import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/data_failure_message.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_ago.dart';
import '../providers/profile_providers.dart';
import '../widgets/user_list_tile.dart';

/// "Vistas del perfil": quién visitó mi perfil en los últimos 30 días.
class ProfileViewersPage extends ConsumerWidget {
  const ProfileViewersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(profileViewersProvider);

    return Scaffold(
      backgroundColor: AppColors.superficie,
      appBar: AppBar(
        title: Text(l10n.profileViewersTitle),
        centerTitle: true,
        backgroundColor: AppColors.superficie,
        surfaceTintColor: Colors.transparent,
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(profileViewersProvider),
            child: Text(
              '${error is DataFailure ? error.message(l10n) : l10n.errorUnknown}'
              ' ${l10n.retryButton}',
            ),
          ),
        ),
        data: (viewers) => RefreshIndicator(
          onRefresh: () => ref.refresh(profileViewersProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  l10n.profileViewersHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (viewers.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.profileViewersEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              for (final viewer in viewers)
                UserListTile(
                  user: viewer,
                  subtitle: viewer.viewedAt == null
                      ? null
                      : l10n.profileViewedAgo(
                          timeAgo(viewer.viewedAt!, l10n),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
