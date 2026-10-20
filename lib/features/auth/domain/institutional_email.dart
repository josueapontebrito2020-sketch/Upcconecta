import '../../../core/constants/app_constants.dart';

// Regla principal de UpcConecta: solo entran correos institucionales.
// Se valida en el formulario, en los casos de uso y en la base de datos
// (ver supabase/migrations).

final RegExp _institutionalEmail = RegExp(
  '^[a-z0-9._%+-]+@${RegExp.escape(AppConstants.institutionalDomain)}\$',
);

/// Quita espacios y pasa a minúsculas: " Ana@UNICESAR.edu.co " → "ana@unicesar.edu.co".
String normalizeEmail(String email) => email.trim().toLowerCase();

bool isInstitutionalEmail(String email) {
  return _institutionalEmail.hasMatch(normalizeEmail(email));
}
