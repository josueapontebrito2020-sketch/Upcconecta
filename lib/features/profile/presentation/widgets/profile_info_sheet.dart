import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../domain/entities/user_profile.dart';

/// "Ver más información del perfil" (▼ junto al nombre): facultad,
/// carrera, rol, calificación y desde cuándo está en UpcConecta.
Future<void> showProfileInfoSheet(BuildContext context, UserProfile profile) {
  final l10n = context.l10n;
  final textTheme = Theme.of(context).textTheme;
  final notSet = l10n.profileNotSet;

  Widget row(IconData icon, String label, Widget value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.verdeUpc),
      title: Text(label, style: textTheme.bodySmall),
      subtitle: DefaultTextStyle.merge(
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        child: value,
      ),
    );
  }

  final role = switch (profile.role) {
    'profesor' => l10n.roleTeacher,
    'admin' => l10n.roleAdmin,
    _ => l10n.roleStudent,
  };

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: AppColors.superficie,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                profile.displayName,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 4),
            row(Icons.badge_outlined, l10n.profileRole, Text(role)),
            row(
              Icons.account_balance_outlined,
              l10n.facultyLabel,
              Text(profile.facultyName ?? notSet),
            ),
            row(
              Icons.school_outlined,
              l10n.programLabel,
              Text(profile.programName ?? notSet),
            ),
            row(
              Icons.star_outline_rounded,
              l10n.profileRating,
              profile.ratingCount == 0
                  ? Text(l10n.postNoRatings)
                  : Row(
                      children: [
                        StarRating(value: profile.ratingAverage),
                        const SizedBox(width: 6),
                        Text(
                          '${profile.ratingAverage.toStringAsFixed(1)} · '
                          '${l10n.postReviews(profile.ratingCount)}',
                        ),
                      ],
                    ),
            ),
            row(
              Icons.grid_view_rounded,
              l10n.profilePostsCount,
              Text('${profile.postsCount}'),
            ),
            row(
              Icons.event_outlined,
              l10n.profileMemberSince,
              Text(formatDayMonthYear(profile.createdAt)),
            ),
          ],
        ),
      ),
    ),
  );
}
