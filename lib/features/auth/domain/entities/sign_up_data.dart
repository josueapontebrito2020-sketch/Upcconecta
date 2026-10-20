/// Datos del formulario de registro. La foto de perfil va aparte porque se
/// sube después de verificar el correo (hasta entonces no hay sesión).
class SignUpData {
  const SignUpData({
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.birthDate,
    required this.facultyId,
    required this.programId,
    this.phone,
    this.bio = '',
  });

  final String fullName;
  final String username;
  final String email;
  final String password;
  final DateTime birthDate;
  final int facultyId;
  final int programId;

  /// Celular colombiano de 10 dígitos, o `null` si no lo dio.
  final String? phone;
  final String bio;

  SignUpData copyWith({String? email, String? username}) {
    return SignUpData(
      fullName: fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password,
      birthDate: birthDate,
      facultyId: facultyId,
      programId: programId,
      phone: phone,
      bio: bio,
    );
  }
}
