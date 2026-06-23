-- ═══════════════════════════════════════════════════════════
-- INDOOR DISTANCE STAFF APP — Supabase Schema
-- Kör detta i Supabase Dashboard → SQL Editor → New query → Run
-- ═══════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────
-- 1. STAFF ACCOUNTS — Inloggning + godkännande-flöde
-- ─────────────────────────────────────────────────────────────
create table if not exists public.staff_accounts (
  id           uuid primary key default gen_random_uuid(),
  email        text unique not null,
  name         text not null,
  role         text not null default 'support',  -- admin | support | social | content | dev | other
  pw_hash      text,                              -- SHA-256 hash från klient (eller __google_only__)
  approved     boolean not null default false,
  reason       text,                              -- varför de begär åtkomst
  created_at   timestamptz not null default now(),
  approved_at  timestamptz,
  last_login   timestamptz
);

create index if not exists staff_accounts_email_idx on public.staff_accounts(lower(email));
create index if not exists staff_accounts_approved_idx on public.staff_accounts(approved);

-- ─────────────────────────────────────────────────────────────
-- 2. PRODUCTS — Lager + produktkatalog
-- ─────────────────────────────────────────────────────────────
create table if not exists public.products (
  id           text primary key,                  -- t.ex. "hoodie-grey"
  name         text not null,
  category     text,                              -- "hoodie" | "t-shirt" | "cap" osv.
  price        integer not null default 0,        -- pris i SEK
  icon         text,                              -- emoji eller URL
  stock        jsonb default '{}'::jsonb,         -- { "S": 10, "M": 15, "L": 8 }
  image_url    text,
  active       boolean not null default true,
  created_at   timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────
-- 3. ORDERS — Beställningar
-- ─────────────────────────────────────────────────────────────
create table if not exists public.orders (
  id              uuid primary key default gen_random_uuid(),
  order_number    text unique,
  customer_name   text,
  customer_email  text not null,
  customer_phone  text,
  shipping_addr   jsonb,
  items           jsonb not null default '[]'::jsonb,   -- [{product_id, size, qty, price}]
  total           integer not null,                       -- SEK
  discount_code   text,
  payment_method  text,                                   -- "stripe" | "swish" | "klarna"
  payment_ref     text,                                   -- Stripe payment intent id
  status          text not null default 'pending',        -- pending|paid|processing|shipped|delivered|cancelled
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists orders_email_idx on public.orders(customer_email);
create index if not exists orders_status_idx on public.orders(status);
create index if not exists orders_created_idx on public.orders(created_at desc);

-- ─────────────────────────────────────────────────────────────
-- 4. NEWSLETTER SUBSCRIBERS — Waitlist + nyhetsbrev
-- ─────────────────────────────────────────────────────────────
create table if not exists public.newsletter_subscribers (
  id            uuid primary key default gen_random_uuid(),
  email         text unique not null,
  name          text,
  source        text default 'website',          -- "website" | "manual" | "import"
  language      text default 'sv',
  consent_at    timestamptz not null default now(),
  unsubscribed  boolean not null default false,
  created_at    timestamptz not null default now()
);

create index if not exists newsletter_email_idx on public.newsletter_subscribers(lower(email));

-- ─────────────────────────────────────────────────────────────
-- 5. DISCOUNT CODES — Rabattkoder
-- ─────────────────────────────────────────────────────────────
create table if not exists public.discount_codes (
  code         text primary key,
  discount     integer not null,                  -- procent (1-100)
  description  text,
  valid_until  date,
  max_uses     integer default 999999,
  used         integer not null default 0,
  active       boolean not null default true,
  created_at   timestamptz not null default now()
);

-- ─────────────────────────────────────────────────────────────
-- 6. STAFF ACTIVITY LOG — Vem gjorde vad
-- ─────────────────────────────────────────────────────────────
create table if not exists public.staff_activity (
  id           uuid primary key default gen_random_uuid(),
  staff_email  text not null,
  action       text not null,                     -- "approved_user" | "deleted_order" | "added_product" etc.
  target       text,                              -- target id/email/etc
  details      jsonb,
  created_at   timestamptz not null default now()
);

create index if not exists staff_activity_email_idx on public.staff_activity(staff_email);
create index if not exists staff_activity_created_idx on public.staff_activity(created_at desc);

-- ═══════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS)
-- VIKTIGT: Skydda data så bara godkänd staff kan läsa/skriva
-- ═══════════════════════════════════════════════════════════

-- Slå PÅ RLS för alla tabeller
alter table public.staff_accounts        enable row level security;
alter table public.products              enable row level security;
alter table public.orders                enable row level security;
alter table public.newsletter_subscribers enable row level security;
alter table public.discount_codes        enable row level security;
alter table public.staff_activity        enable row level security;

-- ─── staff_accounts ───
-- Alla får läsa (för login-check) — pw_hash exponeras men är SHA-256 (icke-reverserbar)
create policy "Public read staff_accounts" on public.staff_accounts
  for select using (true);

-- Bara godkänd admin kan ändra
create policy "Admin can manage staff_accounts" on public.staff_accounts
  for all using (
    exists (
      select 1 from public.staff_accounts s
      where lower(s.email) = lower(auth.jwt() ->> 'email')
        and s.role = 'admin'
        and s.approved = true
    )
  );

-- Anyone kan skapa pending-request (insert med approved=false)
create policy "Anyone can request access" on public.staff_accounts
  for insert with check (approved = false);

-- ─── products ───
create policy "Public read active products" on public.products
  for select using (active = true);

create policy "Staff can manage products" on public.products
  for all using (
    exists (
      select 1 from public.staff_accounts s
      where lower(s.email) = lower(auth.jwt() ->> 'email')
        and s.approved = true
    )
  );

-- ─── orders ───
create policy "Staff can read all orders" on public.orders
  for select using (
    exists (
      select 1 from public.staff_accounts s
      where lower(s.email) = lower(auth.jwt() ->> 'email')
        and s.approved = true
    )
  );

create policy "Anyone can create order" on public.orders
  for insert with check (true);

create policy "Staff can update orders" on public.orders
  for update using (
    exists (
      select 1 from public.staff_accounts s
      where lower(s.email) = lower(auth.jwt() ->> 'email')
        and s.approved = true
    )
  );

-- ─── newsletter_subscribers ───
create policy "Anyone can subscribe" on public.newsletter_subscribers
  for insert with check (true);

create policy "Staff can read subscribers" on public.newsletter_subscribers
  for select using (
    exists (
      select 1 from public.staff_accounts s
      where lower(s.email) = lower(auth.jwt() ->> 'email')
        and s.approved = true
    )
  );

-- ─── discount_codes ───
create policy "Public read active codes" on public.discount_codes
  for select using (active = true);

create policy "Staff can manage codes" on public.discount_codes
  for all using (
    exists (
      select 1 from public.staff_accounts s
      where lower(s.email) = lower(auth.jwt() ->> 'email')
        and s.approved = true
    )
  );

-- ─── staff_activity ───
create policy "Staff can read activity" on public.staff_activity
  for select using (
    exists (
      select 1 from public.staff_accounts s
      where lower(s.email) = lower(auth.jwt() ->> 'email')
        and s.approved = true
    )
  );

create policy "Staff can log own activity" on public.staff_activity
  for insert with check (
    lower(staff_email) = lower(auth.jwt() ->> 'email')
  );

-- ═══════════════════════════════════════════════════════════
-- BOOTSTRAP — Lägg in VD som första admin
-- ═══════════════════════════════════════════════════════════
insert into public.staff_accounts (email, name, role, approved, pw_hash)
values ('indoor.distance.vd@gmail.com', 'VD', 'admin', true, '__google_only__')
on conflict (email) do nothing;

-- ═══════════════════════════════════════════════════════════
-- KLAR! Verifiera med:
--   select * from staff_accounts;
--   select * from products;
-- ═══════════════════════════════════════════════════════════
