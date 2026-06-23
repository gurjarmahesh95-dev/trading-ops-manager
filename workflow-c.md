# Workflow C — X Content System

Supabase `posts` table is the brain. No X API needed yet.
Goals: never repeat a post, never lose an idea, build follow-up chains, track performance over time.

post_type values: new_call | follow_up | t1_hit | t2_hit | sl_hit | theme | opinion | fronttest | idea
status values: draft | ready | posted | archived

---

## C1 — WRITE & SAVE NEW POST
Triggers: "write post for [TICKER]", "draft post on [TOPIC]", "post idea about X", "save this post idea", "I want to post about X later"

1. **Check duplicates first**
```sql
SELECT id, ticker, post_type, status, created_at, content
FROM posts WHERE ticker='[TICKER]' OR content ILIKE '%[keyword]%'
ORDER BY created_at DESC LIMIT 5;
```
If recent post exists → show it → "New post or follow-up?"

2. **Fetch live CMP via INDmoney** — always before writing any stock post.

3. **Write both versions:**
   - 🆓 FREE: ≤280 chars, punchy hook, 1 CTA, max 2 hashtags
   - 💎 PREMIUM: extended thread, more data, up to 5 hashtags
   - Format: breakout/new call → Format 4 | stat/data → Format 1 | theme → Format 3 | opinion → Format 5

4. **Set trigger condition:** "Post immediately" / "Post when T1 ₹X hit" / "Post when weekly close above ₹X"

5. **Save to Supabase**
```sql
INSERT INTO posts (ticker, post_type, thread_type, content, free_version, premium_version,
  status, trigger_condition, topic_tags, notes, posted_cmp, created_at)
VALUES ('[ticker]','[post_type]','[thread_type]','[premium]','[free]','[premium]',
  'draft','[trigger]',ARRAY['[tag1]','[tag2]'],'[notes]',[cmp],NOW());
```

---

## C2 — FOLLOW-UP POST
Triggers: "follow-up post for [TICKER]", "post [TICKER] update", "[TICKER] T1 hit — write follow-up"

1. Fetch original post chain:
```sql
SELECT id, ticker, content, free_version, posted_cmp, posted_at, post_type, follow_up_number
FROM posts WHERE ticker='[TICKER]' ORDER BY created_at ASC;
```

2. Fetch live CMP. Calculate: called at ₹[X] → now ₹[X] → +/-X% in N days.

3. Write follow-up structure:
```
[What happened since call — 1 line]
Called [TICKER] at ₹[posted_cmp] on [date]. Now ₹[cmp] — [+/-X%] in [N] days.
[Thesis status: intact / evolving / at risk]
[Next level to watch]
[One new data point]
[CTA] #tag #tag
```

4. Save with original_post_id link:
```sql
INSERT INTO posts (ticker, post_type, content, free_version, premium_version, status,
  trigger_condition, original_post_id, follow_up_number, posted_cmp, notes, created_at)
VALUES ('[ticker]','follow_up','[premium]','[free]','[premium]','draft',
  '[trigger]','[original_uuid]',[follow_up_n+1],[cmp],'[notes]',NOW());
```

---

## C3 — FINALIZE & MARK POSTED
Triggers: "post this now", "mark [TICKER] as posted", "I just posted [TICKER]", "finalize [TICKER] draft"

1. Fetch drafts: `SELECT id, ticker, free_version, premium_version, trigger_condition, posted_cmp FROM posts WHERE ticker='[TICKER]' AND status IN ('draft','ready') ORDER BY created_at DESC LIMIT 3;`
2. If posted_cmp > 2 days old → refresh numbers via INDmoney.
3. Show clean plain text (no markdown) ready to copy-paste into X.
4. On confirm: `UPDATE posts SET status='posted', posted_at=NOW(), posted_cmp=[cmp] WHERE id='[id]';`

---

## C4 — CONTENT QUEUE
Triggers: "pending posts", "check my drafts", "content queue", "what should I post today"

```sql
SELECT ticker, post_type, follow_up_number, trigger_condition, posted_cmp, created_at, status, notes
FROM posts WHERE status IN ('draft','ready') ORDER BY created_at DESC;
```

Display as:
```
📬 CONTENT QUEUE — [N] pending
READY TO POST      : [TICKER] — [type] | Trigger: [condition]
WAITING ON TRIGGER : [TICKER] — [type] | Waiting: [condition]
IDEAS / DRAFTS     : [TICKER] — [type] | Saved: [X days ago]
```
Flag any draft older than 14 days as stale.

---

## C5 — LOG PERFORMANCE
Triggers: "log post performance", "[TICKER] post got X likes", "post performance update"

```sql
UPDATE posts SET likes=[N], retweets=[N], impressions=[N], replies=[N],
  performance_score=[likes + retweets*3 + replies*2],
  why_it_worked='[observation]'
WHERE ticker='[TICKER]' AND status='posted' ORDER BY posted_at DESC LIMIT 1;
```

When 5+ posts logged, show: `SELECT post_type, AVG(performance_score), COUNT(*) FROM posts WHERE status='posted' AND performance_score IS NOT NULL GROUP BY post_type ORDER BY avg DESC;`

---

## C6 — POST HISTORY FOR TICKER
Triggers: "show all posts for [TICKER]", "[TICKER] post history"

```sql
SELECT post_type, follow_up_number, status, posted_cmp, posted_at, likes, impressions, content
FROM posts WHERE ticker='[TICKER]' ORDER BY created_at ASC;
```

---

## @equityos1 Brand Rules
- Voice: data-driven, punchy, numbers first, no fluff, no corporate speak
- Always show SL and risk — accountability builds trust
- Disclaimer on every trade post: "Not SEBI registered. Not investment advice. My own trades. DYOR."
- Hashtags: max 3 standalone / 5 thread | #NSE #SwingTrading #StockMarket #Darvas #Multibagger
- Best times: 8–9 AM IST | 3:30–4 PM IST | 9–10 PM IST
- Never repeat: check duplicates before writing
- Every trade call deserves at least one follow-up (T1/SL hit or 30-day update)
