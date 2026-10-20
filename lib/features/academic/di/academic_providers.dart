import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env.dart';
import '../../../core/di/supabase_providers.dart';
import '../../../core/errors/result.dart';
import '../data/repositories/fake_academic_repository.dart';
import '../data/repositories/supabase_academic_repository.dart';
import '../domain/entities/academic_program.dart';
import '../domain/entities/faculty.dart';
import '../domain/repositories/academic_repository.dart';
import '../domain/usecases/get_faculties.dart';
import '../domain/usecases/get_programs.dart';

// Inyección de dependencias del módulo académico (facultades y carreras).

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  if (AppEnv.hasSupabase) {
    return SupabaseAcademicRepository(ref.watch(supabaseClientProvider));
  }
  return const FakeAcademicRepository();
});

final getFacultiesProvider = Provider<GetFaculties>((ref) {
  return GetFaculties(ref.watch(academicRepositoryProvider));
});

final getProgramsProvider = Provider<GetPrograms>((ref) {
  return GetPrograms(ref.watch(academicRepositoryProvider));
});

/// Lista de facultades lista para mostrar. Si falla, queda en estado de
/// error y la pantalla ofrece reintentar con `ref.invalidate`.
final facultiesProvider = FutureProvider<List<Faculty>>((ref) async {
  final result = await ref.watch(getFacultiesProvider).call();
  return switch (result) {
    Ok(:final value) => value,
    Err(:final error) => throw error,
  };
});

/// Carreras de la facultad indicada.
final programsProvider = FutureProvider.family<List<AcademicProgram>, int>((
  ref,
  facultyId,
) async {
  final result = await ref.watch(getProgramsProvider).call(facultyId);
  return switch (result) {
    Ok(:final value) => value,
    Err(:final error) => throw error,
  };
});
