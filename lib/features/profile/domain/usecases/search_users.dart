import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/user_summary.dart';
import '../repositories/profile_repository.dart';

/// Busca personas por nombre o usuario.
class SearchUsers {
  const SearchUsers(this._repository);

  final ProfileRepository _repository;

  /// Con menos de 2 letras no busca (devuelve la lista vacía).
  Future<Result<List<UserSummary>, DataFailure>> call(String query) async {
    final text = query.trim().replaceAll(RegExp(r'^@'), '');
    if (text.length < 2) return const Ok([]);
    return _repository.searchUsers(text);
  }
}
