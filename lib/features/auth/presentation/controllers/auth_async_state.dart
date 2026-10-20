import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/auth_failure.dart';

/// Convierte el resultado de un caso de uso en el estado de un controlador:
/// éxito → `AsyncData`, error → `AsyncError` con el [AuthFailure].
AsyncValue<void> authAsyncStateFrom<T>(Result<T, AuthFailure> result) {
  return switch (result) {
    Ok() => const AsyncData<void>(null),
    Err(:final error) => AsyncError<void>(error, StackTrace.current),
  };
}
