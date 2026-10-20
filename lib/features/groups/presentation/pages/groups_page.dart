import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/coming_soon_view.dart';

/// Pestaña "Grupos": chats grupales de estudio y de juegos (siguiente fase).
class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: AppColors.fondo,
      child: SafeArea(
        bottom: false,
        child: ComingSoonView(
          icon: Icons.groups_outlined,
          title: l10n.groupsTitle,
          message: l10n.groupsMessage,
        ),
      ),
    );
  }
}
