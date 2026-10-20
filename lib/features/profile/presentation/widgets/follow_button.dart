import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/data_failure_message.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../feed/di/feed_providers.dart';

/// Botón Seguir / Siguiendo para las listas de personas. Cambia al
/// instante y, si falla, vuelve como estaba.
class FollowButton extends ConsumerStatefulWidget {
  const FollowButton({
    super.key,
    required this.userId,
    required this.initiallyFollowing,
  });

  final String userId;
  final bool initiallyFollowing;

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  late bool _following = widget.initiallyFollowing;
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    final l10n = context.l10n;
    final following = !_following;
    setState(() {
      _following = following;
      _busy = true;
    });

    final result = await ref
        .read(toggleFollowProvider)
        .call(widget.userId, following: following);
    if (!mounted) return;

    setState(() {
      _busy = false;
      if (result is Err) _following = !following;
    });
    if (result case Err(:final error)) {
      context.showSnackBar(error.message(l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(104, 36)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 14),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      visualDensity: VisualDensity.compact,
    );

    return _following
        ? OutlinedButton(
            onPressed: _toggle,
            style: style.merge(
              OutlinedButton.styleFrom(foregroundColor: AppColors.tintaSuave),
            ),
            child: Text(l10n.profileFollowing),
          )
        : FilledButton(
            onPressed: _toggle,
            style: style,
            child: Text(l10n.profileFollow),
          );
  }
}
