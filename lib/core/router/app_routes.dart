/// Nombres de las rutas. Siempre navegar con estas constantes:
/// `context.go(AppRoutes.home)`.
abstract final class AppRoutes {
  // Pestañas de la barra inferior (con sesión).
  static const String home = '/';
  static const String groups = '/grupos';
  static const String messages = '/mensajes';
  static const String profile = '/perfil';

  /// Nueva publicación (botón "+"), se abre encima de las pestañas.
  static const String createPost = '/publicar';

  /// Video en pantalla completa: `/video?url=...`.
  static const String videoViewer = '/video';

  // Perfil.
  /// Perfil de otra persona: `/usuario/<id>`.
  static const String userProfile = '/usuario/:id';
  static String userProfilePath(String userId) => '/usuario/$userId';

  /// Seguidores y seguidos: `/usuario/<id>/seguidores?ver=seguidos`.
  static const String followList = '/usuario/:id/seguidores';
  static String followListPath(String userId, {bool following = false}) =>
      '/usuario/$userId/seguidores${following ? '?ver=seguidos' : ''}';

  /// Publicaciones de una pestaña del perfil, empezando en una:
  /// `/publicaciones?usuario=<id>&tipo=<pestaña>&inicio=<id-publicación>`.
  static const String postList = '/publicaciones';

  static const String editProfile = '/editar-perfil';

  /// Editar un dato: `/editar-perfil/<campo>` (nombre, usuario,
  /// descripcion, celular, carrera).
  static const String editProfileField = '/editar-perfil/:campo';
  static String editProfileFieldPath(String field) => '/editar-perfil/$field';

  static const String searchUsers = '/buscar-usuarios';
  static const String profileViewers = '/vistas-del-perfil';

  // Acceso (sin sesión).
  static const String login = '/iniciar-sesion';
  static const String register = '/registro';
  static const String verifyEmail = '/verificar-correo';
  static const String forgotPassword = '/recuperar-contrasena';
  static const String resetPassword = '/nueva-contrasena';

  /// Rutas que se pueden ver sin sesión iniciada.
  static const Set<String> publicRoutes = {
    login,
    register,
    verifyEmail,
    forgotPassword,
    resetPassword,
  };
}
