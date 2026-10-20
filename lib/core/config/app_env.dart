/// Configuración que llega al compilar, desde `env/dev.json`:
///
/// ```bash
/// flutter run --dart-define-from-file=env/dev.json
/// ```
///
/// Así las claves no quedan escritas en el código ni se suben al
/// repositorio (`env/*.json` está en `.gitignore`, salvo el ejemplo).
abstract final class AppEnv {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Si es false, la app usa la autenticación de prueba en memoria.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
