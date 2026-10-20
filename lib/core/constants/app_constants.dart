/// Valores fijos de la app. Si una regla cambia, se cambia solo aquí.
abstract final class AppConstants {
  static const String appName = 'UpcConecta';

  /// Solo se aceptan cuentas con correo de este dominio.
  static const String institutionalDomain = 'unicesar.edu.co';

  static const int minPasswordLength = 8;

  /// Nombre de usuario: de 3 a 30 caracteres (minúsculas, números, . y _).
  static const int usernameMinLength = 3;
  static const int usernameMaxLength = 30;

  /// Edad permitida para registrarse.
  static const int minAge = 14;
  static const int maxAge = 100;

  static const int maxBioLength = 500;

  /// Tamaño máximo de la foto de perfil (igual al límite del bucket).
  static const int maxAvatarBytes = 2 * 1024 * 1024;

  /// El código que llega al correo tiene entre 6 y 10 dígitos
  /// (depende de la configuración de Supabase; por defecto, 6).
  static const int otpMinLength = 6;
  static const int otpMaxLength = 10;

  // Publicaciones (las mismas reglas están en la base de datos).
  static const int postMaxLength = 2000;
  static const int postMaxImages = 5;
  static const int postMaxTags = 5;
  static const int postMaxTagLength = 30;

  /// Fotos de publicaciones: máximo 5 MB cada una (ya comprimidas).
  static const int postMaxImageBytes = 5 * 1024 * 1024;

  /// Video corto: máximo 20 MB (límite del bucket "posts") y, al grabarlo
  /// con la cámara, 30 segundos.
  static const int postMaxVideoBytes = 20 * 1024 * 1024;
  static const Duration postMaxVideoDuration = Duration(seconds: 30);
}
