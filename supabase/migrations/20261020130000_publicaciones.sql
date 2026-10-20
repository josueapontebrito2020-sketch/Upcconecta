-- =============================================================================
-- UpcConecta · Migración 3: publicaciones (inicio)
--
-- Qué hace:
--   1. Tabla de publicaciones (posts) y de sus fotos o video (post_media).
--      Reglas: texto de 1 a 2000 caracteres, hasta 5 etiquetas, y hasta
--      5 fotos o 1 video por publicación.
--   2. Me gusta, guardados, seguidores, publicaciones ocultas y reportes.
--   3. Contadores automáticos (me gusta y guardados) y función para sumar
--      compartidos.
--   4. Vista "feed_posts": lo que muestra el inicio, con el autor, las fotos y
--      si el usuario ya dio me gusta, guardó o sigue al autor.
--   5. Función "create_post": crea la publicación y sus archivos de una vez.
--   6. Bucket "posts" (fotos y videos, máximo 20 MB por archivo).
--   7. Seguridad (RLS) y permisos de cada tabla.
--
-- Cómo aplicarla: Supabase → SQL Editor → pegar este archivo → Run.
-- Requiere las migraciones 1 y 2.
-- =============================================================================


-- 1. Publicaciones -------------------------------------------------------------

create table if not exists public.posts (
  id             uuid primary key default gen_random_uuid(),
  author_id      uuid not null default auth.uid()
                   references public.profiles (id) on delete cascade,
  content        text not null
                   check (char_length(btrim(content)) between 1 and 2000),
  category       text not null
                   check (category in ('product', 'service', 'skill', 'advisory')),
  tags           text[] not null default '{}'
                   check (cardinality(tags) <= 5),
  -- Destacada (pagada). Solo el servidor la cambia.
  is_featured    boolean not null default false,
  featured_until timestamptz,
  -- Contadores: los mantienen los triggers y funciones de abajo.
  like_count     integer not null default 0,
  save_count     integer not null default 0,
  share_count    integer not null default 0,
  -- Calificación: se llenará con las reseñas (fase de solicitudes).
  rating_avg     numeric(3, 2) not null default 0,
  rating_count   integer not null default 0,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

comment on table public.posts is
  'Publicaciones del inicio: productos, servicios, habilidades y asesorías.';

create index if not exists posts_created_at_idx
  on public.posts (created_at desc);
create index if not exists posts_author_idx
  on public.posts (author_id, created_at desc);
create index if not exists posts_category_idx
  on public.posts (category, created_at desc);
create index if not exists posts_featured_idx
  on public.posts (created_at desc) where is_featured;

-- updated_at solo cuando cambia el contenido (no con cada me gusta).
drop trigger if exists posts_set_updated_at on public.posts;
create trigger posts_set_updated_at
  before update of content, category, tags on public.posts
  for each row execute function public.set_updated_at();

-- Etiquetas limpias: sin espacios sobrantes, sin repetir (sin importar
-- mayúsculas), máximo 30 letras cada una.
create or replace function public.normalize_post_tags()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  select coalesce(array_agg(tag order by pos), '{}')
    into new.tags
  from (
    select distinct on (lower(btrim(t)))
           left(btrim(t), 30) as tag, pos
    from unnest(coalesce(new.tags, '{}')) with ordinality as u (t, pos)
    where btrim(t) <> ''
    order by lower(btrim(t)), pos
  ) as clean;
  return new;
end;
$$;

drop trigger if exists posts_normalize_tags on public.posts;
create trigger posts_normalize_tags
  before insert or update of tags on public.posts
  for each row execute function public.normalize_post_tags();


-- Fotos y video de cada publicación
create table if not exists public.post_media (
  id           uuid primary key default gen_random_uuid(),
  post_id      uuid not null references public.posts (id) on delete cascade,
  -- Ruta dentro del bucket "posts": <id-del-autor>/<carpeta>/<n>.<ext>
  storage_path text not null unique,
  media_type   text not null check (media_type in ('image', 'video')),
  position     smallint not null check (position between 0 and 4),
  created_at   timestamptz not null default now(),
  unique (post_id, position)
);

create index if not exists post_media_post_idx on public.post_media (post_id);

-- Hasta 5 fotos o 1 video (no se mezclan).
create or replace function public.check_post_media_limits()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_total  integer;
  v_videos integer;
begin
  select count(*), count(*) filter (where media_type = 'video')
    into v_total, v_videos
  from public.post_media
  where post_id = new.post_id;

  if v_total >= 5 then
    raise exception 'Una publicación tiene máximo 5 fotos'
      using errcode = 'check_violation';
  end if;
  if v_videos > 0 or (new.media_type = 'video' and v_total > 0) then
    raise exception 'Una publicación tiene hasta 5 fotos o 1 video'
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

drop trigger if exists post_media_limits on public.post_media;
create trigger post_media_limits
  before insert on public.post_media
  for each row execute function public.check_post_media_limits();


-- 2. Me gusta, guardados, seguidores, ocultas y reportes ---------------------

create table if not exists public.post_likes (
  post_id    uuid not null references public.posts (id) on delete cascade,
  user_id    uuid not null default auth.uid()
               references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.post_saves (
  post_id    uuid not null references public.posts (id) on delete cascade,
  user_id    uuid not null default auth.uid()
               references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);
create index if not exists post_saves_user_idx
  on public.post_saves (user_id, created_at desc);

create table if not exists public.follows (
  follower_id uuid not null default auth.uid()
                references public.profiles (id) on delete cascade,
  followed_id uuid not null references public.profiles (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (follower_id, followed_id),
  check (follower_id <> followed_id)
);
create index if not exists follows_followed_idx on public.follows (followed_id);

create table if not exists public.hidden_posts (
  user_id    uuid not null default auth.uid()
               references public.profiles (id) on delete cascade,
  post_id    uuid not null references public.posts (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, post_id)
);

create table if not exists public.post_reports (
  id          uuid primary key default gen_random_uuid(),
  post_id     uuid not null references public.posts (id) on delete cascade,
  reporter_id uuid not null default auth.uid()
                references public.profiles (id) on delete cascade,
  reason      text not null
                check (reason in ('spam', 'inappropriate', 'fraud', 'other')),
  details     text check (details is null or char_length(details) <= 500),
  status      text not null default 'pendiente'
                check (status in ('pendiente', 'revisado', 'descartado')),
  created_at  timestamptz not null default now(),
  -- Una persona reporta la misma publicación una sola vez.
  unique (post_id, reporter_id)
);

comment on table public.post_reports is
  'Reportes de publicaciones. Solo los revisa el equipo desde el panel.';


-- 3. Contadores ----------------------------------------------------------------

create or replace function public.update_post_counters()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_post_id uuid;
  v_delta   integer;
begin
  if tg_op = 'INSERT' then
    v_post_id := new.post_id;
    v_delta := 1;
  else
    v_post_id := old.post_id;
    v_delta := -1;
  end if;

  if tg_table_name = 'post_likes' then
    update public.posts
       set like_count = greatest(like_count + v_delta, 0)
     where id = v_post_id;
  else
    update public.posts
       set save_count = greatest(save_count + v_delta, 0)
     where id = v_post_id;
  end if;
  return null;
end;
$$;

drop trigger if exists post_likes_count on public.post_likes;
create trigger post_likes_count
  after insert or delete on public.post_likes
  for each row execute function public.update_post_counters();

drop trigger if exists post_saves_count on public.post_saves;
create trigger post_saves_count
  after insert or delete on public.post_saves
  for each row execute function public.update_post_counters();

-- Compartir: la app copia el texto y llama a esta función.
create or replace function public.register_post_share(p_post_id uuid)
returns void
language sql
security definer
set search_path = ''
as $$
  update public.posts
     set share_count = share_count + 1
   where id = p_post_id
     and public.is_institutional_user();
$$;

revoke all on function public.register_post_share(uuid) from public, anon;
grant execute on function public.register_post_share(uuid) to authenticated;


-- 4. Vista del inicio ----------------------------------------------------------
-- security_invoker: respeta los permisos (RLS) de quien consulta.

create or replace view public.feed_posts
with (security_invoker = true)
as
select
  p.id,
  p.author_id,
  p.content,
  p.category,
  p.tags,
  (p.is_featured and (p.featured_until is null or p.featured_until > now()))
    as is_featured,
  p.like_count,
  p.save_count,
  p.share_count,
  p.rating_avg,
  p.rating_count,
  p.created_at,
  a.username     as author_username,
  a.full_name    as author_full_name,
  a.avatar_url   as author_avatar_url,
  a.is_verified  as author_is_verified,
  coalesce(
    (select jsonb_agg(
              jsonb_build_object('path', m.storage_path, 'type', m.media_type)
              order by m.position)
       from public.post_media m
      where m.post_id = p.id),
    '[]'::jsonb
  ) as media,
  (p.author_id = (select auth.uid())) as is_mine,
  exists (
    select 1 from public.post_likes l
     where l.post_id = p.id and l.user_id = (select auth.uid())
  ) as is_liked,
  exists (
    select 1 from public.post_saves s
     where s.post_id = p.id and s.user_id = (select auth.uid())
  ) as is_saved,
  exists (
    select 1 from public.follows f
     where f.followed_id = p.author_id and f.follower_id = (select auth.uid())
  ) as is_following_author
from public.posts p
join public.profiles a on a.id = p.author_id
where not exists (
  select 1 from public.hidden_posts h
   where h.post_id = p.id and h.user_id = (select auth.uid())
);

comment on view public.feed_posts is
  'Publicaciones listas para el inicio, desde el punto de vista de quien consulta.';


-- 5. Crear publicación con sus archivos (todo o nada) --------------------------
-- La app primero sube los archivos al bucket y luego llama:
--   create_post(texto, categoría, etiquetas, [{"path": "...", "type": "image"}])

create or replace function public.create_post(
  p_content  text,
  p_category text,
  p_tags     text[],
  p_media    jsonb
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_post_id  uuid;
  v_item     jsonb;
  v_position smallint := 0;
begin
  insert into public.posts (content, category, tags)
  values (btrim(p_content), p_category, coalesce(p_tags, '{}'))
  returning id into v_post_id;

  for v_item in
    select value from jsonb_array_elements(coalesce(p_media, '[]'::jsonb))
  loop
    insert into public.post_media (post_id, storage_path, media_type, position)
    values (v_post_id, v_item ->> 'path', v_item ->> 'type', v_position);
    v_position := v_position + 1;
  end loop;

  return v_post_id;
end;
$$;

revoke all on function public.create_post(text, text, text[], jsonb) from public, anon;
grant execute on function public.create_post(text, text, text[], jsonb) to authenticated;


-- 6. Archivos de las publicaciones (Storage) -----------------------------------
-- Bucket público de máximo 20 MB por archivo. Cada usuario solo escribe en su
-- carpeta: posts/<id-del-usuario>/...

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'posts', 'posts', true, 20971520,
  array['image/jpeg', 'image/png', 'image/webp',
        'video/mp4', 'video/quicktime', 'video/webm']
)
on conflict (id) do nothing;

drop policy if exists "Usuarios ven los archivos de publicaciones" on storage.objects;
create policy "Usuarios ven los archivos de publicaciones"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'posts');

drop policy if exists "Cada usuario sube archivos a su carpeta" on storage.objects;
create policy "Cada usuario sube archivos a su carpeta"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'posts'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Cada usuario borra sus archivos" on storage.objects;
create policy "Cada usuario borra sus archivos"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'posts'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );


-- 7. Seguridad (RLS) y permisos -----------------------------------------------

alter table public.posts        enable row level security;
alter table public.post_media   enable row level security;
alter table public.post_likes   enable row level security;
alter table public.post_saves   enable row level security;
alter table public.follows      enable row level security;
alter table public.hidden_posts enable row level security;
alter table public.post_reports enable row level security;

-- Publicaciones: todos los institucionales las ven; cada uno publica,
-- edita y borra solo las suyas.
drop policy if exists "Usuarios institucionales ven publicaciones" on public.posts;
create policy "Usuarios institucionales ven publicaciones"
  on public.posts for select
  to authenticated
  using (public.is_institutional_user());

drop policy if exists "Cada usuario publica a su nombre" on public.posts;
create policy "Cada usuario publica a su nombre"
  on public.posts for insert
  to authenticated
  with check (
    author_id = (select auth.uid()) and public.is_institutional_user()
  );

drop policy if exists "Cada usuario edita sus publicaciones" on public.posts;
create policy "Cada usuario edita sus publicaciones"
  on public.posts for update
  to authenticated
  using (author_id = (select auth.uid()))
  with check (author_id = (select auth.uid()));

drop policy if exists "Cada usuario borra sus publicaciones" on public.posts;
create policy "Cada usuario borra sus publicaciones"
  on public.posts for delete
  to authenticated
  using (author_id = (select auth.uid()));

grant select, delete on public.posts to authenticated;
-- Solo estos campos los pone el usuario; destacado, contadores y
-- calificación los maneja el servidor.
grant insert (content, category, tags) on public.posts to authenticated;
grant update (content, category, tags) on public.posts to authenticated;

-- Archivos de la publicación: solo el autor los agrega o borra, y solo
-- desde su carpeta del bucket.
drop policy if exists "Usuarios institucionales ven archivos" on public.post_media;
create policy "Usuarios institucionales ven archivos"
  on public.post_media for select
  to authenticated
  using (public.is_institutional_user());

drop policy if exists "El autor agrega archivos" on public.post_media;
create policy "El autor agrega archivos"
  on public.post_media for insert
  to authenticated
  with check (
    storage_path like (select auth.uid())::text || '/%'
    and exists (
      select 1 from public.posts p
       where p.id = post_id and p.author_id = (select auth.uid())
    )
  );

drop policy if exists "El autor borra archivos" on public.post_media;
create policy "El autor borra archivos"
  on public.post_media for delete
  to authenticated
  using (
    exists (
      select 1 from public.posts p
       where p.id = post_id and p.author_id = (select auth.uid())
    )
  );

grant select, delete on public.post_media to authenticated;
grant insert (post_id, storage_path, media_type, position)
  on public.post_media to authenticated;

-- Me gusta y guardados: cada uno ve y maneja solo los suyos (los totales
-- están en los contadores de la publicación).
drop policy if exists "Cada usuario ve sus me gusta" on public.post_likes;
create policy "Cada usuario ve sus me gusta"
  on public.post_likes for select
  to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Cada usuario da me gusta" on public.post_likes;
create policy "Cada usuario da me gusta"
  on public.post_likes for insert
  to authenticated
  with check (
    user_id = (select auth.uid()) and public.is_institutional_user()
  );

drop policy if exists "Cada usuario quita su me gusta" on public.post_likes;
create policy "Cada usuario quita su me gusta"
  on public.post_likes for delete
  to authenticated
  using (user_id = (select auth.uid()));

grant select, delete on public.post_likes to authenticated;
grant insert (post_id) on public.post_likes to authenticated;

drop policy if exists "Cada usuario ve sus guardados" on public.post_saves;
create policy "Cada usuario ve sus guardados"
  on public.post_saves for select
  to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Cada usuario guarda publicaciones" on public.post_saves;
create policy "Cada usuario guarda publicaciones"
  on public.post_saves for insert
  to authenticated
  with check (
    user_id = (select auth.uid()) and public.is_institutional_user()
  );

drop policy if exists "Cada usuario quita sus guardados" on public.post_saves;
create policy "Cada usuario quita sus guardados"
  on public.post_saves for delete
  to authenticated
  using (user_id = (select auth.uid()));

grant select, delete on public.post_saves to authenticated;
grant insert (post_id) on public.post_saves to authenticated;

-- Seguidores: se pueden ver (para contar seguidores en el perfil); cada uno
-- sigue o deja de seguir por su cuenta.
drop policy if exists "Usuarios institucionales ven seguidores" on public.follows;
create policy "Usuarios institucionales ven seguidores"
  on public.follows for select
  to authenticated
  using (public.is_institutional_user());

drop policy if exists "Cada usuario sigue a otros" on public.follows;
create policy "Cada usuario sigue a otros"
  on public.follows for insert
  to authenticated
  with check (
    follower_id = (select auth.uid()) and public.is_institutional_user()
  );

drop policy if exists "Cada usuario deja de seguir" on public.follows;
create policy "Cada usuario deja de seguir"
  on public.follows for delete
  to authenticated
  using (follower_id = (select auth.uid()));

grant select, delete on public.follows to authenticated;
grant insert (followed_id) on public.follows to authenticated;

-- Ocultas: privadas de cada usuario.
drop policy if exists "Cada usuario ve sus ocultas" on public.hidden_posts;
create policy "Cada usuario ve sus ocultas"
  on public.hidden_posts for select
  to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Cada usuario oculta publicaciones" on public.hidden_posts;
create policy "Cada usuario oculta publicaciones"
  on public.hidden_posts for insert
  to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "Cada usuario vuelve a mostrar" on public.hidden_posts;
create policy "Cada usuario vuelve a mostrar"
  on public.hidden_posts for delete
  to authenticated
  using (user_id = (select auth.uid()));

grant select, delete on public.hidden_posts to authenticated;
grant insert (post_id) on public.hidden_posts to authenticated;

-- Reportes: el usuario solo los crea; no puede leerlos ni cambiarlos.
-- El equipo los revisa en Supabase → Table Editor → post_reports.
drop policy if exists "Cada usuario reporta publicaciones" on public.post_reports;
create policy "Cada usuario reporta publicaciones"
  on public.post_reports for insert
  to authenticated
  with check (
    reporter_id = (select auth.uid()) and public.is_institutional_user()
  );

grant insert (post_id, reason, details) on public.post_reports to authenticated;

-- La vista del inicio
grant select on public.feed_posts to authenticated;
