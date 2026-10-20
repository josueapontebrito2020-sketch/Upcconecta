import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/follow_list_type.dart';
import '../../domain/entities/profile_changes.dart';
import '../../domain/entities/profile_photo.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_summary.dart';
import '../../domain/repositories/profile_repository.dart';

/// Perfiles de prueba en memoria, para correr la app sin Supabase y para
/// las pruebas. El perfil propio es la cuenta demo (`demo`).
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.latency = const Duration(milliseconds: 400)});

  final Duration latency;

  static const String _myId = 'demo';

  UserProfile _me = UserProfile(
    id: _myId,
    username: 'demo',
    fullName: 'Estudiante Demo',
    createdAt: DateTime(2026, 10, 19),
    bio: 'Cuenta de prueba de UpcConecta 👋',
    facultyId: 5,
    programId: 14,
    facultyName: 'Facultad de Ingenierías y Tecnologías',
    programName: 'Ingeniería de Sistemas',
    followersCount: 2,
    followingCount: 1,
    likesCount: 12,
    recentViewsCount: 1,
    isMine: true,
    email: 'demo@unicesar.edu.co',
  );

  static const List<UserSummary> _people = [
    UserSummary(
      id: 'u1',
      username: 'vale.rios',
      fullName: 'Valentina Ríos',
      isVerified: true,
    ),
    UserSummary(id: 'u2', username: 'andres.dev', fullName: 'Andrés Mejía'),
    UserSummary(id: 'u3', username: 'lau.tutorias', fullName: 'Laura Pérez'),
  ];

  final Set<String> _following = {'u2'};

  @override
  Future<Result<UserProfile, DataFailure>> getProfile(String userId) async {
    await Future<void>.delayed(latency);
    if (userId == _myId) return Ok(_me);

    for (final person in _people) {
      if (person.id == userId) {
        return Ok(
          UserProfile(
            id: person.id,
            username: person.username,
            fullName: person.fullName,
            isVerified: person.isVerified,
            createdAt: DateTime(2026, 9, 1),
            bio: 'Perfil de prueba.',
            followersCount: 10,
            followingCount: 4,
            likesCount: 120,
            isFollowing: _following.contains(person.id),
          ),
        );
      }
    }
    return const Err(DataFailure.notFound);
  }

  @override
  Future<Result<void, DataFailure>> updateProfile(
    ProfileChanges changes,
  ) async {
    await Future<void>.delayed(latency);
    if (changes.username != null &&
        _people.any((person) => person.username == changes.username)) {
      return const Err(DataFailure.conflict);
    }
    final me = _me;
    _me = UserProfile(
      id: me.id,
      username: changes.username ?? me.username,
      fullName: changes.fullName ?? me.fullName,
      createdAt: me.createdAt,
      avatarUrl: me.avatarUrl,
      bio: changes.bio ?? me.bio,
      facultyId: changes.facultyId ?? me.facultyId,
      programId: changes.programId ?? me.programId,
      facultyName: me.facultyName,
      programName: me.programName,
      followersCount: me.followersCount,
      followingCount: me.followingCount,
      likesCount: me.likesCount,
      recentViewsCount: me.recentViewsCount,
      isMine: true,
      email: me.email,
      phone: changes.clearPhone ? null : (changes.phone ?? me.phone),
      birthDate: changes.birthDate ?? me.birthDate,
    );
    return const Ok(null);
  }

  @override
  Future<Result<String, DataFailure>> uploadAvatar({
    required String userId,
    required ProfilePhoto photo,
  }) async {
    return Ok('memoria://avatars/$userId/avatar.${photo.extension}');
  }

  @override
  Future<Result<bool, DataFailure>> isUsernameAvailable(String username) async {
    await Future<void>.delayed(latency ~/ 2);
    return Ok(!_people.any((person) => person.username == username));
  }

  @override
  Future<Result<List<UserSummary>, DataFailure>> searchUsers(
    String query,
  ) async {
    await Future<void>.delayed(latency);
    final text = query.toLowerCase();
    return Ok([
      for (final person in _people)
        if (person.username.contains(text) ||
            person.fullName.toLowerCase().contains(text))
          _withFollow(person),
    ]);
  }

  @override
  Future<Result<List<UserSummary>, DataFailure>> getFollowList(
    String userId,
    FollowListType type,
  ) async {
    await Future<void>.delayed(latency);
    return Ok(switch (type) {
      FollowListType.followers => [
        _withFollow(_people[0]),
        _withFollow(_people[2]),
      ],
      FollowListType.following => [
        for (final person in _people)
          if (_following.contains(person.id)) _withFollow(person),
      ],
    });
  }

  @override
  Future<Result<void, DataFailure>> registerProfileView(
    String profileId,
  ) async {
    return const Ok(null);
  }

  @override
  Future<Result<List<UserSummary>, DataFailure>> getProfileViewers() async {
    await Future<void>.delayed(latency);
    final viewer = _people[0];
    return Ok([
      UserSummary(
        id: viewer.id,
        username: viewer.username,
        fullName: viewer.fullName,
        isVerified: viewer.isVerified,
        isFollowing: _following.contains(viewer.id),
        viewedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);
  }

  UserSummary _withFollow(UserSummary person) {
    return person.copyWith(isFollowing: _following.contains(person.id));
  }
}
