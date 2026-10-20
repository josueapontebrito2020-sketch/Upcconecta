-- =============================================================================
-- UpcConecta · Migración 5: editar la fecha de nacimiento
--
-- Qué hace:
--   1. Permite que cada usuario cambie su fecha de nacimiento desde
--      "Editar perfil".
--   2. Revisa en la base de datos que la edad quede entre 14 y 100 años
--      (la misma regla del registro), aunque alguien salte la app.
--
-- Cómo aplicarla: Supabase → SQL Editor → pegar este archivo → Run.
-- =============================================================================

create or replace function public.check_birth_date()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.birth_date is not null
     and (new.birth_date > current_date - interval '14 years'
          or new.birth_date <= current_date - interval '101 years') then
    raise exception 'La edad debe estar entre 14 y 100 años'
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_check_birth_date on public.profiles;
create trigger profiles_check_birth_date
  before update of birth_date on public.profiles
  for each row execute function public.check_birth_date();

grant update (birth_date) on public.profiles to authenticated;
