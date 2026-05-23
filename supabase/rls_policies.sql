-- Políticas para GastoSmart con login custom (rol anon).
-- Ejecutar en Supabase → SQL Editor si las operaciones fallan por RLS.

alter table public.cuentas enable row level security;
alter table public.movimientos enable row level security;
alter table public.categorias enable row level security;
alter table public.historial enable row level security;
alter table public.detalle_historial enable row level security;
alter table public.config_sistema enable row level security;
alter table public.onboarding enable row level security;

-- cuentas
drop policy if exists "anon_cuentas_all" on public.cuentas;
create policy "anon_cuentas_all" on public.cuentas
  for all to anon using (true) with check (true);

-- movimientos
drop policy if exists "anon_movimientos_all" on public.movimientos;
create policy "anon_movimientos_all" on public.movimientos
  for all to anon using (true) with check (true);

-- categorias
drop policy if exists "anon_categorias_all" on public.categorias;
create policy "anon_categorias_all" on public.categorias
  for all to anon using (true) with check (true);

-- historial
drop policy if exists "anon_historial_all" on public.historial;
create policy "anon_historial_all" on public.historial
  for all to anon using (true) with check (true);

-- detalle_historial
drop policy if exists "anon_detalle_historial_all" on public.detalle_historial;
create policy "anon_detalle_historial_all" on public.detalle_historial
  for all to anon using (true) with check (true);

-- config_sistema
drop policy if exists "anon_config_sistema_all" on public.config_sistema;
create policy "anon_config_sistema_all" on public.config_sistema
  for all to anon using (true) with check (true);

-- onboarding
drop policy if exists "anon_onboarding_all" on public.onboarding;
create policy "anon_onboarding_all" on public.onboarding
  for all to anon using (true) with check (true);

alter table public.presupuestos enable row level security;
alter table public.metas_ahorro enable row level security;
alter table public.reportes_personales enable row level security;

drop policy if exists "anon_presupuestos_all" on public.presupuestos;
create policy "anon_presupuestos_all" on public.presupuestos
  for all to anon using (true) with check (true);

drop policy if exists "anon_metas_ahorro_all" on public.metas_ahorro;
create policy "anon_metas_ahorro_all" on public.metas_ahorro
  for all to anon using (true) with check (true);

drop policy if exists "anon_reportes_personales_all" on public.reportes_personales;
create policy "anon_reportes_personales_all" on public.reportes_personales
  for all to anon using (true) with check (true);
