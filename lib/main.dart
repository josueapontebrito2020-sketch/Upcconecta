import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicense();

  // Sin las claves (env/dev.json) la app arranca con la autenticación de
  // prueba en memoria. Ver README.
  if (AppEnv.hasSupabase) {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      publishableKey: AppEnv.supabasePublishableKey,
    );
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
