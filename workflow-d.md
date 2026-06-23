# Workflow D — Close Trade

Handles partial exits, full exits, SL hits, SL moves, and trade history.
Reads from `open_trades`, writes to `closed_trades`, updates/deletes `open_trades`.

---

## D1 — PARTIAL EXIT
Triggers: "partial exit [SYMBOL]", "booked [N] shares of [SYMBOL] at ₹X", "T1 hit [SYMBOL] partial", "sold [N] [SYMBOL]"

### Collect:
```
qty_sold        : shares being closed
exit_price      : ₹
reason          : T1 Hit / T2 Hit / Partial Profit / Risk Reduction / Other
lesson          : what you observed (encouraged)
emotional_state : calm / disciplined / greedy / fearful
```

### Calculate:
```
pnl           = (exit_price - entry_price) × qty_sold
pnl_pct       = (exit_price - entry_price) / entry_price × 100
qty_remaining = current_qty - qty_sold
```

### Preview & confirm:
```
📋 PARTIAL EXIT PREVIEW
──────────────────────────────
Stock     : [NAME] ([SYMBOL])
Sold      : [qty_sold] sh @ ₹[exit_price]
Entry was : ₹[entry_price]
P&L       : ₹[pnl] ([+/-pnl_pct]%)
Remaining : [qty_remaining] sh still open
Reason    : [reason]
──────────────────────────────
Confirm? (yes/no)
```

### Write closed_trades:
```sql
-- Get next trade_no
SELECT MAX(trade_no) + 1 as next_no FROM closed_trades;

INSERT INTO closed_trades (stock, symbol, entry_date, exit_date, qty_sold,
  entry_price, exit_price, pnl, pnl_pct, reason, notes, lesson, emotional_state, trade_no, created_at)
VALUES ('[stock]','[symbol]','[entry_date]',CURRENT_DATE,[qty_sold],
  [entry_price],[exit_price],[pnl],[pnl_pct],'[reason]','[notes]','[lesson]','[emotional_state]',[next_no],NOW());
```

### Update open_trades qty:
```sql
UPDATE open_trades SET qty = [qty_remaining] WHERE symbol = '[SYMBOL]';
```
Confirm: "✅ Partial exit logged. [qty_remaining] shares still running."

---

## D2 — FULL EXIT
Triggers: "full exit [SYMBOL]", "closed [SYMBOL]", "exited [SYMBOL] at ₹X", "sold all [SYMBOL]", "SL hit [SYMBOL]"

Same fields as D1. For SL hits: reason = "SL Hit", capture emotional_state carefully.

```
pnl     = (exit_price - entry_price) × qty
pnl_pct = (exit_price - entry_price) / entry_price × 100
```

### Preview:
```
📋 FULL EXIT PREVIEW
──────────────────────────────
Stock     : [NAME] ([SYMBOL])
Sold      : [qty] sh @ ₹[exit_price]  ← ALL shares
Entry was : ₹[entry_price]
P&L       : ₹[pnl] ([+/-pnl_pct]%)  [🟢 WIN / 🔴 LOSS]
Reason    : [reason]
──────────────────────────────
FULLY CLOSES [SYMBOL]. Confirm? (yes/no)
```

Same INSERT as D1, then:
```sql
DELETE FROM open_trades WHERE symbol = '[SYMBOL]';
```
Confirm: "✅ [SYMBOL] fully closed. P&L: ₹[pnl] ([pnl_pct]%)"

**If SL hit:** Ask — "Log as mistake?" If yes:
```sql
INSERT INTO mistakes (date, stock, setup_grade, mistake_type, what_went_wrong, rule_corrective_action)
VALUES (CURRENT_DATE,'[symbol]','[grade]','SL Hit','[what happened]','[rule for next time]');
```

---

## D3 — MOVE STOP LOSS
Triggers: "move SL [SYMBOL]", "trail SL [SYMBOL] to ₹X", "update stop loss [SYMBOL]"

```sql
UPDATE open_trades SET stop_loss = [new_sl] WHERE symbol = '[SYMBOL]';
```
Show: "SL moved: ₹[old] → ₹[new] | New risk: ₹[new_risk_total]"

---

## D4 — TRADE HISTORY
Triggers: "show closed trades", "trade history", "P&L summary", "how have I done overall", "show exits for [SYMBOL]"

```sql
SELECT symbol, stock, entry_date, exit_date, qty_sold,
       entry_price, exit_price, pnl, pnl_pct, reason, lesson
FROM closed_trades ORDER BY exit_date DESC;
```

Display:
```
📊 CLOSED TRADES SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total exits    : [N]
Total P&L      : ₹[sum]
Wins / Losses  : [W] / [L]
Best trade     : [SYMBOL] +₹[X] ([%])
Worst trade    : [SYMBOL] -₹[X] ([%])
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[full table newest first]
```
