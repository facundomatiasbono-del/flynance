alter table public.profiles
  add column if not exists monthly_income numeric(12,2),
  add column if not exists spending_alert numeric(12,2);

alter table public.profiles
  drop constraint if exists monthly_income_non_negative,
  drop constraint if exists spending_alert_positive;

alter table public.profiles
  add constraint monthly_income_non_negative check (monthly_income is null or monthly_income >= 0),
  add constraint spending_alert_positive check (spending_alert is null or spending_alert > 0);
