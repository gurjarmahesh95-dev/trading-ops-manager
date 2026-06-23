---
name: trading-ops-manager
description: >
  All-in-one trading ops skill. Five workflows — all backed by Supabase (free tier works).
  Needs: Supabase MCP + INDmoney MCP (built for NSE/BSE — DM @equityos1 to adapt for other brokers).
  Pairs with x-post-creater skill (github.com/gurjarmahesh95-dev/x-post-creater-skill) for full trading + content system.
  A: Log new trade → open_trades. B: Fronttest paper trades → fronttest table.
  C: X content system — drafts, follow-ups, performance log → posts table.
  D: Close trade — partial/full exit, move SL → closed_trades.
  E: Journal review — analytics, behavioral patterns, coaching verdict.
  Triggers: add trade, new entry, log trade, entered [STOCK], add to fronttest,
  fronttest [STOCK], paper trade, fronttest review, weekly fronttest, draft post,
  write post, pending posts, post [TICKER], close trade, partial exit, SL hit,
  full exit, move SL, review my journal, trading review, how am I trading.
  Stock name + price implies trade entry. Never mix open_trades and fronttest.
---

# Trading Ops Manager

Five workflows. All Supabase-backed. Read the relevant reference file for full instructions.

---

## WORKFLOW ROUTER

| What user wants | Workflow | Reference file |
|-----------------|----------|----------------|
| Log new real trade | **A — Trade Entry** | `references/workflow-a.md` |
| Add/review paper trade idea | **B — Fronttest** | `references/workflow-b.md` |
| Write/save/finalize X post | **C — X Content** | `references/workflow-c.md` |
| Close/partial exit/move SL | **D — Close Trade** | `references/workflow-d.md` |
| Review journal / analytics | **E — Journal Review** | `references/workflow-e.md` |

**Always read the relevant reference file before executing any workflow.**

---

## ⚙️ SETUP (first time only)

1. Create a free Supabase project at supabase.com
2. Run `references/setup.sql` in your Supabase SQL editor — creates all 5 tables
3. Connect Supabase MCP to Claude (claude.ai → Settings → Integrations)
4. Connect INDmoney MCP for live Indian stock prices
5. Open this SKILL.md and replace `YOUR_SUPABASE_PROJECT_ID` with your actual project ID
6. Install this .skill file in Claude

---

## SUPABASE CONFIG

- **Project ID**: `YOUR_SUPABASE_PROJECT_ID`
- **Tool**: `Supabase:execute_sql` | DDL → `Supabase:apply_migration`
- **Tables**:
  - `open_trades` — real active positions ONLY
  - `closed_trades` — all exits, one row per exit event
  - `fronttest` — paper ideas ONLY, never mixed with real trades
  - `posts` — X content drafts and history
  - `mistakes` — rule violations and lessons
- **HARD RULE**: `fronttest` ↔ `open_trades` never cross. Ever.
- **trade_no**: always `SELECT MAX(trade_no) + 1 FROM closed_trades` before inserting.

---

## ERROR HANDLING

| Problem | Action |
|---------|--------|
| INDmoney fails | `lookup_ind_keys` first → retry → web search fallback |
| Supabase fails | Show SQL → ask user to run manually |
| Missing required field | Ask before proceeding — never skip |
| Post draft exists | Show existing → "update or new?" |
| Fronttest added to open_trades | Redirect to fronttest table |
