alter table public.categories
  add column if not exists icon_key text not null default 'tag'
  check (icon_key in ('food','transport','shopping','services','health','leisure','home','education','pets','travel','gifts','clothing','tag'));

update public.categories set icon_key = case name
  when 'Comida' then 'food'
  when 'Transporte' then 'transport'
  when 'Supermercado' then 'shopping'
  when 'Servicios' then 'services'
  when 'Salud' then 'health'
  when 'Ocio' then 'leisure'
  else icon_key
end
where name in ('Comida','Transporte','Supermercado','Servicios','Salud','Ocio')
  and icon_key = 'tag';
