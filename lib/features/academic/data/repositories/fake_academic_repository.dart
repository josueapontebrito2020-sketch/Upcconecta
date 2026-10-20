import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/academic_program.dart';
import '../../domain/entities/faculty.dart';
import '../../domain/repositories/academic_repository.dart';

/// Versión de prueba con las mismas facultades y carreras que carga la
/// migración `20261020120000_registro_facultades_y_avatares.sql`.
/// Se usa en las pruebas y cuando la app corre sin Supabase.
class FakeAcademicRepository implements AcademicRepository {
  const FakeAcademicRepository();

  static const List<Faculty> _faculties = [
    Faculty(id: 1, name: 'Facultad de Ciencias Administrativas, Contables y Económicas'),
    Faculty(id: 2, name: 'Facultad de Bellas Artes'),
    Faculty(id: 3, name: 'Facultad de Derecho, Ciencias Políticas y Sociales'),
    Faculty(id: 4, name: 'Facultad de Ciencias Básicas'),
    Faculty(id: 5, name: 'Facultad de Ingenierías y Tecnologías'),
    Faculty(id: 6, name: 'Facultad de Ciencias de la Salud'),
    Faculty(id: 7, name: 'Facultad de Educación'),
  ];

  static const List<AcademicProgram> _programs = [
    AcademicProgram(id: 1, facultyId: 1, name: 'Administración de Empresas'),
    AcademicProgram(id: 2, facultyId: 1, name: 'Administración de Empresas Turísticas y Hoteleras'),
    AcademicProgram(id: 3, facultyId: 1, name: 'Comercio Internacional'),
    AcademicProgram(id: 4, facultyId: 1, name: 'Contaduría Pública'),
    AcademicProgram(id: 5, facultyId: 1, name: 'Economía'),
    AcademicProgram(id: 6, facultyId: 2, name: 'Licenciatura en Artes'),
    AcademicProgram(id: 7, facultyId: 2, name: 'Música'),
    AcademicProgram(id: 8, facultyId: 3, name: 'Derecho'),
    AcademicProgram(id: 9, facultyId: 3, name: 'Psicología'),
    AcademicProgram(id: 10, facultyId: 3, name: 'Sociología'),
    AcademicProgram(id: 11, facultyId: 4, name: 'Microbiología'),
    AcademicProgram(id: 12, facultyId: 5, name: 'Ingeniería Agroindustrial'),
    AcademicProgram(id: 13, facultyId: 5, name: 'Ingeniería Ambiental y Sanitaria'),
    AcademicProgram(id: 14, facultyId: 5, name: 'Ingeniería de Sistemas'),
    AcademicProgram(id: 15, facultyId: 5, name: 'Ingeniería Electrónica'),
    AcademicProgram(id: 16, facultyId: 6, name: 'Enfermería'),
    AcademicProgram(id: 17, facultyId: 6, name: 'Fisioterapia'),
    AcademicProgram(id: 18, facultyId: 6, name: 'Instrumentación Quirúrgica'),
    AcademicProgram(id: 19, facultyId: 7, name: 'Licenciatura en Ciencias Naturales y Educación Ambiental'),
    AcademicProgram(id: 20, facultyId: 7, name: 'Licenciatura en Educación Física, Recreación y Deportes'),
    AcademicProgram(id: 21, facultyId: 7, name: 'Licenciatura en Español e Inglés'),
    AcademicProgram(id: 22, facultyId: 7, name: 'Licenciatura en Literatura y Lengua Castellana'),
    AcademicProgram(id: 23, facultyId: 7, name: 'Licenciatura en Matemáticas'),
  ];

  @override
  Future<Result<List<Faculty>, DataFailure>> getFaculties() async {
    return const Ok(_faculties);
  }

  @override
  Future<Result<List<AcademicProgram>, DataFailure>> getPrograms(
    int facultyId,
  ) async {
    return Ok([
      for (final program in _programs)
        if (program.facultyId == facultyId) program,
    ]);
  }
}
