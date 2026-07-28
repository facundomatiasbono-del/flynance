alter table public.expenses
  add column if not exists excluded_from_totals boolean not null default false;
