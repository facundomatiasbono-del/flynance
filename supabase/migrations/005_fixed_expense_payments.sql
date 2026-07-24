create table if not exists public.fixed_expense_payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  fixed_expense_id uuid not null references public.fixed_expenses(id) on delete cascade,
  expense_id uuid not null references public.expenses(id) on delete cascade,
  paid_month date not null,
  paid_at timestamptz not null default now(),
  unique (fixed_expense_id, paid_month)
);

alter table public.fixed_expense_payments enable row level security;
create policy "fixed_expense_payments_select_own" on public.fixed_expense_payments for select using (auth.uid() = user_id);
create policy "fixed_expense_payments_insert_own" on public.fixed_expense_payments for insert with check (auth.uid() = user_id);
grant select, insert on public.fixed_expense_payments to authenticated;

create or replace function public.mark_fixed_expense_paid(fixed_id uuid)
returns uuid language plpgsql security invoker set search_path = public as $$
declare
  fixed_record public.fixed_expenses%rowtype;
  new_expense_id uuid;
  month_start date := date_trunc('month', current_date)::date;
begin
  select * into fixed_record from public.fixed_expenses where id = fixed_id and user_id = auth.uid();
  if not found then raise exception 'Fixed expense not found'; end if;
  select expense_id into new_expense_id from public.fixed_expense_payments where fixed_expense_id = fixed_id and paid_month = month_start;
  if found then return new_expense_id; end if;
  insert into public.expenses (user_id, amount, category, description, source)
    values (auth.uid(), fixed_record.amount, 'Servicios', fixed_record.name, 'web') returning id into new_expense_id;
  insert into public.fixed_expense_payments (user_id, fixed_expense_id, expense_id, paid_month)
    values (auth.uid(), fixed_id, new_expense_id, month_start);
  return new_expense_id;
end;
$$;
grant execute on function public.mark_fixed_expense_paid(uuid) to authenticated;
