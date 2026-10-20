import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente de Supabase ya inicializado en `main.dart`. Los repositorios lo
/// reciben desde aquí; nunca llaman a `Supabase.instance` por su cuenta.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
