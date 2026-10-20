import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/user_profile.dart';

/// Parte de arriba del perfil (según el boceto): nombre con ▼ para ver más
/// información, @usuario, descripción y la foto a la derecha; debajo,
/// Siguiendo · Seguidores · Me gusta y, en perfiles ajenos, los botones
/// Seguir y Mensaje.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onInfoTap,
    required this.onFollowingTap,
    required this.onFollowersTap,
    required this.onLikesTap,
    this.onFollowTap,
    this.onMessageTap,
  });

  final UserProfile profile;
  final VoidCallback onInfoTap;
  final VoidCallback onFollowingTap;
  final VoidCallback onFollowersTap;
  final VoidCallback onLikesTap;

  /// Solo en perfiles ajenos.
  final VoidCallback? onFollowTap;
  final VoidCallback? onMessageTap;

  static final NumberFormat _compact = NumberFormat.compact(locale: 'es');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final followTap = onFollowTap;
    final messageTap = onMessageTap;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onInfoTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (profile.isVerified) ...[
                            const SizedBox(width: 4),
                            Tooltip(
                              message: l10n.postVerified,
                              child: const Icon(
                                Icons.verified,
                                size: 20,
                                color: AppColors.verdeUpc,
                              ),
                            ),
                          ],
                          Tooltip(
                            message: l10n.profileMoreInfo,
                            child: const Icon(Icons.arrow_drop_down_rounded),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '@${profile.username}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.tintaSuave,
                      ),
                    ),
                    if (profile.bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        profile.bio,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.tinta,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.superficie, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.verdeProfundo.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: UserAvatar(
                  name: profile.displayName,
                  imageUrl: profile.avatarUrl,
                  size: 92,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(
                value: _compact.format(profile.followingCount),
                label: l10n.profileFollowingCount,
                onTap: onFollowingTap,
              ),
              _Stat(
                value: _compact.format(profile.followersCount),
                label: l10n.profileFollowersCount,
                onTap: onFollowersTap,
              ),
              _Stat(
                value: _compact.format(profile.likesCount),
                label: l10n.profileLikesCount,
                onTap: onLikesTap,
              ),
            ],
          ),
          if (followTap != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: profile.isFollowing
                      ? OutlinedButton(
                          onPressed: followTap,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                          ),
                          child: Text(l10n.profileFollowing),
                        )
                      : FilledButton.icon(
                          onPressed: followTap,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                          ),
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: Text(l10n.profileFollow),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: messageTap,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: Text(l10n.profileMessage),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.onTap});

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.tinta,
                ),
              ),
              Text(label, style: textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
