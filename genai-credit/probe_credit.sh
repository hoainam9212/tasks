#!/usr/bin/env bash
# Thử xem credit "Trial credit for GenAI App Builder" trả cho những dịch vụ nào.
# Mỗi dịch vụ gọi 1 lần với chi phí nhỏ nhất (tổng < ¥30).
# ~24 giờ sau: Billing → Reports → Time range = hôm chạy, Services = All, Group by = SKU,
# xem cột "Other savings": khác ¥0 → credit trả; = ¥0 → mất phí.
#
# Cách dùng:
#   ./probe_credit.sh run <PROJECT_ID> <file.pdf>   # PDF nhỏ 1–2 trang
#   ./probe_credit.sh cleanup <PROJECT_ID>          # xoá data store thử sau khi đã xem Billing
#
# Cần: gcloud đã đăng nhập (gcloud auth login), curl, base64.
# Đã biết (2026-11-10): Gemini gọi trực tiếp KHÔNG được credit trả → không thử lại.
set -euo pipefail

CMD="${1:-}"
PROJECT="${2:-}"
PDF="${3:-}"
DE="https://discoveryengine.googleapis.com/v1/projects/${PROJECT}/locations/global"
STORES=(credit-probe-layout credit-probe-ocr)
RESP="$(mktemp)"
trap 'rm -f "$RESP"' EXIT

usage() { sed -n '2,13p' "$0"; exit 1; }
[[ -n "$CMD" && -n "$PROJECT" ]] || usage

TOKEN="$(gcloud auth print-access-token)"

call() {  # call <tên> <METHOD> <URL> [body]
  local name="$1" method="$2" url="$3" body="${4:-}" code
  code=$(curl -sS -o "$RESP" -w '%{http_code}' -X "$method" "$url" \
    -H "Authorization: Bearer ${TOKEN}" -H "x-goog-user-project: ${PROJECT}" \
    -H "Content-Type: application/json" ${body:+-d "$body"})
  if [[ "$code" == 2* ]]; then
    printf '  %-40s OK (%s)\n' "$name" "$code"
  else
    printf '  %-40s LỖI (%s): %s\n' "$name" "$code" "$(head -c 300 "$RESP")"
  fi
}

wait_op() {  # chờ long-running operation của Discovery Engine
  local op
  op=$(sed -n 's/.*"name": *"\([^"]*operations[^"]*\)".*/\1/p' "$RESP" | head -1)
  [[ -n "$op" ]] || return 0
  for _ in $(seq 1 30); do
    curl -sS "https://discoveryengine.googleapis.com/v1/${op}" \
      -H "Authorization: Bearer ${TOKEN}" -H "x-goog-user-project: ${PROJECT}" | grep -q '"done": *true' && return 0
    sleep 5
  done
  echo "  (thao tác vẫn đang chạy, có thể chạy lại lệnh sau ít phút)"
}

case "$CMD" in
run)
  [[ -n "$PDF" ]] || usage
  echo "== Kiểm tra billing của project (phải là billing account chứa credit)"
  gcloud billing projects describe "$PROJECT" --format='value(billingAccountName,billingEnabled)'

  echo "== Bật API"
  gcloud services enable aiplatform.googleapis.com discoveryengine.googleapis.com --project "$PROJECT"

  echo "== 1. Nhóm ✅ (có trong mọi SKU group) — để xác nhận"
  call "Ranking API" POST "${DE}/rankingConfigs/default_ranking_config:rank" \
    '{"model":"semantic-ranker-default@latest","query":"capital of Japan","records":[{"id":"1","content":"Tokyo is the capital of Japan."}]}'
  call "Check Grounding API" POST "${DE}/groundingConfigs/default_grounding_config:check" \
    '{"answerCandidate":"Tokyo is the capital of Japan.","facts":[{"factText":"Tokyo is the capital of Japan."}]}'
  call "Grounded Generation (inline facts)" POST "${DE}:generateGroundedContent" \
    '{"contents":[{"role":"user","parts":[{"text":"What is the capital of Japan?"}]}],"groundingSpec":{"groundingSources":[{"inlineSource":{"groundingFacts":[{"factText":"Tokyo is the capital of Japan."}]}}]}}'
  call "Web Grounded Generation" POST "${DE}:generateGroundedContent" \
    '{"contents":[{"role":"user","parts":[{"text":"What is the capital of Japan?"}]}],"groundingSpec":{"groundingSources":[{"googleSearchSource":{}}]}}'

  echo "== 2. Nhóm B? — Grounding with Google Search (kèm vài token Gemini, phần token chắc chắn mất phí)"
  call "Gemini + Google Search grounding" POST \
    "https://aiplatform.googleapis.com/v1/projects/${PROJECT}/locations/global/publishers/google/models/gemini-2.5-flash:generateContent" \
    '{"contents":[{"role":"user","parts":[{"text":"東京の人口は?"}]}],"tools":[{"googleSearch":{}}]}'

  echo "== 3. Nhóm C? — Layout parser / OCR / Data Index, rồi Search API trên data store"
  RAW="$(base64 -w0 "$PDF" 2>/dev/null || base64 -i "$PDF" | tr -d '\n')"
  for store in "${STORES[@]}"; do
    if [[ "$store" == *layout ]]; then
      parsing='{"layoutParsingConfig":{}}'
    else
      parsing='{"ocrParsingConfig":{"useNativeText":false}}'
    fi
    call "Tạo data store ${store}" POST \
      "${DE}/collections/default_collection/dataStores?dataStoreId=${store}" \
      "{\"displayName\":\"${store}\",\"industryVertical\":\"GENERIC\",\"solutionTypes\":[\"SOLUTION_TYPE_SEARCH\"],\"contentConfig\":\"CONTENT_REQUIRED\",\"documentProcessingConfig\":{\"defaultParsingConfig\":${parsing}}}"
    wait_op
    call "Nạp PDF vào ${store}" POST \
      "${DE}/collections/default_collection/dataStores/${store}/branches/default_branch/documents?documentId=probe1" \
      "{\"content\":{\"mimeType\":\"application/pdf\",\"rawBytes\":\"${RAW}\"}}"
  done

  echo "== 4. Nhóm ✅ — Search API (đợi 60 giây cho tài liệu được đánh chỉ mục)"
  sleep 60
  call "Search API (data store)" POST \
    "${DE}/collections/default_collection/dataStores/${STORES[0]}/servingConfigs/default_search:search" \
    '{"query":"test","pageSize":5}'

  echo
  echo "Xong. Khoảng 24 giờ sau: Billing → Reports → Time range = hôm nay, Services = All,"
  echo "Group by = SKU → cột 'Other savings' của từng dòng. Đối chiếu bảng trong genai-credit/PLAN.md."
  echo "Dòng LỖI ở trên = dịch vụ chưa được gọi, gửi nội dung lỗi để sửa."
  echo "Xem xong thì xoá data store: ./probe_credit.sh cleanup ${PROJECT}"
  ;;
cleanup)
  for store in "${STORES[@]}"; do
    call "Xoá data store ${store}" DELETE "${DE}/collections/default_collection/dataStores/${store}"
  done
  ;;
*)
  usage
  ;;
esac
