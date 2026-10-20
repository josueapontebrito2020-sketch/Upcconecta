-- =============================================================================
-- UpcConecta · Migración 2: registro completo
--
-- Qué hace:
--   1. Crea las tablas de facultades y carreras de la UPC (sede Valledupar),
--      con sus datos.
--   2. Agrega al perfil: fecha de nacimiento, celular, facultad y carrera.
--   3. Actualiza la creación automática del perfil para guardar todos los
--      datos del formulario de registro.
--   4. Crea la función para saber si un nombre de usuario está libre.
--   5. Crea el espacio de fotos de perfil (bucket "avatars") y sus permisos.
--
-- Cómo aplicarla: Supabase → SQL Editor → pegar este archivo → Run.
-- =============================================================================


-- 1. Facultades y carreras -----------------------------------------------------

create table if not exists public.faculties (
  id         smallint generated always as identity primary key,
  name       text not null unique,
  sort_order smallint not null default 0
);

create table if not exists public.programs (
  id         smallint generated always as identity primary key,
  faculty_id smallint not null references public.faculties (id) on delete restrict,
  name       text not null,
  sort_order smallint not null default 0,
  unique (faculty_id, name)
);

comment on table public.faculties is 'Facultades de la Universidad Popular del Cesar.';
comment on table public.programs is 'Carreras (programas de pregrado) de cada facultad.';

alter table public.faculties enable row level security;
alter table public.programs enable row level security;

-- Las listas se ven sin iniciar sesión, porque se usan en el registro.
drop policy if exists "Cualquiera ve las facultades" on public.faculties;
create policy "Cualquiera ve las facultades"
  on public.faculties for select
  to anon, authenticated
  using (true);

drop policy if exists "Cualquiera ve las carreras" on public.programs;
create policy "Cualquiera ve las carreras"
  on public.programs for select
  to anon, authenticated
  using (true);

grant select on public.faculties to anon, authenticated;
grant select on public.programs to anon, authenticated;

insert into public.faculties (name, sort_order) values
  ('Facultad de Ciencias Administrativas, Contables y Económicas', 1),
  ('Facultad de Bellas Artes', 2),
  ('Facultad de Derecho, Ciencias Políticas y Sociales', 3),
  ('Facultad de Ciencias Básicas', 4),
  ('Facultad de Ingenierías y Tecnologías', 5),
  ('Facultad de Ciencias de la Salud', 6),
  ('Facultad de Educación', 7)
on conflict (name) do nothing;

insert into public.programs (faculty_id, name, sort_order)
select f.id, p.name, p.sort_order
from (values
  ('Facultad de Ciencias Administrativas, Contables y Económicas', 'Administración de Empresas', 1),
  ('Facultad de Ciencias Administrativas, Contables y Económicas', 'Administración de Empresas Turísticas y Hoteleras', 2),
  ('Facultad de Ciencias Administrativas, Contables y Económicas', 'Comercio Internacional', 3),
  ('Facultad de Ciencias Administrativas, Contables y Económicas', 'Contaduría Pública', 4),
  ('Facultad de Ciencias Administrativas, Contables y Económicas', 'Economía', 5),
  ('Facultad de Bellas Artes', 'Licenciatura en Artes', 1),
  ('Facultad de Bellas Artes', 'Música', 2),
  ('Facultad de Derecho, Ciencias Políticas y Sociales', 'Derecho', 1),
  ('Facultad de Derecho, Ciencias Políticas y Sociales', 'Psicología', 2),
  ('Facultad de Derecho, Ciencias Políticas y Sociales', 'Sociología', 3),
  ('Facultad de Ciencias Básicas', 'Microbiología', 1),
  ('Facultad de Ingenierías y Tecnologías', 'Ingeniería Agroindustrial', 1),
  ('Facultad de Ingenierías y Tecnologías', 'Ingeniería Ambiental y Sanitaria', 2),
  ('Facultad de Ingenierías y Tecnologías', 'Ingeniería de Sistemas', 3),
  ('Facultad de Ingenierías y Tecnologías', 'Ingeniería Electrónica', 4),
  ('Facultad de Ciencias de la Salud', 'Enfermería', 1),
  ('Facultad de Ciencias de la Salud', 'Fisioterapia', 2),
  ('Facultad de Ciencias de la Salud', 'Instrumentación Quirúrgica', 3),
  ('Facultad de Educación', 'Licenciatura en Ciencias Naturales y Educación Ambiental', 1),
  ('Facultad de Educación', 'Licenciatura en Educación Física, Recreación y Deportes', 2),
  ('Facultad de Educación', 'Licenciatura en Español e Inglés', 3),
  ('Facultad de Educación', 'Licenciatura en Literatura y Lengua Castellana', 4),
  ('Facultad de Educación', 'Licenciatura en Matemáticas', 5)
) as p (faculty, name, sort_order)
join public.faculties f on f.name = p.faculty
on conflict (faculty_id, name) do nothing;


-- 2. Datos nuevos del perfil ---------------------------------------------------

alter table public.profiles
  add column if not exists birth_date date,
  add column if not exists phone      text check (phone is null or phone ~ '^3[0-9]{9}$'),
  add column if not exists faculty_id smallint references public.faculties (id),
  add column if not exists program_id smallint references public.programs (id);

-- El usuario puede editar también su celular (la facultad y la carrera se
-- cambiarán desde una función del servidor más adelante).
grant update (phone) on public.profiles to authenticated;


-- 3. Crear el perfil con todos los datos del registro --------------------------
-- La app envía en los metadatos del registro:
-- full_name, username, birth_date (aaaa-mm-dd), phone, faculty_id, program_id, bio

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  meta jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
begin
  insert into public.profiles (
    id, email, full_name, username, birth_date, phone, faculty_id, program_id, bio
  )
  values (
    new.id,
    lower(new.email),
    coalesce(meta ->> 'full_name', ''),
    nullif(lower(meta ->> 'username'), ''),
    nullif(meta ->> 'birth_date', '')::date,
    nullif(meta ->> 'phone', ''),
    nullif(meta ->> 'faculty_id', '')::smallint,
    nullif(meta ->> 'program_id', '')::smallint,
    left(coalesce(meta ->> 'bio', ''), 500)
  );
  return new;
end;
$$;


-- 4. ¿Nombre de usuario disponible? --------------------------------------------
-- Se llama desde la app antes de crear la cuenta: supabase.rpc('is_username_available')

create or replace function public.is_username_available(p_username text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select not exists (
    select 1 from public.profiles where username = lower(p_username)
  );
$$;

revoke all on function public.is_username_available(text) from public;
grant execute on function public.is_username_available(text) to anon, authenticated;


-- 5. Fotos de perfil (Storage) -------------------------------------------------
-- Bucket público de máximo 2 MB por foto. Cada usuario solo escribe en su
-- propia carpeta: avatars/<id-del-usuario>/avatar.jpg

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatars', 'avatars', true, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

drop policy if exists "Usuarios ven las fotos de perfil" on storage.objects;
create policy "Usuarios ven las fotos de perfil"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'avatars');

drop policy if exists "Cada usuario sube su foto" on storage.objects;
create policy "Cada usuario sube su foto"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Cada usuario cambia su foto" on storage.objects;
create policy "Cada usuario cambia su foto"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Cada usuario borra su foto" on storage.objects;
create policy "Cada usuario borra su foto"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
