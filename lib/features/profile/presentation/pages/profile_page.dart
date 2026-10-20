import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/data_failure_message.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/di/auth_providers.dart';
import '../../../feed/domain/entities/post_list_source.dart';
import '../../../feed/presentation/controllers/feed_controller.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_sheet.dart';
import '../widgets/profile_menu_sheet.dart';
import '../widgets/profile_post_grid.dart';

/// Perfil (según el boceto). Sin [userId] es el propio (pestaña Perfil):
/// arriba, el lápiz para editar, quién vio el perfil, buscar personas y el
/// menú ≡; abajo, cuatro pestañas: mis publicaciones, guardadas, me encanta
/// y compartidas. Con [userId] es el de otra persona, con Seguir y Mensaje.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final id = userId ?? ref.watch(currentUserIdProvider);
    if (id == null) return const SizedBox.shrink();

    final state = ref.watch(profileControllerProvider(id));
    final profile = state.value;

    final Widget body;
    if (profile != null) {
      body = _ProfileContent(profile: profile, isOwnTab: userId == null);
    } else if (state.hasError) {
      final error = state.error;
      body = _ErrorView(
        message: error is DataFailure ? error.message(l10n) : l10n.errorUnknown,
        onRetry: () => ref.invalidate(profileControllerProvider(id)),
      );
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    if (userId == null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Material(
          color: AppColors.superficie,
          child: SafeArea(bottom: false, child: body),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.superficie,
      appBar: AppBar(
        backgroundColor: AppColors.superficie,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(profile == null ? '' : '@${profile.username}'),
        actions: [
          if (profile != null)
            IconButton(
              onPressed: () => _openMenu(context, ref, profile),
              tooltip: l10n.profileMoreOptions,
              icon: const Icon(Icons.menu_rounded),
            ),
        ],
      ),
      body: body,
    );
  }
}

/// Menú ≡ con sus acciones.
Future<void> _openMenu(
  BuildContext context,
  WidgetRef ref,
  UserProfile profile,
) async {
  final l10n = context.l10n;
  final option = await showProfileMenuSheet(context, isMine: profile.isMine);
  if (option == null || !context.mounted) return;

  switch (option) {
    case ProfileMenuOption.editProfile:
      context.push(AppRoutes.editProfile);
    case ProfileMenuOption.share:
      await Clipboard.setData(
        ClipboardData(
          text: l10n.profileShareText(profile.displayName, profile.username),
        ),
      );
      if (context.mounted) context.showSnackBar(l10n.shareCopied);
    case ProfileMenuOption.settings:
    case ProfileMenuOption.report:
      context.showSnackBar(l10n.comingSoon);
    case ProfileMenuOption.signOut:
      if (await confirmSignOut(context)) {
        await ref.read(signOutProvider).call();
      }
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.profile, required this.isOwnTab});

  final UserProfile profile;
  final bool isOwnTab;

  List<_ProfileTab> _tabs(BuildContext context) {
    final l10n = context.l10n;
    final mine = profile.isMine;
    return [
      _ProfileTab(
        collection: PostCollection.authored,
        icon: Icons.grid_on_rounded,
        label: l10n.profileTabPosts,
        empty: mine ? l10n.profileEmptyMyPosts : l10n.profileEmptyPosts,
      ),
      if (mine) ...[
        _ProfileTab(
          collection: PostCollection.saved,
          icon: Icons.bookmark_border_rounded,
          label: l10n.profileTabSaved,
          empty: l10n.profileEmptySaved,
        ),
        _ProfileTab(
          collection: PostCollection.liked,
          icon: Icons.favorite_border_rounded,
          label: l10n.profileTabLiked,
          empty: l10n.profileEmptyLiked,
        ),
        _ProfileTab(
          collection: PostCollection.shared,
          icon: Icons.reply_rounded,
          label: l10n.profileTabShared,
          empty: l10n.profileEmptyShared,
          flipIcon: true,
        ),
      ],
    ];
  }

  ProfilePostsSource _source(_ProfileTab tab) =>
      ProfilePostsSource(userId: profile.id, collection: tab.collection);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tabs = _tabs(context);
    final controller = ref.read(profileControllerProvider(profile.id).notifier);

    Future<void> refresh() async {
      for (final tab in tabs) {
        ref.invalidate(feedControllerProvider(_source(tab)));
      }
      await controller.refresh();
    }

    Future<void> toggleFollow() async {
      final failure = await controller.toggleFollow();
      if (failure != null && context.mounted) {
        context.showSnackBar(failure.message(l10n));
      }
    }

    final header = ProfileHeader(
      profile: profile,
      onInfoTap: () => showProfileInfoSheet(context, profile),
      onFollowingTap: () => context.push(
        AppRoutes.followListPath(profile.id, following: true),
      ),
      onFollowersTap: () =>
          context.push(AppRoutes.followListPath(profile.id)),
      onLikesTap: () => context.showSnackBar(
        l10n.profileLikesInfo(profile.likesCount),
      ),
      onFollowTap: profile.isMine ? null : toggleFollow,
      onMessageTap: profile.isMine
          ? null
          : () => context.showSnackBar(l10n.comingSoon),
    );

    return DefaultTabController(
      length: tabs.length,
      child: RefreshIndicator(
        onRefresh: refresh,
        notificationPredicate: (notification) =>
            notification.metrics.axis == Axis.vertical,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            if (isOwnTab)
              SliverToBoxAdapter(
                child: _OwnTopBar(
                  profile: profile,
                  onMenuTap: () => _openMenu(context, ref, profile),
                ),
              ),
            SliverToBoxAdapter(child: header),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    dividerColor: Colors.transparent,
                    indicatorColor: AppColors.tinta,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.tinta,
                    unselectedLabelColor: AppColors.tintaSuave,
                    tabs: [
                      for (final tab in tabs)
                        Tab(
                          icon: Tooltip(
                            message: tab.label,
                            child: tab.flipIcon
                                ? Transform.flip(
                                    flipX: true,
                                    child: Icon(tab.icon),
                                  )
                                : Icon(tab.icon),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              for (final tab in tabs)
                ProfilePostGrid(
                  source: _source(tab),
                  emptyIcon: tab.icon,
                  emptyText: tab.empty,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra de arriba del perfil propio (según el boceto): lápiz a la
/// izquierda; a la derecha, quién vio el perfil, buscar personas y menú.
class _OwnTopBar extends StatelessWidget {
  const _OwnTopBar({required this.profile, required this.onMenuTap});

  final UserProfile profile;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final views = profile.recentViewsCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.push(AppRoutes.editProfile),
            tooltip: l10n.profileEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push(AppRoutes.profileViewers),
            tooltip: l10n.profileViewersTitle,
            icon: Badge(
              isLabelVisible: views > 0,
              backgroundColor: AppColors.verdeUpc,
              label: Text(views > 99 ? '99+' : '$views'),
              child: const Icon(Icons.visibility_outlined),
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.searchUsers),
            tooltip: l10n.searchUsersTitle,
            icon: const Icon(Icons.person_add_alt_outlined),
          ),
          IconButton(
            onPressed: onMenuTap,
            tooltip: l10n.profileMoreOptions,
            icon: const Icon(Icons.menu_rounded),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab {
  const _ProfileTab({
    required this.collection,
    required this.icon,
    required this.label,
    required this.empty,
    this.flipIcon = false,
  });

  final PostCollection collection;
  final IconData icon;
  final String label;
  final String empty;
  final bool flipIcon;
}

/// Mantiene las pestañas fijas arriba al desplazarse.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height + 1;

  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: AppColors.superficie,
      child: Column(
        children: [
          tabBar,
          const Divider(height: 1, color: AppColors.borde),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => true;
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 48,
              color: AppColors.tintaSuave,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}
