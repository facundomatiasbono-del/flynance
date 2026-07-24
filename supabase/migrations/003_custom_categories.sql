create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 40),
  created_at timestamptz not null default now()
);

create unique index if not exists categories_user_name_unique
  on public.categories (user_id, lower(name));

alter table public.categories enable row level security;

create policy "categories_select_own" on public.categories for select using (auth.uid() = user_id);
create policy "categories_insert_own" on public.categories for insert with check (auth.uid() = user_id);
create policy "categories_update_own" on public.categories for update using (auth.uid() = user_id);
create policy "categories_delete_own" on public.categories for delete using (auth.uid() = user_id);

grant select, insert, update, delete on public.categories to authenticated;

insert into public.categories (user_id, name)
select profiles.id, defaults.name
from public.profiles
cross join unnest(array['Comida','Transporte','Supermercado','Servicios','Salud','Ocio','Otros']) as defaults(name)
on conflict do nothing;

create or replace function public.create_profile_for_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');

  insert into public.categories (user_id, name)
  select new.id, name
  from unnest(array['Comida','Transporte','Supermercado','Servicios','Salud','Ocio','Otros']) as defaults(name);

  return new;
end;
$$;
