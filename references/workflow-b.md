# Workflow B — Fronttest Manager

Paper trade tracker. Source of truth: Supabase `fronttest` table.
NEVER use open_trades for fronttest. These are "what if" ideas only — no real capital.

## B1 — ADD TO FRONTTEST
Triggers: "add to fronttest", "fronttest [STOCK]", "paper trade [STOCK]", "track [STOCK]", "interesting idea [STOCK]"

### Collect fields (same as real trade + extras):
```
stock, symbol, entry_price, qty (default 100 for P&L calc)
stop_loss, t1, t2, t3 (optional)
thesis, thesis_invalidation, entry_trigger
theme       : Nuclear / China+1 / Defence / PLI / IPO Base / etc.
source      : own research / Twitter / screener / etc.
grade       : A+ / A / B / C
conviction  : HIGH / MEDIUM / SPECULATIVE
```

Auto-calculate: rr_t1, rr_t2, risk_per_share, risk_total, max_profit (same formulas as Workflow A)

### Preview & confirm
```
📋 FRONTTEST ENTRY PREVIEW
──────────────────────────────
Stock   : [NAME] ([SYMBOL])
Entry   : ₹[price] × [qty] sh (PAPER)
SL      : ₹[sl] | T1: ₹[t1] R:R [rr_t1] | T2: ₹[t2] R:R [rr_t2]
Theme   : [theme] | Source: [source] | Grade: [grade]
Thesis  : [thesis]
Trigger : [entry_trigger]
Abort if: [thesis_invalidation]
──────────────────────────────
Add to fronttest? (yes/no)
```

### INSERT
```sql
INSERT INTO fronttest (
  added_date, stock, symbol, entry_price, qty, stop_loss,
  t1, t2, t3, rr_t1, rr_t2, risk_per_share, risk_total, max_profit,
  thesis, thesis_invalidation, entry_trigger, theme, source,
  grade, conviction, status, trigger_fired, invalidated
) VALUES (
  CURRENT_DATE, '[stock]', '[symbol]', [entry_price], [qty], [stop_loss],
  [t1], [t2], '[t3]', '[rr_t1]', '[rr_t2]', [risk_per_share], [risk_total], [max_profit],
  '[thesis]', '[thesis_invalidation]', '[entry_trigger]', '[theme]', '[source]',
  '[grade]', '[conviction]', 'WATCHING', false, false
);
```
Confirm: "✅ Added to fronttest. No real capital allocated."

---

## B2 — WEEKLY REVIEW
Triggers: "fronttest review", "weekly fronttest", "review fronttest", "check fronttest", "fronttest update", "fronttest P&L"

### Step 1 — Read all active ideas
```sql
SELECT id, stock, symbol, entry_price, qty, stop_loss, t1, t2, t3,
       rr_t1, rr_t2, thesis, thesis_invalidation, entry_trigger,
       theme, grade, conviction, added_date, notes, trigger_fired, invalidated
FROM fronttest
ORDER BY added_date ASC;
```

### Step 2 — Fetch live CMP via INDmoney
For each symbol: `lookup_ind_keys` → `get_indian_stocks_details`. Fallback: web search.

### Step 3 — Calculate per stock
```
pnl_pct        = (cmp - entry_price) / entry_price × 100
unrealised_pnl = (cmp - entry_price) × qty
dist_to_t1     = (t1 - cmp) / cmp × 100
signal: 🟢 >+5% | 🟡 -5% to +5% | 🔴 <-5% | ⚡ cmp >= t1 | 🚨 cmp <= stop_loss
```

### Step 4 — Report
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 FRONTTEST WEEKLY REVIEW — [DATE]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUMMARY
  Active: [N] | Green: [N] | Red: [N] | Best: [SYM] +X% | Worst: [SYM] -X%

PER-STOCK
  [signal] [SYMBOL] — Entry ₹[X] → CMP ₹[X] ([+/-X%]) | Paper P&L: ₹[X]
  SL ₹[sl] ([X]% below) | T1 ₹[t1] ([X]% away) | Trigger: [entry_trigger]

ACTION FLAGS
  ⚡ TRIGGER FIRED : [list]
  🚨 SL HIT (paper): [list]
  🟢 STRONG        : [list]
  🔴 WEAKENING     : [list]

DELETE CANDIDATES (Claude recommends — always ask before deleting)
  ⚠️ [SYMBOL] — Reason: [SL hit X days ago / thesis dead / 30+ days stale]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Flag for deletion only if: SL hit + no recovery for 2+ weeks, thesis clearly dead, or stale 30+ days.
NEVER auto-delete. Always ask: "Delete [SYMBOL]? (yes / no / keep with note)"

### Step 5 — Update CMP in Supabase
```sql
UPDATE fronttest SET cmp=[cmp], unrealised_pnl=[val], pnl_pct=[val], last_price_check=NOW()
WHERE symbol='[SYMBOL]';
```

---

## B3 — DELETE
Trigger: "delete [SYMBOL] from fronttest", "remove [SYMBOL] fronttest"
Always confirm first. On yes: `DELETE FROM fronttest WHERE symbol = '[SYMBOL]';`

## B4 — EDIT
Trigger: "update fronttest [SYMBOL]", "edit fronttest [SYMBOL]", "move SL fronttest [SYMBOL]"
Ask what to change → preview → confirm → UPDATE SQL on fronttest table.
