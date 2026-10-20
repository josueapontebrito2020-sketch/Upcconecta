import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/user_summary.dart';
import '../providers/profile_providers.dart';
import 'follow_button.dart';

/// Una persona en una lista: foto, nombre, @usuario y botón Seguir. Al
/// tocarla se abre su perfil. [subtitle] reemplaza el @usuario (ej. "hace
/// 3 h" en las visitas).
class UserListTile extends ConsumerWidget {
  const UserListTile({super.key, required this.user, this.subtitle});

  final UserSummary user;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isMe = ref.watch(currentUserIdProvider) == user.id;

    return ListTile(
      onTap: () {
        if (isMe) {
          context.go(AppRoutes.profile);
        } else {
          context.push(AppRoutes.userProfilePath(user.id));
        }
      },
      leading: UserAvatar(
        name: user.displayName,
        imageUrl: user.avatarUrl,
        size: 48,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (user.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 16, color: AppColors.verdeUpc),
          ],
        ],
      ),
      subtitle: Text(
        subtitle ?? '@${user.username}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isMe
          ? null
          : FollowButton(
              key: ValueKey('follow-${user.id}'),
              userId: user.id,
              initiallyFollowing: user.isFollowing,
            ),
    );
  }
}
