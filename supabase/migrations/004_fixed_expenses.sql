create table if not exists public.fixed_expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 60),
  amount numeric(12,2) not null check (amount > 0),
  due_day smallint check (due_day is null or due_day between 1 and 31),
  created_at timestamptz not null default now()
);

alter table public.fixed_expenses enable row level security;

create policy "fixed_expenses_select_own" on public.fixed_expenses for select using (auth.uid() = user_id);
create policy "fixed_expenses_insert_own" on public.fixed_expenses for insert with check (auth.uid() = user_id);
create policy "fixed_expenses_update_own" on public.fixed_expenses for update using (auth.uid() = user_id);
create policy "fixed_expenses_delete_own" on public.fixed_expenses for delete using (auth.uid() = user_id);

grant select, insert, update, delete on public.fixed_expenses to authenticated;
