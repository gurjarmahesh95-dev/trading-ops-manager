# Workflow A — Trade Entry

Log a new real trade to Supabase `open_trades`.

## Triggers
"add trade", "new entry", "I entered X", "log this trade", "new position in X", stock name + entry price

## Step 1 — Collect fields
Required (ask if missing, infer if obvious):
```
symbol      : NSE ticker
stock       : Full company name
entry_date  : YYYY-MM-DD (default today)
qty         : integer shares
entry_price : ₹
stop_loss   : ₹ SL
t1, t2      : ₹ targets
t3          : optional (text or ₹)
notes       : 1-2 line thesis
grade       : A+ / A / B / C (default A)
mtf         : true/false
```

Auto-calculate:
```
risk            = (entry_price - stop_loss) × qty
rr_t1           = (t1 - entry_price) / (entry_price - stop_loss) → "X.Xx"
rr_t2           = (t2 - entry_price) / (entry_price - stop_loss)
invested        = entry_price × qty
```

## Step 2 — Preview & confirm
```
📋 TRADE ENTRY PREVIEW
──────────────────────────────
Stock     : [NAME] ([SYMBOL])
Entry     : ₹[price] × [qty] sh = ₹[invested]
SL        : ₹[sl] | Risk: ₹[risk] ([risk_%]%)
T1        : ₹[t1] | R:R [rr_t1]
T2        : ₹[t2] | R:R [rr_t2]
T3        : ₹[t3 or "–"]
Grade     : [grade] | MTF: [yes/no]
Thesis    : [notes]
──────────────────────────────
Confirm? (yes/no)
```

## Step 3 — INSERT to open_trades
```sql
INSERT INTO open_trades (
  symbol, stock, entry_date, qty, entry_price,
  stop_loss, t1, t2, t3, notes, grade,
  risk, rr_t1, rr_t2, invested, status, created_at
) VALUES (
  '[symbol]', '[stock]', '[entry_date]', [qty], [entry_price],
  [stop_loss], [t1], [t2], '[t3]', '[notes]', '[grade]',
  [risk], '[rr_t1]', '[rr_t2]', [invested], 'OPEN', NOW()
);
```

Confirm: "✅ Trade logged."
**Reminder:** "GTT/SL order placed on broker? Rule: no entry is final without GTT."
