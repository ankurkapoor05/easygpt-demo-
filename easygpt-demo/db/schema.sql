-- Enable UUIDs
create extension if not exists "uuid-ossp";

-- 1) Core org structure
create table if not exists restaurants (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  timezone text not null default 'America/Chicago',
  currency text not null default 'USD',
  created_at timestamptz not null default now()
);

create table if not exists locations (
  id uuid primary key default uuid_generate_v4(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  name text not null,
  address text,
  created_at timestamptz not null default now(),
  unique (restaurant_id, name)
);

-- 2) Platforms & accounts (Square / DoorDash / Uber Eats)
create type platform_name as enum ('square', 'doordash', 'ubereats');

create table if not exists platform_accounts (
  id uuid primary key default uuid_generate_v4(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  platform platform_name not null,
  account_label text, -- e.g. "Main DoorDash store"
  access_token text,  -- for demo; later encrypt or store in vault
  refresh_token text,
  token_expires_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (restaurant_id, platform, account_label)
);

create index if not exists idx_platform_accounts_restaurant on platform_accounts(restaurant_id);

-- 3) External location mapping (vendor location/store IDs)
create table if not exists platform_locations (
  id uuid primary key default uuid_generate_v4(),
  location_id uuid not null references locations(id) on delete cascade,
  platform platform_name not null,
  platform_location_id text not null, -- vendor's location/store id
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (location_id, platform, platform_location_id)
);

create index if not exists idx_platform_locations_location on platform_locations(location_id);

-- 4) Canonical menu items
create table if not exists items (
  id uuid primary key default uuid_generate_v4(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  name text not null,
  category text,
  sku text,
  base_price_cents integer,         -- optional
  estimated_cost_cents integer,     -- optional (for demo, can be set)
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (restaurant_id, name)
);

create index if not exists idx_items_restaurant on items(restaurant_id);

-- 5) Platform-specific menu mapping (the GOLD table)
create table if not exists platform_items (
  id uuid primary key default uuid_generate_v4(),
  item_id uuid not null references items(id) on delete cascade,
  platform platform_name not null,
  platform_item_id text not null,    -- vendor item id
  price_cents integer,               -- current price on that platform
  is_available boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (platform, platform_item_id),
  unique (item_id, platform)
);

create index if not exists idx_platform_items_item on platform_items(item_id);

-- 6) Orders (canonical)
create type order_channel as enum ('dine_in', 'pickup', 'delivery', 'other');

create table if not exists orders (
  id uuid primary key default uuid_generate_v4(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  location_id uuid references locations(id) on delete set null,

  platform platform_name not null,      -- where it originated
  platform_order_id text not null,      -- vendor order id

  channel order_channel not null default 'other',
  ordered_at timestamptz not null,

  subtotal_cents integer not null default 0,
  tax_cents integer not null default 0,
  tip_cents integer not null default 0,
  discounts_cents integer not null default 0,

  fees_cents integer not null default 0,        -- delivery/service fees if present
  commission_cents integer not null default 0,  -- key for DoorDash/Uber (if available)

  total_cents integer not null default 0,
  net_revenue_cents integer not null default 0, -- total - discounts - commission - fees (your definition; keep consistent)

  status text,
  metadata jsonb not null default '{}'::jsonb,

  created_at timestamptz not null default now(),
  unique (platform, platform_order_id)
);

create index if not exists idx_orders_restaurant_time on orders(restaurant_id, ordered_at);
create index if not exists idx_orders_platform_time on orders(platform, ordered_at);

-- 7) Order line items
create table if not exists order_items (
  id uuid primary key default uuid_generate_v4(),
  order_id uuid not null references orders(id) on delete cascade,
  item_id uuid references items(id) on delete set null,

  platform_item_id text, -- capture raw in case mapping fails initially
  name text not null,    -- vendor line item name (for debugging)
  quantity integer not null default 1,
  unit_price_cents integer not null default 0,
  line_total_cents integer not null default 0,
  metadata jsonb not null default '{}'::jsonb,

  created_at timestamptz not null default now()
);

create index if not exists idx_order_items_order on order_items(order_id);
create index if not exists idx_order_items_item on order_items(item_id);

-- 8) Metrics cache (fast insights for demo)
create table if not exists metrics_daily (
  id uuid primary key default uuid_generate_v4(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  location_id uuid references locations(id) on delete set null,
  platform platform_name,
  day date not null,

  orders_count integer not null default 0,
  gross_sales_cents integer not null default 0,
  discounts_cents integer not null default 0,
  commission_cents integer not null default 0,
  fees_cents integer not null default 0,
  estimated_cogs_cents integer not null default 0,
  net_profit_cents integer not null default 0,

  created_at timestamptz not null default now(),
  unique (restaurant_id, location_id, platform, day)
);

create index if not exists idx_metrics_daily_restaurant_day on metrics_daily(restaurant_id, day);

create table if not exists item_metrics_daily (
  id uuid primary key default uuid_generate_v4(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  location_id uuid references locations(id) on delete set null,
  platform platform_name,
  day date not null,

  item_id uuid not null references items(id) on delete cascade,
  units_sold integer not null default 0,
  revenue_cents integer not null default 0,
  estimated_cogs_cents integer not null default 0,
  net_profit_cents integer not null default 0,

  created_at timestamptz not null default now(),
  unique (restaurant_id, location_id, platform, item_id, day)
);

create index if not exists idx_item_metrics_daily_item_day on item_metrics_daily(item_id, day);

-- 9) Actions (for Step 8 demo: propose/apply changes)
create type change_type as enum ('price_update', 'availability_update');

create table if not exists proposed_changes (
  id uuid primary key default uuid_generate_v4(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  location_id uuid references locations(id) on delete set null,

  platform platform_name not null,
  change_type change_type not null,

  item_id uuid references items(id) on delete set null,
  platform_item_id text,

  old_value jsonb,
  new_value jsonb not null,

  status text not null default 'proposed', -- proposed | queued | applied | failed | reverted
  requested_by text, -- demo: email/username string
  requested_at timestamptz not null default now(),
  applied_at timestamptz
);

create index if not exists idx_changes_restaurant_time on proposed_changes(restaurant_id, requested_at);

-- 10) Audit log (trust builder)
create table if not exists audit_log (
  id uuid primary key default uuid_generate_v4(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  location_id uuid references locations(id) on delete set null,
  actor text not null, -- "ankur" / "owner@..."
  action text not null,
  entity_type text, -- order/item/menu/change
  entity_id text,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_audit_restaurant_time on audit_log(restaurant_id, created_at);
