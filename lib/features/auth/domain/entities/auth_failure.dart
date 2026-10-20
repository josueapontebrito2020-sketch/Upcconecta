/// Motivos por los que puede fallar una operación de autenticación.
/// El texto que ve el usuario está en `presentation/auth_failure_message.dart`.
enum AuthFailure {
  invalidCredentials,
  emailAlreadyInUse,
  usernameTaken,
  nonInstitutionalEmail,
  weakPassword,
  samePassword,
  emailNotVerified,
  invalidCode,
  emailDeliveryFailed,
  tooManyRequests,
  network,
  unknown,
}
