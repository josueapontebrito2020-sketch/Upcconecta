import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Opciones del menú ≡ del perfil.
enum ProfileMenuOption { editProfile, share, settings, signOut, report }

/// Menú ≡ ("más opciones del perfil"). En el propio: editar, compartir,
/// configuración y cerrar sesión; en uno ajeno: compartir y reportar.
Future<ProfileMenuOption?> showProfileMenuSheet(
  BuildContext context, {
  required bool isMine,
}) {
  final l10n = context.l10n;

  Widget option(
    BuildContext sheetContext,
    IconData icon,
    String label,
    ProfileMenuOption value, {
    bool danger = false,
  }) {
    final color = danger ? AppColors.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: () => Navigator.of(sheetContext).pop(value),
    );
  }

  return showModalBottomSheet<ProfileMenuOption>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.superficie,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMine) ...[
              option(
                sheetContext,
                Icons.edit_outlined,
                l10n.profileEdit,
                ProfileMenuOption.editProfile,
              ),
              option(
                sheetContext,
                Icons.ios_share_rounded,
                l10n.profileShare,
                ProfileMenuOption.share,
              ),
              option(
                sheetContext,
                Icons.settings_outlined,
                l10n.profileSettings,
                ProfileMenuOption.settings,
              ),
              option(
                sheetContext,
                Icons.logout_rounded,
                l10n.signOutButton,
                ProfileMenuOption.signOut,
                danger: true,
              ),
            ] else ...[
              option(
                sheetContext,
                Icons.ios_share_rounded,
                l10n.profileShare,
                ProfileMenuOption.share,
              ),
              option(
                sheetContext,
                Icons.flag_outlined,
                l10n.profileReport,
                ProfileMenuOption.report,
                danger: true,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Confirma antes de cerrar sesión.
Future<bool> confirmSignOut(BuildContext context) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.signOutConfirmTitle),
      content: Text(l10n.signOutConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(l10n.signOutButton),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
