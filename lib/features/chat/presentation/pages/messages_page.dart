import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/coming_soon_view.dart';

/// Pestaña "Mensajes": chats uno a uno (siguiente fase).
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: AppColors.fondo,
      child: SafeArea(
        bottom: false,
        child: ComingSoonView(
          icon: Icons.chat_bubble_outline_rounded,
          title: l10n.messagesTitle,
          message: l10n.messagesMessage,
        ),
      ),
    );
  }
}
