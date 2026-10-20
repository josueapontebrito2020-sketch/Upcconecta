import 'dart:typed_data';

/// Foto de perfil elegida en el teléfono, lista para subir.
class ProfilePhoto {
  const ProfilePhoto({required this.bytes, required this.extension});

  final Uint8List bytes;

  /// Extensión sin punto y en minúsculas: "jpg", "png" o "webp".
  final String extension;

  static const Set<String> allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  String get contentType => switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };
}
