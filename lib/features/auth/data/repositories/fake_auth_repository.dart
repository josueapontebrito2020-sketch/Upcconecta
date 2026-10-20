import 'dart:async';

import '../../../../core/errors/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/sign_up_data.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementación de prueba (*test double*) que guarda las cuentas en memoria.
///
/// Se usa en las pruebas automáticas y cuando la app se corre sin las claves
/// de Supabase, para poder trabajar en las pantallas sin conexión.
///
/// - Cuenta de prueba: demo@unicesar.edu.co / Demo1234
/// - Código de verificación (registro y recuperar contraseña): 123456
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.latency = const Duration(milliseconds: 700)}) {
    _accounts[demoEmail] = _FakeAccount(
      user: const AppUser(
        id: 'demo',
        email: demoEmail,
        displayName: 'Estudiante Demo',
        emailVerified: true,
      ),
      password: demoPassword,
      username: 'demo',
    );
  }

  static const String demoEmail = 'demo@unicesar.edu.co';
  static const String demoPassword = 'Demo1234';
  static const String verificationCode = '123456';

  /// Demora simulada de la red, para ver los estados de carga.
  final Duration latency;

  final Map<String, _FakeAccount> _accounts = {};
  final StreamController<AppUser?> _changes =
      StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() => _changes.stream;

  @override
  Future<Result<AppUser, AuthFailure>> signIn({
    required String email,
    required String password,
  }) async {
    await _simulateNetwork();
    final account = _accounts[email];
    if (account == null || account.password != password) {
      return const Err(AuthFailure.invalidCredentials);
    }
    if (!account.user.emailVerified) {
      return const Err(AuthFailure.emailNotVerified);
    }
    _setUser(account.user);
    return Ok(account.user);
  }

  @override
  Future<Result<void, AuthFailure>> signUp(SignUpData data) async {
    await _simulateNetwork();
    final existing = _accounts[data.email];
    if (existing != null && existing.user.emailVerified) {
      return const Err(AuthFailure.emailAlreadyInUse);
    }
    _accounts[data.email] = _FakeAccount(
      user: AppUser(
        id: 'user-${_accounts.length + 1}',
        email: data.email,
        displayName: data.fullName,
        emailVerified: false,
      ),
      password: data.password,
      username: data.username,
    );
    return const Ok(null);
  }

  @override
  Future<Result<AppUser, AuthFailure>> verifySignUpCode({
    required String email,
    required String code,
  }) async {
    await _simulateNetwork();
    final account = _accounts[email];
    if (account == null || code != verificationCode) {
      return const Err(AuthFailure.invalidCode);
    }
    final verified = account.user.copyWith(emailVerified: true);
    account.user = verified;
    _setUser(verified);
    return Ok(verified);
  }

  @override
  Future<Result<void, AuthFailure>> resendSignUpCode(String email) async {
    await _simulateNetwork();
    return const Ok(null);
  }

  @override
  Future<Result<bool, AuthFailure>> isUsernameAvailable(String username) async {
    await _simulateNetwork();
    final taken = _accounts.values.any((account) => account.username == username);
    return Ok(!taken);
  }

  @override
  Future<Result<void, AuthFailure>> sendPasswordResetCode(String email) async {
    await _simulateNetwork();
    return const Ok(null);
  }

  @override
  Future<Result<AppUser, AuthFailure>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _simulateNetwork();
    final account = _accounts[email];
    if (account == null || code != verificationCode) {
      return const Err(AuthFailure.invalidCode);
    }
    if (account.password == newPassword) {
      return const Err(AuthFailure.samePassword);
    }
    account.password = newPassword;
    final user = account.user.copyWith(emailVerified: true);
    account.user = user;
    _setUser(user);
    return Ok(user);
  }

  @override
  Future<void> signOut() async => _setUser(null);

  void dispose() => _changes.close();

  void _setUser(AppUser? user) {
    _currentUser = user;
    _changes.add(user);
  }

  Future<void> _simulateNetwork() {
    if (latency == Duration.zero) return Future<void>.value();
    return Future<void>.delayed(latency);
  }
}

class _FakeAccount {
  _FakeAccount({
    required this.user,
    required this.password,
    required this.username,
  });

  AppUser user;
  String password;
  final String username;
}
