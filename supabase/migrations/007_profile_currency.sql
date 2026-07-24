alter table public.profiles
  add column if not exists currency_code text not null default 'ARS'
  check (currency_code in ('ARS','BOB','BRL','CLP','COP','GYD','PYG','PEN','SRD','UYU','VES','USD','EUR','TRY'));
