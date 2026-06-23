# Trading Ops Manager — Claude Skill

A Claude skill that turns your AI assistant into a complete trading operations system. Log trades, track paper ideas, manage your X content, close positions, and get a full coaching review — all from a single conversation, all stored in Supabase.

Built for Indian NSE/BSE swing traders. Works with Claude + Supabase + INDmoney MCP.

---

## What It Does

Most traders use spreadsheets to track trades. This skill replaces that entirely — you talk to Claude naturally and it handles everything behind the scenes, writing directly to your Supabase database.

**Five workflows in one skill:**

### A — Trade Entry
Say "entered ZENTEC at ₹1,720, 100 shares, SL ₹1,650, T1 ₹2,000, T2 ₹2,300" and Claude:
- Auto-calculates R:R, total risk ₹, max profit
- Shows a preview for confirmation
- Writes the trade to your `open_trades` table
- Reminds you to place the GTT order on your broker

### B — Fronttest (Paper Trades)
Track ideas without risking capital. Whenever you find an interesting setup in any chat, say "add to fronttest" and Claude logs it as a paper trade with full parameters. Weekly review fetches live prices via INDmoney, shows P&L as if you had entered, and flags ideas ready for real entry.

### C — X Content System
No X API needed. Save post drafts to Supabase, write follow-up threads that reference your original call, track what performed best. When you're ready to post, Claude formats it as clean copy-paste text. Over time it builds a performance database — which formats and tickers work best for your audience.

### D — Close Trade
Handle partial exits, full exits, SL hits cleanly. Each exit logs to `closed_trades` with lesson and emotional state captured. SL hits prompt an automatic mistake log. Trade history always one command away.

### E — Journal Review (Trading Coach)
Pulls all your open and closed trade data, calculates:
- Win rate, expectancy, avg win vs loss
- R:R planned vs actually achieved
- Holding period: winners vs losers
- Exit quality: how often you hit T1/T2 vs manual exits
- Open positions health: total capital at risk, closest to SL, closest to T1
- Behavioral patterns from your mistakes table

Ends with a coaching verdict: 3 things you're doing well, 3 things costing you money, 1 priority fix for this week — all backed by numbers from your actual data.

---

## Requirements

- [Claude](https://claude.ai) (Pro or higher recommended)
- [Supabase](https://supabase.com) account — **free tier works perfectly**
- [Supabase MCP](https://supabase.com/docs/guides/getting-started/mcp) connected to Claude
- [INDmoney MCP](https://mcp.indmoney.com) connected to Claude — built for live NSE/BSE prices

> **Using a different broker?** The skill is built with INDmoney for Indian markets. If you want to adapt it for Zerodha, Dhan, or any other broker/market, you can modify the price-fetch steps in the reference files yourself — or DM [@equityos1](https://x.com/equityos1) and I'll help you set it up.

> **Building AI tools for trading or finance?** DM [@equityos1](https://x.com/equityos1) — always happy to collaborate.

---

## Pairs With

This skill works best alongside **[x-post-creater](https://github.com/gurjarmahesh95-dev/x-post-creater-skill)** — a Claude skill for writing high-engagement X posts for any niche.

Together they form a complete system:
- `trading-ops-manager` → logs your trades, tracks paper ideas, reviews your journal
- `x-post-creater` → turns your trade calls and market observations into X content

Workflow C (X Content System) inside this skill is built to complement x-post-creater's voice and formatting conventions.

---

## Setup

**1. Create Supabase tables**

Go to your Supabase project → SQL Editor → paste and run `references/setup.sql`

This creates 5 tables:
- `open_trades` — active real positions
- `closed_trades` — all exits, one row per exit event
- `fronttest` — paper trade ideas (never mixed with real trades)
- `posts` — X content drafts and performance history
- `mistakes` — rule violations and lessons

**2. Connect MCPs to Claude**

In claude.ai → Settings → Integrations:
- Add Supabase MCP
- Add INDmoney MCP

**3. Configure your project ID**

Open `SKILL.md` and replace `YOUR_SUPABASE_PROJECT_ID` with your actual Supabase project ID (found in your Supabase dashboard under Project Settings → General).

**4. Install the skill**

Download `trading-ops-manager.skill` and install it in Claude via Settings → Skills.

---

## Usage Examples

```
# Log a new trade
"Entered HLEGLAS at ₹375, 50 shares, SL ₹340, T1 ₹480, T2 ₹580. Nuclear equipment theme."

# Add a paper trade idea
"Add SPEL to fronttest. Entry ₹155, SL ₹130, T1 ₹200, T2 ₹260. ISM 2.0 OSAT play."

# Weekly fronttest check
"Fronttest review"

# Draft an X post
"Write a post for INOXINDIA — King Candle, 2.6x volume, cryogenic infrastructure play."

# Close a partial position
"Booked 25 shares of ZENTEC at ₹2,050. T1 partial exit."

# Move a stop loss
"Trail SL on NETWEB to ₹4,900"

# Full journal review
"Review my journal"

# Quick version
"Quick review"
```

---

## File Structure

```
trading-ops-manager/
├── SKILL.md                    ← Main skill file (install this)
└── references/
    ├── setup.sql               ← Run once in Supabase SQL Editor
    ├── workflow-a.md           ← Trade entry instructions
    ├── workflow-b.md           ← Fronttest manager instructions
    ├── workflow-c.md           ← X content system instructions
    ├── workflow-d.md           ← Close trade instructions
    └── workflow-e.md           ← Journal review instructions
```

---

## Philosophy

Most trading tools are dashboards — they show you data but don't help you act. This skill is different. It lives inside your conversation with Claude, so the friction between "I took a trade" and "it's logged with full details" is a single sentence.

The fronttest workflow exists because the gap between "this looks interesting" and "I entered a real trade" should be a paper trail, not a leap of faith.

The journal review is deliberately harsh — it doesn't congratulate you for being in the market, it tells you where you're leaking money and what to fix this week.

---

## Customisation

The skill is built for Indian swing traders but the structure works for any market. To adapt:
- Replace INDmoney with any price feed MCP you have access to
- Adjust the X brand context in `references/workflow-c.md` to your own account voice
- Add or remove fields from `setup.sql` to match your trading style

---

## Built By

[@equityos1](https://x.com/equityos1) — Indian swing trader building AI tools for traders.

**Want to adapt this for a different broker or market?** DM me on X — [@equityos1](https://x.com/equityos1).

**Building something similar or want to collaborate on AI trading tools?** DM me — always open to working with people doing interesting things in this space.

---

## Licence

MIT — use it, fork it, adapt it. If you build something on top of this, a mention would be appreciated.
