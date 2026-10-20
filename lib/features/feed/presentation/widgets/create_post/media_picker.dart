import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/new_post.dart';
import '../../../domain/entities/post_media.dart';

/// Fotos o video de la publicación nueva: miniaturas con una X para
/// quitarlas y botones para agregar.
///
/// Reglas: hasta 5 fotos (5 MB cada una) o 1 video corto (20 MB). En el
/// celular se puede usar la cámara; en la web, solo la galería.
class MediaPicker extends StatelessWidget {
  const MediaPicker({super.key, required this.media, required this.onChanged});

  final List<NewPostMedia> media;
  final ValueChanged<List<NewPostMedia>> onChanged;

  bool get _hasVideo => media.any((file) => file.isVideo);
  int get _remainingPhotos => AppConstants.postMaxImages - media.length;
  bool get _canAddPhotos => !_hasVideo && _remainingPhotos > 0;
  bool get _canAddVideo => media.isEmpty;

  /// En el celular pregunta galería o cámara; en la web, galería.
  Future<ImageSource?> _chooseSource(BuildContext context) async {
    if (kIsWeb) return ImageSource.gallery;
    final l10n = context.l10n;
    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.photoFromGallery),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.photoFromCamera),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPhotos(BuildContext context) async {
    final l10n = context.l10n;
    final source = await _chooseSource(context);
    if (source == null || !context.mounted) return;

    final picker = ImagePicker();
    final remaining = _remainingPhotos;
    final List<XFile> files;
    if (source == ImageSource.gallery && remaining > 1) {
      files = await picker.pickMultiImage(
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
        limit: remaining,
      );
    } else {
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      files = file == null ? const [] : [file];
    }
    if (files.isEmpty || !context.mounted) return;

    final added = <NewPostMedia>[];
    var skipped = false;
    for (final file in files.take(remaining)) {
      final extension = _normalize(_extensionOf(file));
      final bytes = await file.readAsBytes();
      if (!NewPostMedia.imageExtensions.contains(extension) ||
          bytes.length > AppConstants.postMaxImageBytes) {
        skipped = true;
        continue;
      }
      added.add(
        NewPostMedia(
          bytes: bytes,
          extension: extension,
          type: PostMediaType.image,
        ),
      );
    }
    if (!context.mounted) return;

    if (skipped || files.length > remaining) {
      context.showSnackBar(
        l10n.createPostPhotosSkipped(
          AppConstants.postMaxImages,
          AppConstants.postMaxImageBytes ~/ (1024 * 1024),
        ),
      );
    }
    if (added.isNotEmpty) onChanged([...media, ...added]);
  }

  Future<void> _addVideo(BuildContext context) async {
    final l10n = context.l10n;
    final source = await _chooseSource(context);
    if (source == null || !context.mounted) return;

    final file = await ImagePicker().pickVideo(
      source: source,
      maxDuration: AppConstants.postMaxVideoDuration,
    );
    if (file == null || !context.mounted) return;

    final extension = _normalize(_extensionOf(file));
    if (!NewPostMedia.videoExtensions.contains(extension)) {
      context.showSnackBar(l10n.createPostVideoInvalid);
      return;
    }
    final bytes = await file.readAsBytes();
    if (!context.mounted) return;
    if (bytes.length > AppConstants.postMaxVideoBytes) {
      context.showSnackBar(
        l10n.createPostVideoTooLarge(
          AppConstants.postMaxVideoBytes ~/ (1024 * 1024),
        ),
      );
      return;
    }
    onChanged([
      NewPostMedia(bytes: bytes, extension: extension, type: PostMediaType.video),
    ]);
  }

  static String _normalize(String extension) => switch (extension) {
    'jpeg' => 'jpg',
    'quicktime' => 'mov',
    _ => extension,
  };

  /// Extensión del archivo; si el nombre no la tiene (pasa en la web), se
  /// deduce del tipo.
  static String _extensionOf(XFile file) {
    final name = file.name.toLowerCase();
    final dot = name.lastIndexOf('.');
    if (dot != -1 && dot < name.length - 1) return name.substring(dot + 1);

    final mimeType = file.mimeType ?? '';
    final slash = mimeType.lastIndexOf('/');
    return slash == -1 ? '' : mimeType.substring(slash + 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (media.isNotEmpty) ...[
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              final size = (constraints.maxWidth - spacing * 2) / 3;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var i = 0; i < media.length; i++)
                    _Thumbnail(
                      file: media[i],
                      size: size,
                      onRemove: () => onChanged([...media]..removeAt(i)),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: _AddButton(
                icon: Icons.add_photo_alternate_outlined,
                label: l10n.createPostAddPhotos,
                onPressed: _canAddPhotos ? () => _addPhotos(context) : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AddButton(
                icon: Icons.videocam_outlined,
                label: l10n.createPostAddVideo,
                onPressed: _canAddVideo ? () => _addVideo(context) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: AppColors.campo,
      ),
      icon: Icon(icon),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.file,
    required this.size,
    required this.onRemove,
  });

  final NewPostMedia file;
  final double size;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final megabytes = (file.bytes.length / (1024 * 1024)).toStringAsFixed(1);

    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: file.isVideo
                ? DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.verdeProfundo, AppColors.tinta],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.createPostVideoSize(megabytes),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : Image.memory(file.bytes, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black.withValues(alpha: 0.6),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: Tooltip(
                  message: l10n.createPostRemoveMedia,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
