import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/report_reason.dart';

/// Lo que se eligió en los tres puntos de una publicación.
enum PostOption { hide, report, delete }

/// Hoja inferior con las opciones de la publicación: ocultar o reportar; si
/// es propia ([isMine]), eliminar.
Future<PostOption?> showPostOptionsSheet(
  BuildContext context, {
    required bool isMine,
}) {
  final l10n = context.l10n;

  return showModalBottomSheet<PostOption>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.superficie,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMine) ...[
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                title: Text(
                  l10n.postDelete,
                  style: const TextStyle(color: AppColors.error),
                ),
                subtitle: Text(l10n.postDeleteHint),
                onTap: () => Navigator.of(context).pop(PostOption.delete),
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined),
                title: Text(l10n.postHide),
                subtitle: Text(l10n.postHideHint),
                onTap: () => Navigator.of(context).pop(PostOption.hide),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: AppColors.error),
                title: Text(
                  l10n.postReport,
                  style: const TextStyle(color: AppColors.error),
                ),
                subtitle: Text(l10n.postReportHint),
                onTap: () => Navigator.of(context).pop(PostOption.report),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Confirma antes de borrar una publicación propia.
Future<bool> confirmDeletePost(BuildContext context) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.postDeleteTitle),
      content: Text(l10n.postDeleteMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(l10n.postDeleteConfirm),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Pregunta el motivo del reporte. Devuelve null si se canceló.
Future<ReportReason?> showReportReasonDialog(BuildContext context) {
  final l10n = context.l10n;

  String label(ReportReason reason) {
    return switch (reason) {
      ReportReason.spam => l10n.reportSpam,
      ReportReason.inappropriate => l10n.reportInappropriate,
      ReportReason.fraud => l10n.reportFraud,
      ReportReason.other => l10n.reportOther,
    };
  }

  return showDialog<ReportReason>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l10n.postReportTitle),
      children: [
        for (final reason in ReportReason.values)
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(reason),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Text(label(reason)),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelButton),
            ),
          ),
        ),
      ],
    ),
  );
}
