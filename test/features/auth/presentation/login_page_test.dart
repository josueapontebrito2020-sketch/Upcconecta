import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcconect/app/app.dart';
import 'package:upcconect/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:upcconect/features/auth/di/auth_providers.dart';
import 'package:upcconect/features/feed/data/repositories/fake_feed_repository.dart';
import 'package:upcconect/features/feed/di/feed_providers.dart';
import 'package:upcconect/features/profile/data/repositories/fake_profile_repository.dart';
import 'package:upcconect/features/profile/di/profile_providers.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(latency: Duration.zero),
          ),
          feedRepositoryProvider.overrideWithValue(
            FakeFeedRepository(latency: Duration.zero),
          ),
          profileRepositoryProvider.overrideWithValue(
            FakeProfileRepository(latency: Duration.zero),
          ),
        ],
        child: const UpcConectaApp(),
      ),
    );
    // Deja terminar la animación de entrada.
    await tester.pumpAndSettle();
  }

  Future<void> fillAndSubmit(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo institucional'),
      email,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      password,
    );
    final button = find.widgetWithText(FilledButton, 'Iniciar sesión');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('la app abre en la pantalla de inicio de sesión', (tester) async {
    await pumpApp(tester);

    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.bySemanticsLabel('Logo de UPC Conecta'), findsOneWidget);
  });

  testWidgets('rechaza correos que no son institucionales', (tester) async {
    await pumpApp(tester);

    await fillAndSubmit(tester, email: 'ana@gmail.com', password: 'Clave1234');

    expect(
      find.text('Usa tu correo institucional @unicesar.edu.co.'),
      findsOneWidget,
    );
  });

  testWidgets('muestra un error con contraseña incorrecta', (tester) async {
    await pumpApp(tester);

    await fillAndSubmit(
      tester,
      email: FakeAuthRepository.demoEmail,
      password: 'Incorrecta1',
    );

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
  });

  testWidgets('con la cuenta de prueba entra al inicio', (tester) async {
    await pumpApp(tester);

    await fillAndSubmit(
      tester,
      email: FakeAuthRepository.demoEmail,
      password: FakeAuthRepository.demoPassword,
    );

    // Pantalla principal: apartados arriba y barra inferior.
    expect(find.text('Comunidad'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
  });
}
