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
