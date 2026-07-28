alter table public.profiles
  add column if not exists budget_period text not null default 'monthly'
  check (budget_period in ('weekly', 'monthly', 'quarterly'));

create table if not exists public.category_budgets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  category text not null,
  amount numeric not null check (amount > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, category)
);

alter table public.category_budgets enable row level security;

create policy "category_budgets_select_own" on public.category_budgets for select using (auth.uid() = user_id);
create policy "category_budgets_insert_own" on public.category_budgets for insert with check (auth.uid() = user_id);
create policy "category_budgets_update_own" on public.category_budgets for update using (auth.uid() = user_id);
create policy "category_budgets_delete_own" on public.category_budgets for delete using (auth.uid() = user_id);

grant select, insert, update, delete on public.category_budgets to authenticated;
