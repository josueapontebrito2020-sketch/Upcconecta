-- =============================================================================
-- UpcConecta · Migración 4: perfil completo
--
-- Qué hace:
--   1. Protege los datos privados del perfil: el correo, el celular y la
--      fecha de nacimiento ya no los puede leer cualquier usuario; cada uno
--      ve solo los suyos (función get_my_private_profile).
--   2. Permite cambiar la facultad y la carrera desde "Editar perfil".
--   3. Guarda qué publicaciones compartió cada usuario (pestaña Compartidas).
--   4. Guarda quién visitó cada perfil (ícono "Vistas del perfil").
--   5. Vista "profile_details": el perfil con facultad, carrera, seguidores,
--      seguidos, me gusta recibidos y si lo sigues.
--   6. Funciones para buscar usuarios y listar seguidores, seguidos y
--      visitas.
--
-- Cómo aplicarla: Supabase → SQL Editor → pegar este archivo → Run.
-- Requiere las migraciones 1, 2 y 3.
-- =============================================================================


-- 1. Datos privados del perfil -------------------------------------------------
-- Los demás usuarios solo pueden leer estas columnas de "profiles".

revoke select on public.profiles from authenticated;
grant select (
  id, username, full_name, role, avatar_url, bio, visibility, is_verified,
  rating_avg, rating_count, faculty_id, program_id, created_at
) on public.profiles to authenticated;

-- Cada usuario lee sus propios datos privados.
create or replace function public.get_my_private_profile()
returns table (email text, phone text, birth_date date)
language sql
stable
security definer
set search_path = ''
as $$
  select p.email, p.phone, p.birth_date
  from public.profiles p
  where p.id = (select auth.uid());
$$;

revoke all on function public.get_my_private_profile() from public, anon;
grant execute on function public.get_my_private_profile() to authenticated;


-- 2. Facultad y carrera editables ---------------------------------------------

grant update (faculty_id, program_id) on public.profiles to authenticated;


-- 3. Publicaciones compartidas -------------------------------------------------

create table if not exists public.post_shares (
  user_id   uuid not null default auth.uid()
              references public.profiles (id) on delete cascade,
  post_id   uuid not null references public.posts (id) on delete cascade,
  shared_at timestamptz not null default now(),
  primary key (user_id, post_id)
);
create index if not exists post_shares_user_idx
  on public.post_shares (user_id, shared_at desc);

alter table public.post_shares enable row level security;

drop policy if exists "Cada usuario ve lo que compartió" on public.post_shares;
create policy "Cada usuario ve lo que compartió"
  on public.post_shares for select
  to authenticated
  using (user_id = (select auth.uid()));

grant select on public.post_shares to authenticated;

-- Compartir ahora también guarda la publicación en "Compartidas".
create or replace function public.register_post_share(p_post_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_institutional_user() then
    return;
  end if;

  insert into public.post_shares (user_id, post_id)
  values ((select auth.uid()), p_post_id)
  on conflict (user_id, post_id) do update set shared_at = now();

  update public.posts
     set share_count = share_count + 1
   where id = p_post_id;
end;
$$;

revoke all on function public.register_post_share(uuid) from public, anon;
grant execute on function public.register_post_share(uuid) to authenticated;


-- 4. Visitas al perfil ---------------------------------------------------------
-- Se guarda la última visita de cada persona a cada perfil.

create table if not exists public.profile_views (
  viewer_id  uuid not null references public.profiles (id) on delete cascade,
  profile_id uuid not null references public.profiles (id) on delete cascade,
  viewed_at  timestamptz not null default now(),
  primary key (viewer_id, profile_id),
  check (viewer_id <> profile_id)
);
create index if not exists profile_views_profile_idx
  on public.profile_views (profile_id, viewed_at desc);

alter table public.profile_views enable row level security;

-- Solo el dueño del perfil ve quién lo visitó.
drop policy if exists "Cada usuario ve quién visitó su perfil" on public.profile_views;
create policy "Cada usuario ve quién visitó su perfil"
  on public.profile_views for select
  to authenticated
  using (profile_id = (select auth.uid()));

grant select on public.profile_views to authenticated;

-- La app la llama al abrir el perfil de otra persona.
create or replace function public.register_profile_view(p_profile_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_institutional_user()
     or p_profile_id = (select auth.uid()) then
    return;
  end if;

  insert into public.profile_views (viewer_id, profile_id)
  values ((select auth.uid()), p_profile_id)
  on conflict (viewer_id, profile_id) do update set viewed_at = now();
end;
$$;

revoke all on function public.register_profile_view(uuid) from public, anon;
grant execute on function public.register_profile_view(uuid) to authenticated;


-- 5. Vista del perfil ----------------------------------------------------------

create or replace view public.profile_details
with (security_invoker = true)
as
select
  p.id,
  p.username,
  p.full_name,
  p.avatar_url,
  p.bio,
  p.role,
  p.is_verified,
  p.rating_avg,
  p.rating_count,
  p.created_at,
  p.faculty_id,
  p.program_id,
  f.name as faculty_name,
  g.name as program_name,
  (select count(*) from public.follows x where x.followed_id = p.id)
    as followers_count,
  (select count(*) from public.follows x where x.follower_id = p.id)
    as following_count,
  (select count(*) from public.posts s where s.author_id = p.id)
    as posts_count,
  (select coalesce(sum(s.like_count), 0) from public.posts s
    where s.author_id = p.id)
    as likes_count,
  -- Solo el dueño del perfil puede contar sus visitas (por la RLS); para
  -- los demás siempre da 0.
  (select count(*) from public.profile_views v
    where v.profile_id = p.id and v.viewed_at > now() - interval '30 days')
    as recent_views_count,
  (p.id = (select auth.uid())) as is_mine,
  exists (
    select 1 from public.follows x
     where x.follower_id = (select auth.uid()) and x.followed_id = p.id
  ) as is_following
from public.profiles p
left join public.faculties f on f.id = p.faculty_id
left join public.programs g on g.id = p.program_id;

grant select on public.profile_details to authenticated;


-- 6. Buscar usuarios y listas de personas --------------------------------------
-- Todas devuelven las mismas columnas para mostrar a cada persona en una
-- lista: id, usuario, nombre, foto, verificado y si ya la sigues.

create or replace function public.search_users(p_query text)
returns table (
  id uuid, username text, full_name text, avatar_url text,
  is_verified boolean, is_following boolean
)
language sql
stable
set search_path = ''
as $$
  with q as (
    -- Los caracteres % y _ se buscan tal cual (no como comodines).
    select replace(replace(replace(btrim(coalesce(p_query, '')),
             '\', '\\'), '%', '\%'), '_', '\_') as text
  )
  select p.id, p.username, p.full_name, p.avatar_url, p.is_verified,
         exists (
           select 1 from public.follows x
            where x.follower_id = (select auth.uid()) and x.followed_id = p.id
         )
  from public.profiles p, q
  where q.text <> ''
    and p.id <> (select auth.uid())
    and (p.username ilike '%' || q.text || '%'
         or p.full_name ilike '%' || q.text || '%')
  order by (p.username ilike q.text || '%') desc, p.full_name
  limit 30;
$$;

create or replace function public.get_followers(p_user_id uuid)
returns table (
  id uuid, username text, full_name text, avatar_url text,
  is_verified boolean, is_following boolean
)
language sql
stable
set search_path = ''
as $$
  select p.id, p.username, p.full_name, p.avatar_url, p.is_verified,
         exists (
           select 1 from public.follows x
            where x.follower_id = (select auth.uid()) and x.followed_id = p.id
         )
  from public.follows f
  join public.profiles p on p.id = f.follower_id
  where f.followed_id = p_user_id
  order by f.created_at desc
  limit 200;
$$;

create or replace function public.get_following(p_user_id uuid)
returns table (
  id uuid, username text, full_name text, avatar_url text,
  is_verified boolean, is_following boolean
)
language sql
stable
set search_path = ''
as $$
  select p.id, p.username, p.full_name, p.avatar_url, p.is_verified,
         exists (
           select 1 from public.follows x
            where x.follower_id = (select auth.uid()) and x.followed_id = p.id
         )
  from public.follows f
  join public.profiles p on p.id = f.followed_id
  where f.follower_id = p_user_id
  order by f.created_at desc
  limit 200;
$$;

-- Quién visitó mi perfil en los últimos 30 días.
create or replace function public.get_profile_viewers()
returns table (
  id uuid, username text, full_name text, avatar_url text,
  is_verified boolean, is_following boolean, viewed_at timestamptz
)
language sql
stable
set search_path = ''
as $$
  select p.id, p.username, p.full_name, p.avatar_url, p.is_verified,
         exists (
           select 1 from public.follows x
            where x.follower_id = (select auth.uid()) and x.followed_id = p.id
         ),
         v.viewed_at
  from public.profile_views v
  join public.profiles p on p.id = v.viewer_id
  where v.profile_id = (select auth.uid())
    and v.viewed_at > now() - interval '30 days'
  order by v.viewed_at desc
  limit 100;
$$;

revoke all on function public.search_users(text) from public, anon;
revoke all on function public.get_followers(uuid) from public, anon;
revoke all on function public.get_following(uuid) from public, anon;
revoke all on function public.get_profile_viewers() from public, anon;
grant execute on function public.search_users(text) to authenticated;
grant execute on function public.get_followers(uuid) to authenticated;
grant execute on function public.get_following(uuid) to authenticated;
grant execute on function public.get_profile_viewers() to authenticated;
