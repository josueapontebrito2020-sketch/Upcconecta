import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/academic_program.dart';
import '../entities/faculty.dart';

/// Contrato para consultar las facultades y carreras de la universidad.
abstract interface class AcademicRepository {
  Future<Result<List<Faculty>, DataFailure>> getFaculties();

  Future<Result<List<AcademicProgram>, DataFailure>> getPrograms(int facultyId);
}
