alter table public.categories
  drop constraint if exists categories_icon_key_check;

alter table public.categories
  add constraint categories_icon_key_check
    check (icon_key in (
      'food','transport','shopping','services','health','leisure','home',
      'education','pets','travel','gifts','clothing','coffee','phone',
      'internet','fitness','baby','work','fuel','music','repairs','money','tag'
    ));

update public.categories
set icon_key = case name
  when 'Comida' then 'food'
  when 'Transporte' then 'transport'
  when 'Supermercado' then 'shopping'
  when 'Servicios' then 'services'
  when 'Salud' then 'health'
  when 'Ocio' then 'leisure'
  when 'Otros' then 'tag'
  else icon_key
end
where name in ('Comida','Transporte','Supermercado','Servicios','Salud','Ocio','Otros');
