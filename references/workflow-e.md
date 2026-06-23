# Workflow E — Trading Journal Review

Acts as a trading coach. Pulls all data, calculates hard metrics, finds behavioral patterns, gives honest judgment with data behind every statement.

Triggers: "review my journal", "trading review", "weekly review", "how am I trading", "journal review", "am I improving", "deep review", "quick review"

Depth: "quick review" → E1 + E3 summary only. Default / "deep review" → full E1 + E2 + E3.

---

## Step 1 — Pull all data

```sql
-- Open positions
SELECT symbol, stock, entry_date, qty, entry_price, cmp, stop_loss,
       t1, t2, t3, status, notes, invested, unrealised_pnl, pnl_pct, rr_t1, rr_t2
FROM open_trades ORDER BY entry_date ASC;

-- All closed exits
SELECT symbol, stock, entry_date, exit_date, qty_sold, entry_price, exit_price,
       pnl, pnl_pct, reason, lesson, emotional_state, trade_no
FROM closed_trades ORDER BY exit_date ASC;

-- All mistakes
SELECT date, stock, setup_grade, mistake_type, what_went_wrong, rule_corrective_action
FROM mistakes ORDER BY date ASC;
```

---

## E1 — PERFORMANCE METRICS

Calculate from closed_trades:

**Win/Loss**
- total_exits, winners (pnl>0), losers (pnl<0), win_rate %
- total_booked_pnl, avg_win_₹, avg_loss_₹
- largest_win (symbol + ₹), largest_loss (symbol + ₹)

**Expectancy** (most important)
- expectancy = (win_rate × avg_win) + ((1-win_rate) × avg_loss)
- Positive = each trade makes ₹X avg | Negative = each trade loses ₹X avg

**R:R Analysis**
- avg planned rr_t1 vs avg achieved rr
- achieved_rr per trade = exit pnl / (entry_price - stop_loss) × qty
- rr_gap = planned - achieved → positive gap = exiting too early

**Holding Period**
- avg_holding_winners vs avg_holding_losers (exit_date - entry_date)
- If holding losers longer than winners → classic mistake, flag it

**Exit Reason Breakdown**
- COUNT by reason: T1 Hit / T2 Hit / SL Hit / Partial Profit / Manual Exit
- What % are at planned targets vs unplanned?

**Monthly P&L Table**
- GROUP BY month(exit_date) → Month | Trades | P&L | Win Rate

**MTF vs Cash**
- Filter notes ILIKE '%MTF%' vs rest → compare avg pnl_pct

---

## E2 — BEHAVIORAL ANALYSIS (deep review only)

**Mistake Patterns**
- Most repeated mistake_type
- Most repeated stock in mistakes
- Are mistakes decreasing or increasing over time?
- Most violated rule (from rule_corrective_action)

**Emotional State on Losses**
- From emotional_state where pnl < 0
- Any pattern? (fear/greed losing more than calm/disciplined?)

**Early Exit Detection**
- Trades with reason = 'Manual Exit' or 'Partial Profit' where exit_price < t1 → flagged
- Count: how many trades exited before T1?

**SL Discipline**
- SL hit trades: was exit_price ≈ stop_loss (respected) or exit_price << stop_loss (delayed)?

**Winner Cutting**
- After T1 partial: was remaining qty held to T2 or manually exited early?

---

## E3 — OPEN POSITIONS HEALTH

For each open position:
```
dist_to_sl   = (cmp - stop_loss) / cmp × 100 → "X% from SL"
dist_to_t1   = (t1 - cmp) / cmp × 100        → "X% to T1"
days_held    = TODAY - entry_date
risk_if_sl   = (entry_price - stop_loss) × qty
```

Portfolio risk:
```
total_deployed     = SUM(entry_price × qty)
total_at_risk      = SUM(risk_if_sl) across all positions
max_drawdown_if_all_SLs_hit = total_at_risk / total_deployed × 100
```

Flag:
- 🚨 Closest to SL (most urgent)
- 🎯 Closest to T1 (most promising)
- ⏳ Held > 30 days without T1 (thesis stalling?)
- 🔒 SL above entry price (risk-free position — highlight)

---

## Step 2 — Deliver Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 TRADING JOURNAL REVIEW
Date: [today] | Period: [first trade] → today
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SCORECARD
  Booked P&L      : ₹[X]
  Win Rate        : [X]% ([W]W/[L]L)
  Expectancy      : ₹[X] per trade [🟢/🔴]
  Avg Win / Loss  : ₹[X] / ₹[X]
  R:R Planned vs Achieved : [X]x vs [X]x
  Avg Hold — Wins : [X]d | Losses: [X]d
  Best / Worst    : [SYM] +₹[X] / [SYM] -₹[X]

MONTHLY P&L
  [Month] : ₹[X] ([N] trades, [X]% win rate)

EXIT QUALITY
  T1 [N]([X]%) | T2 [N]([X]%) | SL [N]([X]%) | Manual [N]([X]%)
  → [Honest judgment on exit discipline]

OPEN POSITIONS HEALTH
  Deployed: ₹[X] | Unrealised: ₹[X] | At risk: ₹[X] ([X]% of deployed)
  🚨 Closest SL : [SYM] [X]% away
  🎯 Closest T1 : [SYM] [X]% away
  ⚠️  Needs attention: [list]

BEHAVIORAL PATTERNS (deep review)
  Top mistake   : [type] — [N] times
  Most violated : [rule]
  Emotion on losses: [pattern]
  [2-3 sentences honest behavioral observation]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COACHING VERDICT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ DOING WELL
  1. [strength + data]
  2. [strength + data]
  3. [strength + data]

❌ COSTING YOU MONEY
  1. [leak + data — specific, not generic]
  2. [leak + data]
  3. [leak + data]

🎯 PRIORITY FIX THIS WEEK
  [One single most impactful change]
  Why: [data-backed reason]
  How: [concrete action]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Rules for coaching verdict:**
- Never vague. "Improve entries" = useless. "B-grade setups avg -₹X vs A-grade +₹Y — stop taking B setups" = useful.
- Every observation backed by a number.
- Honest even if numbers are bad. Goal is improvement.
- If < 5 closed trades: say so, give what's possible, focus on open positions health.
