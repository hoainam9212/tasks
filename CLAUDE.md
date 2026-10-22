# Gmail cleanup — handoff notes

Account: Gmail of the repo owner. Task: sort the inbox, keep important mail, trash ads/promotions.
Language: reply to the user in Vietnamese.

## Rules (from the user)
- Trash (not permanent delete) only advertising/promotional mail. Trash is recoverable for 30 days.
- NEVER trash: mail labeled `Quan trong` (or its sub-labels), starred mail, transactional mail
  (invoices, payments, orders, bank transfers, utility bills, security/account notices),
  and the Substack newsletter `baihocthutu@substack.com`.
- The user has accounts at Rakuten, TEPCO, Qoo10, Value Domain, ANA, VNA, etc. Their *ads* may be
  trashed, but their transactional/notice mail must be kept.
- If a mail looks transactional or important, skip it and report it instead of trashing.

## Labels created (Gmail label IDs)
- `Quan trong` = Label_16 (parent)
- `Quan trong/Tài chính` = Label_17
- `Quan trong/Bảo mật` = Label_18
- `Quan trong/Công việc` = Label_19
- `Quan trong/Dịch vụ` = Label_20

Note: in `search_threads`, `-label:Label_16` did NOT exclude labeled threads. Check each result's
`labelIds` and skip any thread containing `Label_16` (or STARRED) before trashing.

## Progress (as of 2026-10-03)
Scope chosen by user: inbox mail from the last month (after 2026/09/03).
- Done: 34 important threads labeled; 13 ad threads trashed.
- Remaining: ~100 ad threads in the inbox from 2026/09/03 onward.
- Blocker in the previous (cloud) session: every `trash_thread` call needed a one-time approval,
  with no "always allow" option. Run the next session locally in Claude Desktop (Code, Local)
  so that "Always allow" or an auto-accept mode is available.

## Query for the remaining ads
```
in:inbox after:2026/09/03 -is:starred {from:qoo10info@qoo10.jp from:Trip.com@newsletter.trip.com from:rakutensokuhaimart_2@shop.rakuten.co.jp from:no-reply@mail.coupon.rakuten.co.jp from:anamagazine@mail.ana.co.jp from:koreanair@email.koreanair.com from:noreply@info.vietnamairlines.com from:no-reply@e-news.vietnamairlines.com from:marketing.jp@newsletter.tp-link.com from:noreply@mail.audible.co.jp from:infomag@value-domain.com from:mail@kurashi3.tepco.co.jp from:noreply@albus.is from:info@bloomonline.jp from:mail@mail.adobe.com from:em@em1.cloudflare.com from:no-reply@m.learn.coursera.org from:noreply@email.openai.com from:pampersclub@pg.pampers.jp from:mailnews@mm.mizuhobank.co.jp from:aws-marketing-email-replies@amazon.com}
```
Page through all results, skip threads with `Label_16`/STARRED, then trash the rest.
Known labeled threads that this query matches (do NOT trash): 1a0fb18cc0b8df69 (TEPCO price change),
1a0e779afb2571ac and 1a0ae2ee44af8d98 (Value Domain price change), 1a0a9c0b2cbe857b (Cloudflare AI crawlers).

Sender notes: `info@kurashi.tepco.co.jp` = bills (keep); `mail@kurashi3.tepco.co.jp` = ads (trash).

## Possible next steps
- Offer to create Gmail filters so these ad senders skip the inbox in future.
- The user may want to extend cleanup beyond one month (inbox has ~25,000 threads).

---

# MCP article (Claude Academy course) — handoff notes

Task: the user is writing a Vietnamese blog article summarizing the MCP lessons (~47–57) of
"Building with the Claude API" (https://academy.claude.com/courses/building-with-the-claude-api/introducing-mcp).
Style wanted: lively, concrete, not dry theory. Reply in Vietnamese.

## Doc
- Claude Doc: "Học MCP qua 11 bài của khóa Building with the Claude API" (renamed 2026-10-22; user dislikes
  self-praising titles like "không nhạt" — let the content speak)
  https://claude.ai/artifact/Mf2Sp7aNDo3ndWELRdz15B (project id a745ed4f-ae94-427c-89dc-7420231e395a,
  tab 19b119dd-0439, body node cff1850e-9e21, sequence-diagram widget dea1d623-4267).
- The user has edited the doc since (rev 16+). Read it again before changing anything; keep their edits.
- Open comment in the doc: lessons are numbered 1–11; ask whether to switch to 47–57.

## Sources
- academy.claude.com (and skilljar, coursera) are blocked by the cloud environment's network policy.
- Content came from a learner's notes + code: https://github.com/jaygaha/claude-mcp-course
  (folders 001–003 and cli_project_mcp). The user should cross-check against the official lessons.
- The 11 lessons: Introducing MCP, MCP clients, Project setup, Defining tools with MCP, The server
  inspector, Implementing a client, Defining resources, Accessing resources, Defining prompts,
  Prompts in the client, MCP review.

## Done on 2026-10-21 (second pass, doc rev 22)
- Added to the doc: a "Tool use là gì?" box in the intro; host vs client (1 client : 1 server) bullets;
  JSON-RPC / initialize / stdio vs Streamable HTTP; section "Hiểu lầm hay gặp: MCP là API của API?";
  section "Ngoài khóa học: cắm server thật vào dùng" (claude mcp add, .mcp.json, ${ENV} secrets, safety);
  section "Nếu bạn định thi chứng chỉ Claude" (CCAR-F format, 5 domain weights, 7 MCP points, a self-written
  sample question); extra sources. Cert facts come from unofficial prep guides
  (github.com/dnacenta/claude-certified-architect) — user should verify with the official exam guide.

## Restructured on 2026-10-22 (doc rev 38)
- User disliked per-lesson headings. Doc is now: Mở bài → Phần 1 MCP là gì → Phần 2 Dựng server và viết
  tool đầu tiên → Phần 3 Viết client và nối với Claude → Phần 4 Resources và prompts → Phần 5 Tổng kết và
  mang ra dùng thật → Nếu bạn định thi chứng chỉ Claude → Nguồn. Old lesson sections are H3 under the parts;
  each part opens with one line naming the matching course lessons. In-text "bài N" refs now point to parts.

## V-Sharing export (2026-10-22)
- Publish-ready copy: mcp-article/hoc-mcp-qua-11-bai.md (no H1/byline, starts at H2, no code lines starting
  with "#" — V-Sharing's SEO check "Thứ tự heading đúng" failed on those) + mcp-article/mcp-mot-cau-hoi-10-buoc.png
  (diagram, alt text in the .md). The doc keeps its H1 title; otherwise doc and .md match (doc rev 41).
  If the doc changes, regenerate the .md the same way.

## Discussed in chat (earlier)
- Explained "tool use thuần" (plain tool use without MCP) and a glossary of terms for the user.
  Offered to add a short tool-use explanation to the intro.
- The user found the article similar to Trọng's V-Sharing post "MCP - Kết nối AI với thế giới thực"
  (concept-only: LLM limits, USB-C analogy, host/client/server, Connectors). Overlap is the intro/concepts
  (shared source). Proposed: replace the USB-C analogy (e.g. food-delivery app), open with the hands-on
  `/format plan.md` scene, shorten the client/server concept part. Waiting for the user's choice.
- "MCP là API của API?" — half right: MCP is a protocol/standard, servers often wrap APIs but need not
  (course server wraps a dict), it is self-describing via list_tools, has resources/prompts too, and Claude
  still uses tool use while the client calls the server. Offered to add a "common misconception" section.
