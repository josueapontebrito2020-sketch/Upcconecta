import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/data_failure_message.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../controllers/edit_profile_controller.dart';
import '../controllers/profile_controller.dart';
import '../providers/profile_providers.dart';
import '../widgets/avatar_picker.dart';
import 'edit_profile_field_page.dart';

/// "Editar perfil", al estilo TikTok: la foto arriba con "Cambiar foto" y
/// los datos en tarjetas; cada fila abre su pantalla para editarlo.
class EditProfilePage extends ConsumerWidget {
  const EditProfilePage({super.key});

  Future<void> _changePhoto(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    ImageSource? source = ImageSource.gallery;
    if (!kIsWeb) {
      source = await showModalBottomSheet<ImageSource>(
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
    if (source == null || !context.mounted) return;

    final photo = await AvatarPicker.pickPhoto(context, source);
    if (photo == null || !context.mounted) return;

    final saved = await ref
        .read(editProfileControllerProvider.notifier)
        .changePhoto(photo);
    if (!context.mounted) return;
    context.showSnackBar(saved ? l10n.profilePhotoSaved : l10n.errorUnknown);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const SizedBox.shrink();

    final state = ref.watch(profileControllerProvider(userId));
    final saving = ref.watch(editProfileControllerProvider).isLoading;
    final profile = state.value;

    final Widget body;
    if (profile == null) {
      final error = state.error;
      body = Center(
        child: state.hasError
            ? Text(
                error is DataFailure ? error.message(l10n) : l10n.errorUnknown,
              )
            : const CircularProgressIndicator(),
      );
    } else {
      void open(ProfileField field) =>
          context.push(AppRoutes.editProfileFieldPath(field.path));

      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Center(
            child: Semantics(
              button: true,
              label: l10n.photoChange,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: saving ? null : () => _changePhoto(context, ref),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    UserAvatar(
                      name: profile.displayName,
                      imageUrl: profile.avatarUrl,
                      size: 104,
                    ),
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: saving
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.photo_camera_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: saving ? null : () => _changePhoto(context, ref),
              child: Text(l10n.photoChange),
            ),
          ),
          const SizedBox(height: 8),
          _Card(
            children: [
              _Row(
                label: l10n.fullNameLabel,
                value: profile.fullName,
                onTap: () => open(ProfileField.fullName),
              ),
              _Row(
                label: l10n.usernameLabel,
                value: '@${profile.username}',
                onTap: () => open(ProfileField.username),
              ),
            ],
          ),
          _SectionTitle(l10n.editProfileBasicInfo),
          _Card(
            children: [
              _Row(
                label: l10n.editProfileBio,
                value: profile.bio,
                placeholder: l10n.editProfileAddBio,
                multiline: true,
                onTap: () => open(ProfileField.bio),
              ),
              _Row(
                label: l10n.editProfilePhone,
                value: profile.phone ?? '',
                placeholder: l10n.editProfileAddPhone,
                onTap: () => open(ProfileField.phone),
              ),
              _Row(
                label: l10n.editProfileStudies,
                value: [
                  profile.programName,
                  profile.facultyName,
                ].whereType<String>().join('\n'),
                placeholder: l10n.editProfileAddStudies,
                multiline: true,
                onTap: () => open(ProfileField.studies),
              ),
            ],
          ),
          _SectionTitle(l10n.editProfilePrivateInfo),
          _Card(
            children: [
              _Row(
                label: l10n.emailLabel,
                value: profile.email ?? '',
                placeholder: l10n.profileNotSet,
              ),
              _Row(
                label: l10n.birthDateLabel,
                value: profile.birthDate == null
                    ? ''
                    : formatDayMonthYear(profile.birthDate!),
                placeholder: l10n.profileNotSet,
                onTap: () => open(ProfileField.birthDate),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Text(
              l10n.editProfilePrivateHint,
              style: textTheme.bodySmall,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: Text(l10n.profileEdit),
        centerTitle: true,
        backgroundColor: AppColors.fondo,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: body,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.tintaSuave,
        ),
      ),
    );
  }
}

/// Tarjeta blanca con filas, como en TikTok.
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.superficie,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

/// Fila "Etiqueta — valor ›". Sin [onTap] es solo lectura (sin flecha).
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.placeholder,
    this.onTap,
    this.multiline = false,
  });

  final String label;
  final String value;
  final String? placeholder;
  final VoidCallback? onTap;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final empty = value.trim().isEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.tintaSuave,
                ),
              ),
            ),
            Expanded(
              child: Text(
                empty ? (placeholder ?? '') : value,
                maxLines: multiline ? 4 : 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: empty ? FontWeight.w400 : FontWeight.w600,
                  color: empty ? AppColors.tintaSuave : AppColors.tinta,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.tintaSuave,
              ),
          ],
        ),
      ),
    );
  }
}
