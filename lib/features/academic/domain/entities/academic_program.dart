/// Carrera (programa de pregrado) que pertenece a una facultad.
class AcademicProgram {
  const AcademicProgram({
    required this.id,
    required this.facultyId,
    required this.name,
  });

  final int id;
  final int facultyId;
  final String name;
}
