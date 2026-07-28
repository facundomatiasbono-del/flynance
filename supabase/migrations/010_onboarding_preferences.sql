alter table public.profiles
  add column if not exists onboarding_completed boolean not null default false,
  add column if not exists theme_preference text not null default 'system',
  add column if not exists language_preference text not null default 'es';

alter table public.profiles
  drop constraint if exists profiles_theme_preference_check,
  drop constraint if exists profiles_language_preference_check;

alter table public.profiles
  add constraint profiles_theme_preference_check
    check (theme_preference in ('light', 'dark', 'system')),
  add constraint profiles_language_preference_check
    check (language_preference in ('es', 'en', 'fr', 'it', 'de'));
