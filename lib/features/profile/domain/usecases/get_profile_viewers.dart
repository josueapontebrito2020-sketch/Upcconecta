import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/user_summary.dart';
import '../repositories/profile_repository.dart';

/// Quién visitó mi perfil en los últimos 30 días.
class GetProfileViewers {
  const GetProfileViewers(this._repository);

  final ProfileRepository _repository;

  Future<Result<List<UserSummary>, DataFailure>> call() {
    return _repository.getProfileViewers();
  }
}
