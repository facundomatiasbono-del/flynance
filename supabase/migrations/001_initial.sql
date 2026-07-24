create extension if not exists "pgcrypto";

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  whatsapp_phone text unique,
  created_at timestamptz not null default now(),
  constraint phone_format check (whatsapp_phone is null or whatsapp_phone ~ '^\+[1-9][0-9]{7,14}$')
);

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  amount numeric(12,2) not null check (amount > 0),
  category text not null default 'Otros',
  description text,
  spent_at timestamptz not null default now(),
  source text not null default 'web' check (source in ('web', 'whatsapp')),
  twilio_message_sid text unique,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.expenses enable row level security;

create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);
create policy "expenses_select_own" on public.expenses for select using (auth.uid() = user_id);
create policy "expenses_insert_own" on public.expenses for insert with check (auth.uid() = user_id);
create policy "expenses_update_own" on public.expenses for update using (auth.uid() = user_id);
create policy "expenses_delete_own" on public.expenses for delete using (auth.uid() = user_id);

create or replace function public.create_profile_for_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');
  return new;
end;
$$;

create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.create_profile_for_user();

create index expenses_user_spent_at_idx on public.expenses(user_id, spent_at desc);

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.expenses to authenticated;
grant select, update on public.profiles to authenticated;
