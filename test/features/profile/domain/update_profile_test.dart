import 'package:flutter_test/flutter_test.dart';
import 'package:upcconect/core/errors/data_failure.dart';
import 'package:upcconect/core/errors/result.dart';
import 'package:upcconect/features/profile/data/repositories/fake_profile_repository.dart';
import 'package:upcconect/features/profile/domain/entities/profile_changes.dart';
import 'package:upcconect/features/profile/domain/usecases/update_profile.dart';

/// Guarda los cambios que recibe para revisarlos.
class _SpyRepository extends FakeProfileRepository {
  _SpyRepository() : super(latency: Duration.zero);

  ProfileChanges? received;

  @override
  Future<Result<void, DataFailure>> updateProfile(ProfileChanges changes) {
    received = changes;
    return super.updateProfile(changes);
  }
}

void main() {
  test('limpia espacios y pasa el usuario a minúsculas', () async {
    final repository = _SpyRepository();

    await UpdateProfile(repository)(
      const ProfileChanges(fullName: '  Ana Gómez ', username: ' Ana.G '),
    );

    expect(repository.received?.fullName, 'Ana Gómez');
    expect(repository.received?.username, 'ana.g');
  });

  test('un celular vacío lo borra', () async {
    final repository = _SpyRepository();

    await UpdateProfile(repository)(const ProfileChanges(phone: '   '));

    expect(repository.received?.phone, isNull);
    expect(repository.received?.clearPhone, isTrue);
  });

  test('sin cambios no llama al repositorio', () async {
    final repository = _SpyRepository();

    final result = await UpdateProfile(repository)(const ProfileChanges());

    expect(result, isA<Ok<void, DataFailure>>());
    expect(repository.received, isNull);
  });

  test('un nombre de usuario ocupado devuelve conflict', () async {
    final result = await UpdateProfile(
      FakeProfileRepository(latency: Duration.zero),
    )(const ProfileChanges(username: 'vale.rios'));

    expect(result, isA<Err<void, DataFailure>>());
  });
}
