/// Datos que se cambian desde "Editar perfil". Solo se envían los que no
/// son null. Para borrar el celular se usa [clearPhone].
class ProfileChanges {
  const ProfileChanges({
    this.fullName,
    this.username,
    this.bio,
    this.phone,
    this.clearPhone = false,
    this.facultyId,
    this.programId,
    this.birthDate,
  });

  final String? fullName;
  final String? username;
  final String? bio;
  final String? phone;
  final bool clearPhone;
  final int? facultyId;
  final int? programId;
  final DateTime? birthDate;

  bool get isEmpty =>
      fullName == null &&
      username == null &&
      bio == null &&
      phone == null &&
      !clearPhone &&
      facultyId == null &&
      programId == null &&
      birthDate == null;
}
