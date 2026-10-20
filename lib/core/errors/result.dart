/// Resultado de una operación que puede fallar.
///
/// Los repositorios devuelven [Result] en vez de lanzar excepciones: la
/// interfaz siempre sabe qué pasó y Dart obliga a manejar ambos casos.
///
/// ```dart
/// switch (result) {
///   case Ok(:final value): // éxito
///   case Err(:final error): // fallo
/// }
/// ```
sealed class Result<T, E> {
  const Result();
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}
