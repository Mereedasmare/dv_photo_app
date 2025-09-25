
-- Enable RLS
alter table profiles enable row level security;
alter table photos enable row level security;
alter table dv_profiles enable row level security;
alter table orders enable row level security;
alter table payments enable row level security;
alter table deliverables enable row level security;
alter table audit_logs enable row level security;

-- Profiles
create policy "profiles self" on profiles
for select using (auth.uid() = id);
create policy "profiles insert self" on profiles
for insert with check (auth.uid() = id);
create policy "profiles update self" on profiles
for update using (auth.uid() = id);

-- Admin role helper
create or replace function is_admin(uid uuid)
returns boolean language sql stable as $$
  select exists(select 1 from profiles p where p.id = uid and p.role in ('admin','staff'));
$$;

-- Photos
create policy "photos own" on photos
for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- DV profiles
create policy "dv_profiles own" on dv_profiles
for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Orders: user can see own; admin/staff can see all
create policy "orders own read" on orders
for select using (user_id = auth.uid() or is_admin(auth.uid()));
create policy "orders own write" on orders
for insert with check (user_id = auth.uid());
create policy "orders update staff" on orders
for update using (is_admin(auth.uid()));

-- Payments: admin/staff only
create policy "payments admin read" on payments
for select using (is_admin(auth.uid()));
create policy "payments admin write" on payments
for all using (is_admin(auth.uid())) with check (is_admin(auth.uid()));

-- Deliverables
create policy "deliverables read" on deliverables
for select using (
  is_admin(auth.uid()) or exists (
    select 1 from orders o where o.id = order_id and o.user_id = auth.uid()
  )
);
create policy "deliverables write staff" on deliverables
for all using (is_admin(auth.uid())) with check (is_admin(auth.uid()));

-- Audit logs: staff only
create policy "audit read staff" on audit_logs
for select using (is_admin(auth.uid()));
create policy "audit write staff" on audit_logs
for insert with check (is_admin(auth.uid()));
