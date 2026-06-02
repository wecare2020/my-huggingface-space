create extension if not exists pgcrypto;

create table if not exists public.app_modules (
  id uuid primary key default gen_random_uuid(),
  module_key text not null unique,
  name text not null,
  description text,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.app_processes (
  id uuid primary key default gen_random_uuid(),
  module_id uuid references public.app_modules(id) on delete set null,
  process_key text not null unique,
  name text not null,
  description text,
  objective text,
  owner text,
  source_sheet_url text,
  source_script_url text,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.app_nav_items (
  id uuid primary key default gen_random_uuid(),
  process_id uuid references public.app_processes(id) on delete cascade,
  nav_id text not null,
  label text not null,
  mode text not null check (mode in ('user','config')),
  nav_group text,
  sort_order integer not null default 0,
  icon text,
  unique (process_id, mode, nav_id)
);

create table if not exists public.app_tables (
  id uuid primary key default gen_random_uuid(),
  process_id uuid references public.app_processes(id) on delete cascade,
  table_key text not null,
  table_name text not null,
  table_group text,
  data_type text not null default 'operation',
  sheet_name text,
  screen_view text,
  summary text,
  unique (process_id, table_key)
);

create table if not exists public.app_fields (
  id uuid primary key default gen_random_uuid(),
  table_id uuid references public.app_tables(id) on delete cascade,
  field_key text not null,
  label text not null,
  field_type text not null default 'text',
  required boolean not null default false,
  options jsonb not null default '[]'::jsonb,
  sort_order integer not null default 0,
  unique (table_id, field_key)
);

create table if not exists public.item_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  parent_name text,
  material_group text,
  status text not null default 'active'
);

create table if not exists public.item_master (
  id uuid primary key default gen_random_uuid(),
  item_code text unique,
  item_name text not null,
  item_category_id uuid references public.item_categories(id),
  standard_uom text,
  photo_url text,
  classification text,
  status text not null default 'active',
  owner text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.unit_conversions (
  id uuid primary key default gen_random_uuid(),
  item_id uuid references public.item_master(id) on delete cascade,
  from_uom text not null,
  to_uom text not null,
  conversion_rate numeric(18,6) not null check (conversion_rate > 0),
  usage_purpose text,
  status text not null default 'active',
  notes text
);

create table if not exists public.product_developments (
  id uuid primary key default gen_random_uuid(),
  project_code text not null unique,
  product_name text not null,
  customer_name text,
  stage text not null,
  owner text,
  priority text,
  due_date date,
  status text not null default 'active'
);

create table if not exists public.sample_requests (
  id uuid primary key default gen_random_uuid(),
  product_development_id uuid references public.product_developments(id) on delete cascade,
  sample_round text,
  request_detail text,
  qc_status text,
  owner text,
  due_date date
);

create table if not exists public.bom_drafts (
  id uuid primary key default gen_random_uuid(),
  product_development_id uuid references public.product_developments(id) on delete cascade,
  item_id uuid references public.item_master(id),
  qty numeric(14,4),
  uom text,
  cost_note text
);

create table if not exists public.trial_logs (
  id uuid primary key default gen_random_uuid(),
  product_development_id uuid references public.product_developments(id) on delete cascade,
  trial_date date,
  result text,
  issue text,
  next_action text,
  owner text
);

create table if not exists public.crm_accounts (
  id uuid primary key default gen_random_uuid(),
  account_name text not null,
  region text,
  segment text,
  owner text,
  status text not null default 'active'
);

create table if not exists public.crm_contacts (
  id uuid primary key default gen_random_uuid(),
  account_id uuid references public.crm_accounts(id) on delete cascade,
  full_name text not null,
  email text,
  role text,
  status text not null default 'active'
);

create table if not exists public.crm_opportunities (
  id uuid primary key default gen_random_uuid(),
  account_id uuid references public.crm_accounts(id) on delete cascade,
  opportunity_code text not null unique,
  stage text not null,
  quote_value numeric(14,2),
  next_action text,
  due_date date,
  owner text
);

create table if not exists public.crm_activities (
  id uuid primary key default gen_random_uuid(),
  opportunity_id uuid references public.crm_opportunities(id) on delete cascade,
  activity_type text not null,
  detail text,
  due_date date,
  owner text,
  status text not null default 'open'
);

create index if not exists idx_app_processes_module on public.app_processes(module_id,status);
create index if not exists idx_app_nav_process_mode on public.app_nav_items(process_id,mode,sort_order);
create index if not exists idx_item_master_name on public.item_master using gin (to_tsvector('simple', item_name));
create index if not exists idx_product_developments_stage on public.product_developments(stage);
create index if not exists idx_crm_opportunities_stage on public.crm_opportunities(stage);

alter table public.app_modules enable row level security;
alter table public.app_processes enable row level security;
alter table public.app_nav_items enable row level security;
alter table public.app_tables enable row level security;
alter table public.app_fields enable row level security;
alter table public.item_categories enable row level security;
alter table public.item_master enable row level security;
alter table public.unit_conversions enable row level security;
alter table public.product_developments enable row level security;
alter table public.sample_requests enable row level security;
alter table public.bom_drafts enable row level security;
alter table public.trial_logs enable row level security;
alter table public.crm_accounts enable row level security;
alter table public.crm_contacts enable row level security;
alter table public.crm_opportunities enable row level security;
alter table public.crm_activities enable row level security;

insert into public.app_modules (module_key,name,description)
values ('process_os','Process OS','Module hub holding Item Master, Product Development, CRM and future process apps')
on conflict (module_key) do update set name=excluded.name, description=excluded.description, updated_at=now();
