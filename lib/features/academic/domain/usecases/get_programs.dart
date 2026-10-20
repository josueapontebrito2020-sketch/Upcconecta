import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/academic_program.dart';
import '../repositories/academic_repository.dart';

/// Carreras de una facultad.
class GetPrograms {
  const GetPrograms(this._repository);

  final AcademicRepository _repository;

  Future<Result<List<AcademicProgram>, DataFailure>> call(int facultyId) {
    return _repository.getPrograms(facultyId);
  }
}
