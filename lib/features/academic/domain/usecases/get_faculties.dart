import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/faculty.dart';
import '../repositories/academic_repository.dart';

/// Lista de facultades, en el orden en que se muestran.
class GetFaculties {
  const GetFaculties(this._repository);

  final AcademicRepository _repository;

  Future<Result<List<Faculty>, DataFailure>> call() {
    return _repository.getFaculties();
  }
}
