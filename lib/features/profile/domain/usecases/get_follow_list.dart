import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/follow_list_type.dart';
import '../entities/user_summary.dart';
import '../repositories/profile_repository.dart';

/// Seguidores o seguidos de una persona.
class GetFollowList {
  const GetFollowList(this._repository);

  final ProfileRepository _repository;

  Future<Result<List<UserSummary>, DataFailure>> call(
    String userId,
    FollowListType type,
  ) {
    return _repository.getFollowList(userId, type);
  }
}
