
-- SCHEMA: DV Photo App

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  locale text default 'en',
  role text default 'user', -- 'user' | 'admin' | 'staff'
  created_at timestamptz default now()
);

create table if not exists photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  original_url text,
  processed_url text,
  head_percent numeric,
  eye_y integer,
  width integer,
  height integer,
  file_kb integer,
  pass boolean,
  created_at timestamptz default now()
);

create table if not exists dv_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  email text,
  kebele text,
  note text,
  consent boolean default false,
  created_at timestamptz default now()
);

create type order_status as enum ('draft','queued','in_review','submitted','delivered');

create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  dv_profile_id uuid references dv_profiles(id) on delete set null,
  status order_status default 'queued',
  price_cents integer default 0,
  currency text default 'ETB',
  created_at timestamptz default now()
);

create type payment_status as enum ('pending','paid','failed','refunded');

create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id) on delete cascade,
  provider text, -- 'stripe' | 'telebirr'
  provider_ref text, -- session_id / tx_ref
  amount_cents integer,
  currency text,
  status payment_status default 'pending',
  payload jsonb,
  created_at timestamptz default now()
);

create table if not exists deliverables (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id) on delete cascade,
  confirmation_code text,
  attachments jsonb, -- array of storage URLs
  created_at timestamptz default now()
);

create table if not exists audit_logs (
  id bigint generated always as identity primary key,
  actor uuid references auth.users(id),
  action text,
  entity text,
  entity_id text,
  created_at timestamptz default now()
);
