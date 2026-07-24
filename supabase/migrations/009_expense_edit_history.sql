alter table public.expenses
  add column if not exists edited_at timestamptz,
  add column if not exists previous_amount numeric(12,2),
  add column if not exists previous_category text,
  add column if not exists previous_description text;

comment on column public.expenses.edited_at is 'Fecha de la edición más reciente';
comment on column public.expenses.previous_amount is 'Importe inmediatamente anterior';
comment on column public.expenses.previous_category is 'Categoría inmediatamente anterior';
comment on column public.expenses.previous_description is 'Detalle inmediatamente anterior';
