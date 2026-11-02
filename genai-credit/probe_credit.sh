#!/usr/bin/env bash
# Thử nhanh xem credit "Trial credit for GenAI App Builder" trả cho dịch vụ nào.
# Mỗi dịch vụ gọi 1 lần với chi phí nhỏ nhất; ~24 giờ sau xem Billing → Reports theo SKU.
#
# Cách dùng:
#   ./probe_credit.sh run <PROJECT_ID> [file.pdf]   # gọi thử (PDF nhỏ 1–2 trang để thử layout parser / OCR)
#   ./probe_credit.sh cleanup <PROJECT_ID>          # xoá data store thử sau khi đã xem Billing
#
# Cần: gcloud đã đăng nhập (gcloud auth login), curl, base64.
set -euo pipefail

CMD="${1:-}"
PROJECT="${2:-}"
PDF="${3:-}"
REGION="us-central1"
DE="https://discoveryengine.googleapis.com/v1/projects/${PROJECT}/locations/global"
STORES=(credit-probe-layout credit-probe-ocr)

usage() { sed -n '2,9p' "$0"; exit 1; }
[[ -n "$CMD" && -n "$PROJECT" ]] || usage

TOKEN="$(gcloud auth print-access-token)"

call() {  # call <tên> <METHOD> <URL> [body]
  local name="$1" method="$2" url="$3" body="${4:-}" code
  code=$(curl -sS -o /tmp/probe_resp.json -w '%{http_code}' -X "$method" "$url" \
    -H "Authorization: Bearer ${TOKEN}" -H "x-goog-user-project: ${PROJECT}" \
    -H "Content-Type: application/json" ${body:+-d "$body"})
  if [[ "$code" == 2* ]]; then
    printf '  %-34s OK (%s)\n' "$name" "$code"
  else
    printf '  %-34s LỖI (%s): %s\n' "$name" "$code" "$(head -c 300 /tmp/probe_resp.json)"
  fi
}

wait_op() {  # chờ long-running operation của Discovery Engine
  local op
  op=$(sed -n 's/.*"name": *"\([^"]*operations[^"]*\)".*/\1/p' /tmp/probe_resp.json | head -1)
  [[ -n "$op" ]] || return 0
  for _ in $(seq 1 30); do
    curl -sS "https://discoveryengine.googleapis.com/v1/${op}" \
      -H "Authorization: Bearer ${TOKEN}" -H "x-goog-user-project: ${PROJECT}" | grep -q '"done": *true' && return 0
    sleep 5
  done
  echo "  (data store vẫn đang tạo, chạy lại lệnh sau ít phút nếu bước tải PDF lỗi)"
}

case "$CMD" in
run)
  echo "== Kiểm tra billing của project"
  gcloud billing projects describe "$PROJECT" --format='value(billingAccountName,billingEnabled)'
  echo "   → billing account này phải là account đang chứa credit."

  echo "== Bật API"
  gcloud services enable aiplatform.googleapis.com discoveryengine.googleapis.com --project "$PROJECT"

  echo "== Đối chứng (✅ chắc chắn được credit trả)"
  call "Ranking API" POST "${DE}/rankingConfigs/default_ranking_config:rank" \
    '{"model":"semantic-ranker-default@latest","query":"test","records":[{"id":"1","content":"hello"}]}'

  echo "== Phép thử quyết định group"
  call "Gemini 2.5 Flash (group A?)" POST \
    "https://aiplatform.googleapis.com/v1/projects/${PROJECT}/locations/global/publishers/google/models/gemini-2.5-flash:generateContent" \
    '{"contents":[{"role":"user","parts":[{"text":"Reply OK"}]}]}'
  call "Grounding Google Search (A/B?)" POST \
    "https://aiplatform.googleapis.com/v1/projects/${PROJECT}/locations/global/publishers/google/models/gemini-2.5-flash:generateContent" \
    '{"contents":[{"role":"user","parts":[{"text":"今日の東京の天気は?"}]}],"tools":[{"googleSearch":{}}]}'

  echo "== Thử thêm cho chắc (group A)"
  call "Embeddings text-embedding-005" POST \
    "https://${REGION}-aiplatform.googleapis.com/v1/projects/${PROJECT}/locations/${REGION}/publishers/google/models/text-embedding-005:predict" \
    '{"instances":[{"content":"test"}]}'

  if [[ -n "$PDF" ]]; then
    echo "== Layout parser / OCR / Data Index (group C?)"
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
  else
    echo "== Bỏ qua layout parser / OCR (không có file PDF)"
  fi

  echo
  echo "Xong. Khoảng 24 giờ sau: Billing → Reports → lọc project ${PROJECT} → Group by SKU → xem cột Credits."
  echo "Đối chiếu kết quả với bảng trong genai-credit/PLAN.md (mục 2)."
  echo "Sau khi xem xong: ./probe_credit.sh cleanup ${PROJECT}"
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
