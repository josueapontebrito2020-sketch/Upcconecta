import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/startup_error_app.dart';
import 'core/config/app_env.dart';

/// Tiempo máximo para conectar con Supabase al abrir la app.
const Duration _startupTimeout = Duration(seconds: 15);

bool _supabaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicense();
  await _start();
}

/// Inicia Supabase y muestra la app. Si algo falla, muestra una pantalla
/// con el error y el botón Reintentar (nunca la pantalla en negro).
Future<void> _start() async {
  try {
    // Sin las claves (env/dev.json) la app arranca con datos de prueba en
    // memoria. Ver README.
    if (AppEnv.hasSupabase && !_supabaseReady) {
      await Supabase.initialize(
        url: AppEnv.supabaseUrl,
        publishableKey: AppEnv.supabasePublishableKey,
      ).timeout(_startupTimeout);
      _supabaseReady = true;
    }
  } catch (error, stackTrace) {
    debugPrint('No se pudo iniciar la app: $error\n$stackTrace');
    runApp(StartupErrorApp(onRetry: _start));
    return;
  }

  runApp(const ProviderScope(child: UpcConectaApp()));
}

/// La licencia OFL de la fuente Libre Franklin debe acompañar la app
/// (aparece en la pantalla de licencias de Flutter).
void _registerFontLicense() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Libre Franklin'], license);
  });
}
