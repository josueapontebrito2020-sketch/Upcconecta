import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_summary.dart';

/// Convierte una fila de la vista `profile_details` en un [UserProfile].
/// [private] trae el correo, celular y fecha de nacimiento (solo el propio).
UserProfile profileFromRow(
  Map<String, dynamic> row, {
  Map<String, dynamic>? private,
}) {
  final birthDate = private?['birth_date'];
  return UserProfile(
    id: row['id'] as String,
    username: (row['username'] as String?) ?? '',
    fullName: (row['full_name'] as String?) ?? '',
    createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
    avatarUrl: row['avatar_url'] as String?,
    bio: (row['bio'] as String?) ?? '',
    role: (row['role'] as String?) ?? 'estudiante',
    isVerified: row['is_verified'] == true,
    facultyId: _toIntOrNull(row['faculty_id']),
    programId: _toIntOrNull(row['program_id']),
    facultyName: row['faculty_name'] as String?,
    programName: row['program_name'] as String?,
    ratingAverage: _toDouble(row['rating_avg']),
    ratingCount: _toIntOrNull(row['rating_count']) ?? 0,
    followersCount: _toIntOrNull(row['followers_count']) ?? 0,
    followingCount: _toIntOrNull(row['following_count']) ?? 0,
    postsCount: _toIntOrNull(row['posts_count']) ?? 0,
    likesCount: _toIntOrNull(row['likes_count']) ?? 0,
    recentViewsCount: _toIntOrNull(row['recent_views_count']) ?? 0,
    isMine: row['is_mine'] == true,
    isFollowing: row['is_following'] == true,
    email: private?['email'] as String?,
    phone: private?['phone'] as String?,
    birthDate: birthDate is String ? DateTime.tryParse(birthDate) : null,
  );
}

/// Convierte una fila de las funciones `search_users`, `get_followers`,
/// `get_following` o `get_profile_viewers` en un [UserSummary].
UserSummary userSummaryFromRow(Map<String, dynamic> row) {
  final viewedAt = row['viewed_at'];
  return UserSummary(
    id: row['id'] as String,
    username: (row['username'] as String?) ?? '',
    fullName: (row['full_name'] as String?) ?? '',
    avatarUrl: row['avatar_url'] as String?,
    isVerified: row['is_verified'] == true,
    isFollowing: row['is_following'] == true,
    viewedAt: viewedAt is String ? DateTime.parse(viewedAt).toLocal() : null,
  );
}

int? _toIntOrNull(Object? value) => switch (value) {
  final num number => number.toInt(),
  final String text => int.tryParse(text),
  _ => null,
};

double _toDouble(Object? value) => switch (value) {
  final num number => number.toDouble(),
  final String text => double.tryParse(text) ?? 0,
  _ => 0,
};
