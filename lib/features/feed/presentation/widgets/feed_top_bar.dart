import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/feed_category_filter_provider.dart';
import '../post_category_label.dart';
import 'category_filter_sheet.dart';

/// Barra superior del inicio, al estilo TikTok: filtro a la izquierda,
/// apartados (Destacados · Comunidad · Transporte) al centro y búsqueda a la
/// derecha. Debajo, si hay un filtro activo, un chip para quitarlo.
///
/// Usa el `TabController` del `DefaultTabController` de la página.
class FeedTopBar extends ConsumerWidget {
  const FeedTopBar({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final category = ref.watch(feedCategoryFilterProvider);

    Future<void> openFilter() async {
      final choice = await showCategoryFilterSheet(context, current: category);
      if (choice == null) return;
      ref.read(feedCategoryFilterProvider.notifier).select(choice.category);
    }

    return Material(
      color: AppColors.superficie,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 54,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: openFilter,
                    tooltip: l10n.feedFilterTooltip,
                    icon: Badge(
                      isLabelVisible: category != null,
                      backgroundColor: AppColors.verdeUpc,
                      smallSize: 9,
                      child: const Icon(Icons.tune_rounded),
                    ),
                  ),
                  Expanded(
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: AppColors.verdeUpc,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        insets: EdgeInsets.symmetric(horizontal: 6),
                      ),
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                      ),
                      labelColor: AppColors.tinta,
                      unselectedLabelColor: AppColors.tintaSuave,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        Tab(text: l10n.feedFeatured),
                        Tab(text: l10n.feedCommunity),
                        Tab(text: l10n.feedTransport),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onSearchTap,
                    tooltip: l10n.feedSearchTooltip,
                    icon: const Icon(Icons.search_rounded),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: category == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: InputChip(
                          avatar: Icon(
                            category.icon,
                            size: 18,
                            color: AppColors.verdeUpc,
                          ),
                          label: Text(
                            l10n.feedFilterActive(category.label(l10n)),
                          ),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.verdeUpc,
                          ),
                          backgroundColor: AppColors.verdeUpc.withValues(
                            alpha: 0.08,
                          ),
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          deleteIconColor: AppColors.verdeUpc,
                          deleteButtonTooltipMessage: l10n.feedFilterClear,
                          onDeleted: () => ref
                              .read(feedCategoryFilterProvider.notifier)
                              .select(null),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
