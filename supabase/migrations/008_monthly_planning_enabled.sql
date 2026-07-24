alter table public.profiles
  add column if not exists monthly_planning_enabled boolean not null default false;
