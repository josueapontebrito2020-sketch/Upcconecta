import 'dart:typed_data';

/// Tipo de archivo adjunto a una publicación.
enum PostMediaType { image, video }

/// Imagen o video de una publicación.
class PostMedia {
  const PostMedia({
    required this.url,
    required this.type,
    this.thumbnailUrl,
    this.bytes,
  });

  final String url;
  final PostMediaType type;

  /// Miniatura del video, si existe.
  final String? thumbnailUrl;

  /// Archivo aún sin subir (vista previa al publicar). Si no es null, se
  /// muestra este en vez de [url].
  final Uint8List? bytes;

  bool get isVideo => type == PostMediaType.video;
}
