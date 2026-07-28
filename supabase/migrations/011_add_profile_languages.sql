alter table public.profiles
  drop constraint if exists profiles_language_preference_check;

alter table public.profiles
  add constraint profiles_language_preference_check
    check (language_preference in ('es', 'en', 'fr', 'it', 'de'));
