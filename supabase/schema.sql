create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  customer text not null,
  product text not null,
  quantity integer not null default 0 check (quantity >= 0),
  deadline date,
  owner text,
  stage text not null check (stage in ('Báo giá', 'Đã duyệt', 'Đang sản xuất', 'QC', 'Giao hàng')),
  status text not null check (status in ('Đúng tiến độ', 'Cần xử lý', 'Trễ hạn', 'Chờ vật tư')),
  priority text not null check (priority in ('Thấp', 'Vừa', 'Cao')),
  value numeric(14, 0) not null default 0 check (value >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.production_jobs (
  id uuid primary key default gen_random_uuid(),
  machine text not null,
  job text not null,
  progress integer not null default 0 check (progress between 0 and 100),
  shift text not null,
  issue text,
  created_at timestamptz not null default now()
);

create table if not exists public.purchase_requests (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  item text not null,
  requester text,
  eta date,
  status text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.stock_alerts (
  id uuid primary key default gen_random_uuid(),
  item text not null,
  on_hand integer not null default 0,
  min integer not null default 0,
  unit text not null,
  status text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.qc_checks (
  id uuid primary key default gen_random_uuid(),
  lot text not null,
  sample text not null,
  result text not null,
  inspector text,
  created_at timestamptz not null default now()
);

create table if not exists public.maintenance_tickets (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  asset text not null,
  due date,
  status text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_orders_stage on public.orders (stage);
create index if not exists idx_orders_status on public.orders (status);
create index if not exists idx_orders_deadline on public.orders (deadline);
create index if not exists idx_production_jobs_shift on public.production_jobs (shift);

alter table public.orders enable row level security;
alter table public.production_jobs enable row level security;
alter table public.purchase_requests enable row level security;
alter table public.stock_alerts enable row level security;
alter table public.qc_checks enable row level security;
alter table public.maintenance_tickets enable row level security;

create policy "authenticated users can read orders" on public.orders for select to authenticated using (true);
create policy "authenticated users can manage orders" on public.orders for all to authenticated using (true) with check (true);
create policy "authenticated users can read production jobs" on public.production_jobs for select to authenticated using (true);
create policy "authenticated users can manage production jobs" on public.production_jobs for all to authenticated using (true) with check (true);
create policy "authenticated users can read purchase requests" on public.purchase_requests for select to authenticated using (true);
create policy "authenticated users can manage purchase requests" on public.purchase_requests for all to authenticated using (true) with check (true);
create policy "authenticated users can read stock alerts" on public.stock_alerts for select to authenticated using (true);
create policy "authenticated users can manage stock alerts" on public.stock_alerts for all to authenticated using (true) with check (true);
create policy "authenticated users can read qc checks" on public.qc_checks for select to authenticated using (true);
create policy "authenticated users can manage qc checks" on public.qc_checks for all to authenticated using (true) with check (true);
create policy "authenticated users can read maintenance tickets" on public.maintenance_tickets for select to authenticated using (true);
create policy "authenticated users can manage maintenance tickets" on public.maintenance_tickets for all to authenticated using (true) with check (true);
