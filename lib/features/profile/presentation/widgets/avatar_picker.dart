import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile_photo.dart';

/// Círculo con la foto de perfil. Al tocarlo deja elegir una foto de la
/// galería o tomarla con la cámara (en la web, solo galería).
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.photo,
    required this.onChanged,
    this.enabled = true,
  });

  final ProfilePhoto? photo;
  final ValueChanged<ProfilePhoto?> onChanged;
  final bool enabled;

  static const double _radius = 48;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final picked = await pickPhoto(context, source);
    if (picked != null) onChanged(picked);
  }

  /// Abre la galería o la cámara y devuelve la foto lista para subir, o
  /// null si se canceló o no sirve (en ese caso muestra el aviso).
  /// La usa también "Editar perfil".
  static Future<ProfilePhoto?> pickPhoto(
    BuildContext context,
    ImageSource source,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (file == null) return null;

    final extension = _extensionOf(file);
    if (!ProfilePhoto.allowedExtensions.contains(extension)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoInvalidType)));
      return null;
    }

    final bytes = await file.readAsBytes();
    if (bytes.length > AppConstants.maxAvatarBytes) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoTooLarge)));
      return null;
    }

    return ProfilePhoto(
      bytes: bytes,
      extension: extension == 'jpeg' ? 'jpg' : extension,
    );
  }

  static String _extensionOf(XFile file) {
    final name = file.name.toLowerCase();
    final dot = name.lastIndexOf('.');
    if (dot != -1 && dot < name.length - 1) return name.substring(dot + 1);

    final mimeType = file.mimeType ?? '';
    if (mimeType.contains('png')) return 'png';
    if (mimeType.contains('webp')) return 'webp';
    return 'jpg';
  }

  void _showOptions(BuildContext context) {
    final l10n = context.l10n;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.photoFromGallery),
              onTap: () {
                Navigator.pop(sheetContext);
                _pick(context, ImageSource.gallery);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.photoFromCamera),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pick(context, ImageSource.camera);
                },
              ),
            if (photo != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.photoRemove),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onChanged(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentPhoto = photo;

    return Column(
      children: [
        Semantics(
          button: true,
          label: currentPhoto == null ? l10n.photoAdd : l10n.photoChange,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? () => _showOptions(context) : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: _radius,
                  backgroundColor: AppColors.campo,
                  backgroundImage: currentPhoto == null
                      ? null
                      : MemoryImage(currentPhoto.bytes),
                  child: currentPhoto == null
                      ? const Icon(
                          Icons.person_outline,
                          size: _radius,
                          color: AppColors.tintaSuave,
                        )
                      : null,
                ),
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.verdeUpc,
                    child: Icon(
                      Icons.photo_camera,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: enabled ? () => _showOptions(context) : null,
          child: Text(currentPhoto == null ? l10n.photoAdd : l10n.photoChange),
        ),
        Text(l10n.photoOptional, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
