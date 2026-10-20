import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/coming_soon_view.dart';
import '../../domain/entities/feed_section.dart';
import '../../domain/entities/post_list_source.dart';
import '../widgets/feed_list.dart';
import '../widgets/feed_top_bar.dart';

/// Pantalla de inicio (primera pestaña). Arriba los apartados Destacados,
/// Comunidad y Transporte; abajo las publicaciones, que se deslizan hacia
/// abajo. Abre en Comunidad.
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DefaultTabController(
        length: FeedSection.values.length,
        initialIndex: FeedSection.community.index,
        // Material (no ColoredBox) para que se vean las ondas al tocar los
        // botones que están sobre el fondo.
        child: Material(
          color: AppColors.fondo,
          child: Column(
            children: [
              FeedTopBar(
                onSearchTap: () => context.showSnackBar(l10n.comingSoon),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    const FeedList(
                      source: HomeFeedSource(FeedSection.featured),
                    ),
                    const FeedList(
                      source: HomeFeedSource(FeedSection.community),
                    ),
                    ComingSoonView(
                      icon: Icons.directions_car_outlined,
                      title: l10n.transportTitle,
                      message: l10n.transportMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
