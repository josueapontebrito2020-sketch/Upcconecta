-- =============================================================================
-- UpcConecta · Migración 1: perfiles y correo institucional
--
-- Qué hace:
--   1. Rechaza en la base de datos cualquier cuenta que no sea @unicesar.edu.co
--      (aunque alguien salte la validación de la app).
--   2. Crea la tabla public.profiles (un perfil por usuario).
--   3. Crea el perfil automáticamente al registrarse.
--   4. Activa la seguridad por filas (RLS): solo usuarios institucionales leen
--      perfiles y cada uno edita únicamente el suyo y solo ciertos campos.
--
-- Cómo aplicarla: Supabase → SQL Editor → pegar este archivo → Run.
-- (o con la CLI: supabase db push)
-- =============================================================================


-- 1. Solo correos institucionales ---------------------------------------------

create or replace function public.enforce_institutional_email()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.email is null
     or lower(new.email) !~ '^[^@\s]+@unicesar\.edu\.co$' then
    raise exception 'Solo se permiten correos @unicesar.edu.co'
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

drop trigger if exists enforce_institutional_email on auth.users;
create trigger enforce_institutional_email
  before insert or update of email on auth.users
  for each row execute function public.enforce_institutional_email();


-- 2. Tabla de perfiles ---------------------------------------------------------

create table if not exists public.profiles (
  id             uuid primary key references auth.users (id) on delete cascade,
  email          text not null unique,
  full_name      text not null default '',
  username       text unique
                   check (username ~ '^[a-z0-9_.]{3,30}$'),
  role           text not null default 'estudiante'
                   check (role in ('estudiante', 'profesor', 'admin')),
  avatar_url     text,
  bio            text not null default ''
                   check (char_length(bio) <= 500),
  visibility     text not null default 'publico'
                   check (visibility in ('publico', 'amigos', 'privado')),
  is_verified    boolean not null default false,
  rating_avg     numeric(3, 2) not null default 0,
  rating_count   integer not null default 0,
  points_balance integer not null default 0,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

comment on table public.profiles is
  'Perfil público de cada usuario de UpcConecta (1 a 1 con auth.users).';


-- updated_at automático
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();


-- 3. Crear el perfil al registrarse --------------------------------------------
-- La app envía el nombre en los metadatos del registro: { "full_name": "..." }

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    lower(new.email),
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- 4. Seguridad por filas (RLS) ------------------------------------------------

-- ¿El usuario de la petición tiene sesión con correo institucional?
create or replace function public.is_institutional_user()
returns boolean
language sql
stable
set search_path = ''
as $$
  select coalesce(
    (auth.jwt() ->> 'email') ~* '@unicesar\.edu\.co$',
    false
  );
$$;

alter table public.profiles enable row level security;

drop policy if exists "Usuarios institucionales ven los perfiles" on public.profiles;
create policy "Usuarios institucionales ven los perfiles"
  on public.profiles for select
  to authenticated
  using (public.is_institutional_user());

drop policy if exists "Cada usuario edita su propio perfil" on public.profiles;
create policy "Cada usuario edita su propio perfil"
  on public.profiles for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- Permisos explícitos: el proyecto NO expone tablas nuevas automáticamente,
-- así que cada tabla declara qué puede hacer el rol "authenticated".
grant select on public.profiles to authenticated;

-- Campos que el usuario NO puede cambiar por su cuenta (rol, verificado,
-- calificación, puntos): solo el servidor los modifica.
revoke update on public.profiles from authenticated;
grant update (full_name, username, avatar_url, bio, visibility)
  on public.profiles to authenticated;
