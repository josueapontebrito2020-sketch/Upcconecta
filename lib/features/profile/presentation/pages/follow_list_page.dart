import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/data_failure_message.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/follow_list_type.dart';
import '../controllers/profile_controller.dart';
import '../providers/profile_providers.dart';
import '../widgets/user_list_tile.dart';

/// Seguidores y Seguidos de una persona, en dos pestañas.
class FollowListPage extends ConsumerWidget {
  const FollowListPage({
    super.key,
    required this.userId,
    this.initialType = FollowListType.followers,
  });

  final String userId;
  final FollowListType initialType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(profileControllerProvider(userId)).value;

    return DefaultTabController(
      length: 2,
      initialIndex: initialType.index,
      child: Scaffold(
        backgroundColor: AppColors.superficie,
        appBar: AppBar(
          title: Text(profile == null ? '' : '@${profile.username}'),
          centerTitle: true,
          backgroundColor: AppColors.superficie,
          surfaceTintColor: Colors.transparent,
          bottom: TabBar(
            indicatorColor: AppColors.verdeUpc,
            labelColor: AppColors.tinta,
            unselectedLabelColor: AppColors.tintaSuave,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: [
              Tab(
                text: profile == null
                    ? l10n.profileFollowersCount
                    : '${l10n.profileFollowersCount} ${profile.followersCount}',
              ),
              Tab(
                text: profile == null
                    ? l10n.profileFollowingCount
                    : '${l10n.profileFollowingCount} ${profile.followingCount}',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PeopleList(userId: userId, type: FollowListType.followers),
            _PeopleList(userId: userId, type: FollowListType.following),
          ],
        ),
      ),
    );
  }
}

class _PeopleList extends ConsumerWidget {
  const _PeopleList({required this.userId, required this.type});

  final String userId;
  final FollowListType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = followListProvider((userId, type));
    final state = ref.watch(provider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(provider),
          child: Text(
            '${error is DataFailure ? error.message(l10n) : l10n.errorUnknown}'
            ' ${l10n.retryButton}',
          ),
        ),
      ),
      data: (people) => people.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  type == FollowListType.followers
                      ? l10n.followersEmpty
                      : l10n.followingEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.refresh(provider.future),
              child: ListView.builder(
                itemCount: people.length,
                itemBuilder: (context, index) =>
                    UserListTile(user: people[index]),
              ),
            ),
    );
  }
}
