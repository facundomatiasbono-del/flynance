create table if not exists public.expense_keywords (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  category text not null check (char_length(trim(category)) between 1 and 40),
  value text not null check (char_length(trim(value)) between 1 and 50),
  created_at timestamptz not null default now(),
  unique (user_id, category, value)
);

alter table public.expense_keywords enable row level security;
create policy "expense_keywords_select_own" on public.expense_keywords for select using (auth.uid() = user_id);
create policy "expense_keywords_insert_own" on public.expense_keywords for insert with check (auth.uid() = user_id);
create policy "expense_keywords_update_own" on public.expense_keywords for update using (auth.uid() = user_id);
create policy "expense_keywords_delete_own" on public.expense_keywords for delete using (auth.uid() = user_id);
grant select, insert, update, delete on public.expense_keywords to authenticated;
