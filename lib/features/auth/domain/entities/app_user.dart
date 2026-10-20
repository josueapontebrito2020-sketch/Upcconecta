/// Usuario autenticado. No depende de Supabase: la capa `data` convierte el
/// usuario del proveedor a esta clase.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.emailVerified,
  });

  final String id;
  final String email;
  final String displayName;
  final bool emailVerified;

  /// Primer nombre, para saludos ("Hola, Ana").
  String get firstName {
    final name = displayName.trim();
    if (name.isEmpty) return email.split('@').first;
    return name.split(RegExp(r'\s+')).first;
  }

  AppUser copyWith({String? displayName, bool? emailVerified}) {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
