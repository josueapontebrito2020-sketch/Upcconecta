# UpcConecta

App móvil (Flutter) de la comunidad de la Universidad Popular del Cesar: publicaciones de
productos, servicios, habilidades y asesorías entre estudiantes y profesores, perfiles,
chat, grupos, transporte compartido y más. Solo admite cuentas con correo
`@unicesar.edu.co`. Backend: **Supabase**.

Proyecto de aula.

## Avance

- [x] Acceso: login animado, registro con código al correo y recuperar contraseña
- [x] Pantalla principal tipo TikTok: Destacados, Comunidad, filtro por categoría
- [x] Publicaciones: me gusta, guardar, compartir, seguir, ocultar, reportar, eliminar
- [x] Publicar: categoría, descripción, hasta 5 fotos o 1 video corto, etiquetas
- [x] Perfil, editar perfil, seguidores y seguidos, buscar personas, vistas del perfil
- [ ] Mensajes (chat 1 a 1)
- [ ] Solicitar servicio y reseñas
- [ ] Grupos de estudio y de juegos
- [ ] Transporte compartido con mapa en vivo
- [ ] Pagos (Nequi, PSE, efectivo), verificado y destacados
- [ ] Puntos y premios

## Cómo correrla

Requisitos: Flutter 3.47 o superior.

```bash
flutter pub get        # también genera lib/l10n/app_localizations.dart
flutter run
```

Sin claves de Supabase la app usa **datos de prueba** en memoria. Cuenta de prueba:
`demo@unicesar.edu.co` / `Demo1234` (código de verificación: `123456`).

### Con Supabase

1. Crear el proyecto en [supabase.com](https://supabase.com).
2. **SQL Editor** → ejecutar, en orden, los archivos de `supabase/migrations/`.
3. **Authentication → Sign In / Providers → Email**: dejar activado *Confirm email*.
   Configurar un SMTP propio (Authentication → Emails → SMTP Settings) y las plantillas
   *Confirm sign up* y *Reset Password* con `{{ .Token }}`.
4. Copiar `env/env.example.json` como `env/dev.json` y poner la URL y la *publishable key*
   (Project Settings → API Keys). **`env/dev.json` no se sube al repositorio.**
5. Correr:

```bash
flutter run --dart-define-from-file=env/dev.json
```

En VS Code ya hay configuraciones listas en `.vscode/launch.json` (web en el navegador con
vista móvil, con y sin Supabase).

### Pruebas y análisis

```bash
flutter analyze
flutter test
```

## Estructura (Clean Architecture por funcionalidades)

```
lib/
├── main.dart                 # arranque: Supabase + ProviderScope
├── app/                      # une los módulos: app.dart, router/, shell/ (barra inferior)
├── core/                     # compartido; NO depende de ningún módulo
│   ├── config/  constants/  di/  errors/  extensions/
│   ├── router/app_routes.dart
│   ├── theme/                # colores institucionales y tema
│   ├── utils/                # fechas, "hace 2 h", formateadores
│   └── widgets/              # campos, botón principal, avatar, estrellas…
├── features/
│   ├── auth/                 # login, registro, verificar correo, recuperar contraseña
│   ├── academic/             # facultades y carreras
│   ├── feed/                 # inicio, publicar, me gusta, guardar, seguir, compartir
│   ├── profile/              # perfil, editar perfil, seguidores, búsqueda, vistas
│   ├── chat/                 # (próximamente)
│   └── groups/               # (próximamente)
│   # cada módulo: domain/ (Dart puro) · data/ (Supabase y prueba) · di/ · presentation/
└── l10n/app_es.arb           # todos los textos de la app
supabase/migrations/          # base de datos: tablas, triggers, funciones, seguridad (RLS)
env/env.example.json          # plantilla de configuración
test/                         # misma estructura que lib/
```

Reglas del equipo:

- `domain/` es Dart puro: no importa Flutter ni Supabase.
- Las pantallas usan controladores → casos de uso → repositorio (interfaz). Nunca llaman a Supabase.
- Solo `di/` conoce las implementaciones concretas.
- `core/` no importa nada de `features/`.
- Textos en `l10n/app_es.arb`, colores en `core/theme/`, rutas en `AppRoutes`, imágenes en `AppAssets`.
- Toda tabla nueva va en una migración nueva dentro de `supabase/migrations/`, con RLS
  activado y sus permisos (grants) explícitos. Nunca se edita una migración ya aplicada.
- Nunca subir claves: ni `env/dev.json`, ni la *secret key* de Supabase, ni contraseñas de correo.

## Tipografía

Libre Franklin (licencia OFL, en `assets/fonts/OFL.txt`), versión libre de Franklin Gothic,
la tipografía del manual de identidad de la universidad.
