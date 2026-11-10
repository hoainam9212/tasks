# Trial credit for GenAI App Builder — dịch vụ dùng được & kế hoạch nối Zumen-Agent

> Cập nhật: 2026-11-02. Tóm tắt từ phiên làm việc với Claude Code.

## 1. Thông tin credit

| | |
|---|---|
| Tên | Trial credit for GenAI App Builder |
| Số tiền | ¥159,885 (≈ 1.000 USD), còn ¥159,883.72 |
| Loại | One-time |
| Hiệu lực | 10/04/2026 → **11/04/2027** (hết hạn là mất phần chưa dùng) |
| Phạm vi | "Certain usage" — chỉ một số SKU, xem mục 2 |

Credit nằm ở **billing account**. Project nào gắn với billing account đó thì mới được trừ.

## 2. Dịch vụ dùng được

Google có 3 SKU group có thể là phạm vi của credit này. Credit của mình thuộc group nào chỉ xem được trong Billing của mình.

- **A** — [Vertex GenAI Offer 2025](https://cloud.google.com/skus/sku-groups/vertex-genai-offer-2025) (đã gắn nhãn Deprecate; Google support từng chỉ group này cho credit GenAI App Builder)
- **B** — [Vertex AI Search](https://cloud.google.com/skus/sku-groups/vertex-ai-search) (hiện hành)
- **C** — [Vertex AI Search and Conversation](https://cloud.google.com/skus/sku-groups/vertex-ai-search-and-conversation) (đã gắn nhãn Deprecate)

### ✅ Chắc chắn dùng được (có trong cả A, B, C)
- Vertex AI Search (Search API: Standard, Enterprise, LLM add-on, Advanced Generative Answers)
- Ranking API
- Check Grounding API
- Grounded Generation API (kể cả Web Grounded Generation)

> **Đã xác nhận 2026-11-10: credit KHÔNG thuộc group A.** Billing → Reports: project "Zumen GenAI credit",
> SKU *Gemini 3 Flash Text Output - Predictions* ngày 2026-11-02: Usage ¥3, Other savings ¥0, Subtotal ¥3.
> → Gemini, Embeddings, Imagen, Veo đều **phải trả phí**. Credit thuộc group **B hoặc C**.

### ❓ Chưa biết — phải thử mới biết
| Dịch vụ | Có trong group |
|---|---|
| Grounding with Google Search / Google Maps | B (A đã loại) |
| Vertex AI Search: Layout Parser, OCR, Data Index | C |
| Dialogflow CX / Conversational Agents | C |

### 💰 Chắc chắn phải trả phí
- **Gemini trên Vertex AI** (gọi trực tiếp, kể cả Batch, Context Caching), **Embeddings**, **Imagen**, **Veo** — đã xác nhận 2026-11-10
- Các SKU khác trong service Vertex AI Search nhưng không thuộc SKU group: Gemini Business / Gemini Enterprise subscription, AlphaEvolve tokens
- Compute Engine (VM), Artifact Registry, Cloud Storage, Cloud Run
- IAP, egress mạng, Cloud Logging
- **Document AI** gọi API riêng (khác với layout parser bật trong data store)
- Gemini qua API key của **Google AI Studio** (aistudio.google.com)

### Thử tất cả dịch vụ còn lại

Billing Reports chỉ hiện dịch vụ **đã dùng**, nên phải gọi thử mỗi dịch vụ một lần.
Script `probe_credit.sh` gọi hết (Gemini đã biết là mất phí nên bỏ):

| Phép thử | Có trong group | Nếu "Other savings" ≠ ¥0 |
|---|---|---|
| Ranking, Check Grounding, Grounded Generation, Web Grounded Generation, Search API | A, B, C | Xác nhận ✅. Nếu **không** được trả → sai billing account, sửa trước. |
| Grounding with Google Search (qua Gemini) | A, B | Group **B** → dùng được Grounding Google Search / Maps |
| Layout Parsing, OCR, Data Index | C | Group **C** → dùng được Layout, OCR, Data Index, Dialogflow CX |

**Cách 1 — script (khoảng 3 phút chạy, chi phí < ¥30):**
```bash
gcloud auth login
./genai-credit/probe_credit.sh run <PROJECT_ID> mot-file-nho.pdf   # PDF 1–2 trang
# ~24 giờ sau: Billing → Reports → Time range = hôm chạy, Services = All, Group by = SKU
#              → cột "Other savings" từng dòng
./genai-credit/probe_credit.sh cleanup <PROJECT_ID>               # xoá data store thử
```
Project dùng để thử phải gắn vào billing account có credit (ví dụ "Zumen GenAI credit"; script in ra billing account để kiểm).
Dòng Gemini trong Reports (token của phép thử Google Search) sẽ mất phí — bình thường, chỉ xem dòng *Grounding with Google Search*.

**Cách 2 — hỏi Google Billing Support (miễn phí, có khi nhanh hơn chờ Reports):**
Console → Billing → Support → tạo case: *"Credit 'Trial credit for GenAI App Builder' trên billing account này áp dụng cho SKU group nào? Có gồm Gemini trên Vertex AI không?"*

**Đọc kết quả:**
| Gemini | Grounding Google Search | Layout / OCR | Group | Nhóm ❓ dùng được |
|:-:|:-:|:-:|:-:|---|
| ✅ | ✅ | — | **A** | Gemini (cả Batch, Caching), Embeddings, Imagen, Veo, Grounding Google Search / Maps |
| ❌ | ✅ | ❌ | **B** | Grounding Google Search / Maps |
| ❌ | ❌ | ✅ | **C** | Layout parser, OCR, Data Index, Dialogflow CX |

Không thử Veo (một video tốn vài USD) và Dialogflow CX (có trial credit riêng nên kết quả bị lẫn): suy ra từ bảng trên.

Kết quả: `Group = B hoặc C` (A đã loại, 2026-11-10). Còn lại cần tìm: khoản ¥3.41 credit đã trừ là SKU nào
(Billing → Reports, từ 2026-04-10, mọi service, Group by SKU, cột Other savings ≠ 0).
Credit Gemini 3 Flash không còn cần thử nữa.

## 3. Nhận xét bảng kapibot

| サービス | Credit trả? | Ghi chú |
|---|---|---|
| Vertex AI Search | ✅ | |
| Grounded Generation API | ✅ | Phần Gemini sinh câu trả lời tính vào SKU "Vertex AI Search: Grounded Generation", nên được trả kể cả khi gọi Gemini trực tiếp không được trả. Chỉ dùng cho kiểu "tìm rồi trả lời". |
| Document AI / Layout Parser | ⚠️ | Document AI gọi riêng → **mất phí**. Layout parser bật trong data store → chỉ group C, chưa chắc. Đừng gọi Document AI trực tiếp. |
| Ranking API | ✅ | |

## 4. Kế hoạch nối Zumen-Agent

Dựa trên `system-design.md` của Zumen-Agent (chưa xem code thật — tên file / module là suy ra, cần kiểm tra khi mở repo).

### 4.1 Nguyên tắc
1. **Cổng (interface) theo chức năng, không theo nhà cung cấp.** Code nghiệp vụ chỉ gọi `Reranker`, `GroundedAnswerer`…
2. **Config chỉ chứa dịch vụ được credit trả** (4 dịch vụ ✅). Mỗi dịch vụ có một cờ bật/tắt; tắt thì Zumen chạy đường hiện có (`pg_bigm`, LLM hiện tại). Bật/tắt = sửa `.env` + khởi động lại, không sửa code.
3. **Project GCP riêng cho credit** (`zumen-genai`), gắn billing account có credit. Dễ theo dõi, dễ tắt.
4. **Mặc định giữ hành vi hiện tại** (`pg_bigm`, LLM hiện có).
5. **Giữ bất biến 1 (cô lập org).** Không nạp hồ sơ của khách vào data store Vertex. Data store chỉ chứa văn bản công khai (国交省 / NILIM). Ranking / Check Grounding chỉ gửi đoạn văn tạm thời, không lưu chỉ mục.

### 4.2 Config mới (`core/config.py`, tiền tố `ZUMEN_GENAI_*`)

Chỉ gồm dịch vụ được credit trả. Không có `pg_bigm`, LLM hiện tại hay Gemini trực tiếp ở đây.

```env
# ── Trial credit for GenAI App Builder ──
# Project gắn billing account có credit (tách khỏi project chạy VM)
ZUMEN_GENAI_PROJECT=zumen-genai
ZUMEN_GENAI_LOCATION=global

# Vertex AI Search — tra văn bản tiêu chuẩn công khai (国交省 / NILIM)
ZUMEN_GENAI_SEARCH_ENABLED=0
ZUMEN_GENAI_SEARCH_DATASTORE=projects/zumen-genai/locations/global/collections/default_collection/dataStores/standards-public

# Ranking API — xếp hạng lại kết quả pg_bigm
ZUMEN_GENAI_RANKING_ENABLED=0
ZUMEN_GENAI_RANKING_CONFIG=default_ranking_config

# Grounded Generation API — trả lời kèm trích dẫn
ZUMEN_GENAI_GROUNDED_ENABLED=0

# Check Grounding API — kiểm câu LLM viết có đúng căn cứ
ZUMEN_GENAI_CHECK_GROUNDING_ENABLED=0
```

- Cờ `=0`, hoặc Vertex lỗi / quá thời gian chờ (mặc định 8 giây, đặt trong code) → tự quay về đường hiện có.
- Cassette record/replay dùng chung `ZUMEN_LLM_MODE` sẵn có, không thêm biến mới.
- Khi credit hết hạn: đặt 4 cờ `*_ENABLED=0`.

### 4.3 Cấu trúc code (package mới `zumen/genai/`)

```
backend/zumen/genai/
├── ports.py          # Protocol: Retriever, Reranker, GroundedAnswerer, GroundingChecker
├── registry.py       # đọc cờ *_ENABLED → bản Vertex hoặc đường hiện có; bọc fallback + ghi usage
├── local/            # bọc code hiện có (pg_bigm, llm) — không có trong config
├── vertex/           # search.py, ranking.py, grounded.py, check_grounding.py (4 dịch vụ credit)
└── cassette.py       # record/replay, dùng lại cơ chế của llm
```

```python
# ports.py
class Reranker(Protocol):
    def rerank(self, ctx: OrgCtx, query: str, passages: list[Passage], top_n: int) -> list[Scored]: ...

class GroundedAnswerer(Protocol):
    def answer(self, ctx: OrgCtx, query: str, passages: list[Passage]) -> Answer: ...  # Answer có citations
```

`registry.py`: cờ bật → dùng bản Vertex; cờ tắt → đường hiện có. Bản Vertex lỗi hoặc quá thời gian chờ thì chuyển sang đường hiện có, phát sự kiện, ghi log. Ghi mỗi lần gọi Vertex vào bảng usage.

### 4.4 Các bước / PR

| PR | Nội dung | Hành vi |
|---|---|---|
| **0. Hạ tầng** | Tạo project `zumen-genai`, gắn billing account có credit, bật `discoveryengine.googleapis.com`. Cấp `roles/discoveryengine.user` cho service account của VM. Đặt Budget alert. | — |
| **1. Khung** | `zumen/genai/`: ports, registry, bản local, config. Test hợp đồng cho từng cổng. | Không đổi |
| **2. Theo dõi chi phí** | Migration `0042_genai_calls.sql`: `genai_calls(org_id, run_id, service, units, latency_ms, status)`. Thêm vào `ORG_TABLES`, chạy `gen_rls.py`. Hiển thị trong `usage`. | Không đổi |
| **3. Ranking API** | `vertex/ranking.py`. Nối vào tìm kiếm của `kb`: `pg_bigm` top 50 → Ranking → top 10. | Bật bằng cờ |
| **4. Data store tiêu chuẩn** | Nạp PDF 国交省 / NILIM vào `standards-public`. `vertex/search.py` tra căn cứ cho Rule Engine và Fix Strategist. | Bật bằng cờ |
| **5. Grounded Generation + Check Grounding** | Trả lời câu hỏi về kho, giải thích Issue kèm trích dẫn; kiểm câu LLM viết trong câu hỏi gửi kỹ sư. | Bật bằng cờ |
| **6. Vận hành** | Trạng thái provider trong `/api/platform/health`; cờ theo org trong `settings` (`allow_external_ai`); runbook `docs/runbook/genai.md`. | — |

Kiểm thử / CI: mọi lệnh gọi Vertex đi qua cassette (`replay` trong CI, không cần mạng). Thêm dependency `google-cloud-discoveryengine`.

### 4.5 Mốc thời gian

| Thời điểm | Việc |
|---|---|
| Tuần 1 | PR0 + PR1 + PR2. Một ngày sau khi gọi thử, xem Billing để xác nhận credit có trừ. |
| Tuần 2–3 | PR3 (Ranking), PR4 (data store tiêu chuẩn) |
| Tuần 4–5 | PR5, PR6 |
| Tháng 3/2027 | Đánh giá: giữ dịch vụ nào trả phí thật, cái nào tắt |
| Trước 11/04/2027 | Tắt các cờ `*_ENABLED` không giữ; xoá data store không dùng |

### 4.6 Nếu credit thuộc group A (Gemini được trả) — KHÔNG áp dụng (đã loại A ngày 2026-11-10)

LLM của agent Zumen (Planner, Fix Strategist…) là chi phí thật. Muốn có câu trả lời do Gemini viết mà vẫn dùng credit
thì đi qua **Grounded Generation API** (tính vào SKU Vertex AI Search). Phần dưới chỉ giữ để tham khảo.
- Gắn project chạy VM `zumen` vào billing account có credit → toàn bộ LLM của agent trả bằng credit, không sửa code.
- Dùng Gemini Batch + Context Caching cho nạp hàng loạt kho tri thức (K4).
- Gemini multimodal cho số hoá PDF / TIF (phase 2).
- Embeddings + `pgvector` cho 「過去案件の傾向」 và khớp catalog.
- Tránh **Provisioned Throughput** (cam kết thuê công suất, rất đắt).

## 5. Việc tiếp theo
- [ ] Chạy `probe_credit.sh` (hoặc hỏi Billing Support), xem Billing → ghi `Group = ?` ở mục 2
- [ ] Mở repo Zumen-Agent trong Claude Desktop, đối chiếu tên module thật với mục 4.3
- [ ] Bắt đầu PR0 + PR1

## Nguồn
- [Bảng giá Vertex AI Search](https://cloud.google.com/generative-ai-app-builder/pricing?hl=en)
- [Bảng giá Document AI](https://cloud.google.com/document-ai/pricing)
- [Vertex AI Search: parse & chunk documents](https://cloud.google.com/generative-ai-app-builder/docs/parse-chunk-documents)
- [Diễn đàn Google: credit GenAI App Builder](https://discuss.ai.google.dev/t/no-one-is-talking-about-how-to-use-the-credits-of-trial-credit-for-genai-app-builder/101423)
