import 'dart:typed_data';

import 'post_category.dart';
import 'post_media.dart';

/// Foto o video elegido en el teléfono, listo para subir.
class NewPostMedia {
  const NewPostMedia({
    required this.bytes,
    required this.extension,
    required this.type,
  });

  final Uint8List bytes;

  /// Extensión sin punto y en minúsculas: jpg, png, webp, mp4, mov o webm.
  final String extension;
  final PostMediaType type;

  bool get isVideo => type == PostMediaType.video;

  static const Set<String> imageExtensions = {'jpg', 'jpeg', 'png', 'webp'};
  static const Set<String> videoExtensions = {'mp4', 'mov', 'webm'};

  String get contentType => switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    'mp4' => 'video/mp4',
    'mov' => 'video/quicktime',
    'webm' => 'video/webm',
    _ => 'image/jpeg',
  };
}

/// Publicación nueva, tal como la llenó el usuario en "Publicar".
///
/// Reglas: texto obligatorio, hasta 5 etiquetas y hasta 5 fotos o 1 video.
class NewPost {
  const NewPost({
    required this.text,
    required this.category,
    this.tags = const [],
    this.media = const [],
  });

  final String text;
  final PostCategory category;
  final List<String> tags;
  final List<NewPostMedia> media;
}
