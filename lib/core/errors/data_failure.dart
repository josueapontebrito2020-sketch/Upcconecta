/// Fallo genérico al leer o guardar datos (listas, perfil, archivos).
/// Los fallos de inicio de sesión tienen su propio tipo: `AuthFailure`.
enum DataFailure {
  /// Sin conexión o el servidor no respondió.
  network,

  /// Lo buscado no existe (ej. un perfil borrado).
  notFound,

  /// Ya existe algo igual (ej. un nombre de usuario ocupado).
  conflict,

  unknown,
}
