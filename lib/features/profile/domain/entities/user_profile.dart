/// Perfil de una persona, como se muestra en la pestaña Perfil.
///
/// Los datos privados ([email], [phone], [birthDate]) solo vienen llenos en
/// el perfil propio ([isMine]).
class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.createdAt,
    this.avatarUrl,
    this.bio = '',
    this.role = 'estudiante',
    this.isVerified = false,
    this.facultyId,
    this.programId,
    this.facultyName,
    this.programName,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.likesCount = 0,
    this.recentViewsCount = 0,
    this.isMine = false,
    this.isFollowing = false,
    this.email,
    this.phone,
    this.birthDate,
  });

  final String id;
  final String username;
  final String fullName;
  final DateTime createdAt;
  final String? avatarUrl;
  final String bio;

  /// estudiante, profesor o admin.
  final String role;
  final bool isVerified;
  final int? facultyId;
  final int? programId;
  final String? facultyName;
  final String? programName;

  /// Calificación promedio de sus servicios (0 a 5) y número de reseñas.
  final double ratingAverage;
  final int ratingCount;

  final int followersCount;
  final int followingCount;
  final int postsCount;

  /// Me gusta recibidos en todas sus publicaciones.
  final int likesCount;

  /// Visitas al perfil en los últimos 30 días (solo en el propio).
  final int recentViewsCount;

  final bool isMine;
  final bool isFollowing;

  final String? email;
  final String? phone;
  final DateTime? birthDate;

  /// Nombre para mostrar: el nombre completo o, si no tiene, el usuario.
  String get displayName => fullName.trim().isEmpty ? username : fullName;

  UserProfile copyWith({bool? isFollowing, int? followersCount}) {
    return UserProfile(
      id: id,
      username: username,
      fullName: fullName,
      createdAt: createdAt,
      avatarUrl: avatarUrl,
      bio: bio,
      role: role,
      isVerified: isVerified,
      facultyId: facultyId,
      programId: programId,
      facultyName: facultyName,
      programName: programName,
      ratingAverage: ratingAverage,
      ratingCount: ratingCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount,
      postsCount: postsCount,
      likesCount: likesCount,
      recentViewsCount: recentViewsCount,
      isMine: isMine,
      isFollowing: isFollowing ?? this.isFollowing,
      email: email,
      phone: phone,
      birthDate: birthDate,
    );
  }
}
