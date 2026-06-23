-- ============================================================
-- Trading Ops Manager — Supabase Setup
-- Run this entire file in your Supabase SQL Editor once.
-- Creates all 5 tables needed for the skill.
-- ============================================================

-- 1. OPEN TRADES — active real positions
CREATE TABLE IF NOT EXISTS public.open_trades (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamp DEFAULT now(),
  stock text NOT NULL,
  symbol text NOT NULL,
  entry_date date,
  qty integer,
  entry_price numeric,
  cmp numeric,
  stop_loss numeric,
  t1 numeric,
  t2 numeric,
  t3 text,
  invested numeric,
  risk numeric,
  unrealised_pnl numeric,
  pnl_pct numeric,
  rr_t1 text,
  rr_t2 text,
  notes text,
  thesis_invalidation text,
  exit_plan text,
  grade text,
  status text DEFAULT 'OPEN',
  eod_confirmed boolean DEFAULT false,
  last_price_check timestamptz
);

-- 2. CLOSED TRADES — all exits (partial + full), one row per exit event
CREATE TABLE IF NOT EXISTS public.closed_trades (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamp DEFAULT now(),
  stock text NOT NULL,
  symbol text NOT NULL,
  entry_date date,
  exit_date date,
  qty_sold integer,
  entry_price numeric,
  exit_price numeric,
  pnl numeric,
  pnl_pct numeric,
  reason text,
  notes text,
  lesson text,
  emotional_state text,
  trade_no integer
);

-- 3. FRONTTEST — paper trade ideas only, never mixed with real trades
CREATE TABLE IF NOT EXISTS public.fronttest (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamp DEFAULT now(),
  added_date date DEFAULT CURRENT_DATE,
  stock text NOT NULL,
  symbol text NOT NULL,
  entry_price numeric,
  qty integer DEFAULT 100,
  stop_loss numeric,
  t1 numeric,
  t2 numeric,
  t3 text,
  rr_t1 text,
  rr_t2 text,
  risk_per_share numeric,
  risk_total numeric,
  max_profit numeric,
  theme text,
  source text,
  stage text,
  conviction text,
  thesis text,
  thesis_invalidation text,
  entry_trigger text,
  notes text,
  cmp numeric,
  unrealised_pnl numeric,
  pnl_pct numeric,
  last_price_check timestamptz,
  status text DEFAULT 'WATCHING',
  grade text,
  trigger_fired boolean DEFAULT false,
  invalidated boolean DEFAULT false,
  invalidation_reason text,
  weekly_review_notes text
);

-- 4. POSTS — X content drafts, follow-ups, performance tracking
CREATE TABLE IF NOT EXISTS public.posts (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  ticker text,
  post_type text DEFAULT 'standalone',
  thread_type text,
  content text,
  free_version text,
  premium_version text,
  status text DEFAULT 'draft',
  trigger_condition text,
  topic_tags text[],
  original_post_id uuid REFERENCES public.posts(id),
  follow_up_number integer DEFAULT 0,
  posted_cmp numeric,
  posted_at timestamptz,
  x_post_id text,
  likes integer DEFAULT 0,
  retweets integer DEFAULT 0,
  impressions integer DEFAULT 0,
  replies integer DEFAULT 0,
  performance_score numeric,
  why_it_worked text,
  notes text,
  version_number integer DEFAULT 1
);

-- 5. MISTAKES — rule violations and lessons
CREATE TABLE IF NOT EXISTS public.mistakes (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamp DEFAULT now(),
  date date,
  stock text,
  setup_grade text,
  mistake_type text,
  what_went_wrong text,
  rule_corrective_action text
);

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE public.open_trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.closed_trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fronttest ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mistakes ENABLE ROW LEVEL SECURITY;

-- Allow all operations for authenticated users
CREATE POLICY "Allow all for authenticated" ON public.open_trades FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated" ON public.closed_trades FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated" ON public.fronttest FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated" ON public.posts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated" ON public.mistakes FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- Setup complete. All 5 tables created.
-- Next: copy your Supabase Project ID and paste it into SKILL.md
-- ============================================================
