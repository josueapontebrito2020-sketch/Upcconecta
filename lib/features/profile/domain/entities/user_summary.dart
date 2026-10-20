/// Una persona en una lista (búsqueda, seguidores, seguidos, visitas).
class UserSummary {
  const UserSummary({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.isVerified = false,
    this.isFollowing = false,
    this.viewedAt,
  });

  final String id;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final bool isVerified;
  final bool isFollowing;

  /// Cuándo visitó mi perfil (solo en la lista de visitas).
  final DateTime? viewedAt;

  String get displayName => fullName.trim().isEmpty ? username : fullName;

  UserSummary copyWith({bool? isFollowing}) {
    return UserSummary(
      id: id,
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      isFollowing: isFollowing ?? this.isFollowing,
      viewedAt: viewedAt,
    );
  }
}
