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

### ❓ Chưa biết — phải thử mới biết
| Dịch vụ | Có trong group |
|---|---|
| Gemini trên Vertex AI (2.0 / 2.5 / 3 Flash, 2.5 / 3.x Pro, Batch, Context Caching) | A |
| Vertex AI Embeddings (text, multimodal) | A |
| Imagen 3, Veo 2 / Veo 3 | A |
| Grounding with Google Search / Google Maps | A, B |
| Vertex AI Search: Layout Parser, OCR, Data Index | C |
| Dialogflow CX / Conversational Agents | C |

### 💰 Chắc chắn phải trả phí
- Compute Engine (VM), Artifact Registry, Cloud Storage, Cloud Run
- IAP, egress mạng, Cloud Logging
- **Document AI** gọi API riêng (khác với layout parser bật trong data store)
- Gemini qua API key của **Google AI Studio** (aistudio.google.com)

### Cách xác nhận nhóm ❓ (tốn < ¥10)
1. Tạo project thử, gắn vào billing account có credit.
2. Mở **Vertex AI Studio** trong Console (không phải aistudio.google.com) → gửi vài câu cho Gemini Flash.
3. Tuỳ chọn: tạo 1 data store có bật layout parser, nạp 1 file PDF.
4. Sau ~24 giờ: **Billing → Reports**, lọc theo project, nhóm theo **SKU**, xem cột Credits.
   - Credit có trừ dòng Gemini → nhóm ❓ thuộc A → dùng được.
   - Tính vào thẻ → chỉ dùng nhóm ✅.

Ghi kết quả vào đây sau khi thử: `Group = ?`

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
2. **Chọn bản cài đặt bằng biến môi trường.** Đổi nhà cung cấp = sửa `.env` + khởi động lại, không sửa code.
3. **Project GCP riêng cho credit** (`zumen-genai`), gắn billing account có credit. Dễ theo dõi, dễ tắt.
4. **Mặc định giữ hành vi hiện tại** (`pg_bigm`, LLM hiện có).
5. **Giữ bất biến 1 (cô lập org).** Không nạp hồ sơ của khách vào data store Vertex. Data store chỉ chứa văn bản công khai (国交省 / NILIM). Ranking / Check Grounding chỉ gửi đoạn văn tạm thời, không lưu chỉ mục.

### 4.2 Config mới (`core/config.py`, tiền tố `ZUMEN_GENAI_*`)

```env
# Project gắn billing account có credit (tách khỏi project chạy VM)
ZUMEN_GENAI_PROJECT=zumen-genai
ZUMEN_GENAI_LOCATION=global

# Chọn bản cài đặt cho từng cổng
ZUMEN_GENAI_RETRIEVER=pg_bigm            # pg_bigm | vertex_search
ZUMEN_GENAI_RERANKER=none                # none | vertex_ranking
ZUMEN_GENAI_ANSWERER=llm                 # llm | vertex_grounded
ZUMEN_GENAI_GROUNDING_CHECK=none         # none | vertex_check

# Tài nguyên Vertex
ZUMEN_GENAI_STANDARDS_DATASTORE=projects/zumen-genai/locations/global/collections/default_collection/dataStores/standards-public
ZUMEN_GENAI_RANKING_CONFIG=default_ranking_config

# Vận hành
ZUMEN_GENAI_MODE=live                    # live | record | replay (giống ZUMEN_LLM_MODE)
ZUMEN_GENAI_TIMEOUT_S=8
ZUMEN_GENAI_FALLBACK=1                   # lỗi hoặc timeout thì quay về bản local
```

Khi credit hết hạn: `RERANKER=none`, `ANSWERER=llm`, `RETRIEVER=pg_bigm`.

### 4.3 Cấu trúc code (package mới `zumen/genai/`)

```
backend/zumen/genai/
├── ports.py          # Protocol: Retriever, Reranker, GroundedAnswerer, GroundingChecker
├── registry.py       # đọc config → trả về bản cài đặt; bọc fallback + ghi usage
├── local/            # pg_bigm_retriever.py, noop_reranker.py, llm_answerer.py, noop_checker.py
├── vertex/           # search.py, ranking.py, grounded.py, check_grounding.py
└── cassette.py       # record/replay, dùng lại cơ chế của llm
```

```python
# ports.py
class Reranker(Protocol):
    def rerank(self, ctx: OrgCtx, query: str, passages: list[Passage], top_n: int) -> list[Scored]: ...

class GroundedAnswerer(Protocol):
    def answer(self, ctx: OrgCtx, query: str, passages: list[Passage]) -> Answer: ...  # Answer có citations
```

`registry.py`: chọn bản cài đặt theo config; nếu bản Vertex lỗi hoặc quá `TIMEOUT_S` thì chuyển sang bản local, phát sự kiện, ghi log; ghi mỗi lần gọi vào bảng usage.

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
| Tháng 3/2027 | Đánh giá: giữ dịch vụ nào trả phí thật, cái nào chuyển về bản local |
| Trước 11/04/2027 | Đổi config sang bản local (hoặc giữ nếu đáng tiền); xoá data store không dùng |

### 4.6 Nếu credit thuộc group A (Gemini được trả)
- Gắn project chạy VM `zumen` vào billing account có credit → toàn bộ LLM của agent trả bằng credit, không sửa code.
- Dùng Gemini Batch + Context Caching cho nạp hàng loạt kho tri thức (K4).
- Gemini multimodal cho số hoá PDF / TIF (phase 2).
- Embeddings + `pgvector` cho 「過去案件の傾向」 và khớp catalog.
- Tránh **Provisioned Throughput** (cam kết thuê công suất, rất đắt).

## 5. Việc tiếp theo
- [ ] Thử Gemini + layout parser, xem Billing → ghi `Group = ?` ở mục 2
- [ ] Mở repo Zumen-Agent trong Claude Desktop, đối chiếu tên module thật với mục 4.3
- [ ] Bắt đầu PR0 + PR1

## Nguồn
- [Bảng giá Vertex AI Search](https://cloud.google.com/generative-ai-app-builder/pricing?hl=en)
- [Bảng giá Document AI](https://cloud.google.com/document-ai/pricing)
- [Vertex AI Search: parse & chunk documents](https://cloud.google.com/generative-ai-app-builder/docs/parse-chunk-documents)
- [Diễn đàn Google: credit GenAI App Builder](https://discuss.ai.google.dev/t/no-one-is-talking-about-how-to-use-the-credits-of-trial-credit-for-genai-app-builder/101423)
