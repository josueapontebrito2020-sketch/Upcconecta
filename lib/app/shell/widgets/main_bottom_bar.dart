import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';

/// Barra inferior al estilo TikTok: cuatro pestañas y, en el centro, el
/// botón "+" para publicar (verde con bordes verde claro y amarillo, los
/// colores de la UPC).
///
/// El orden de las pestañas coincide con las ramas del router:
/// 0 Inicio, 1 Grupos, 2 Mensajes, 3 Perfil.
class MainBottomBar extends StatelessWidget {
  const MainBottomBar({
      super.key,
      required this.currentIndex,
      required this.onTabSelected,
      required this.onCreateTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget tab(int index, IconData icon, IconData selectedIcon, String label) {
      return Expanded(
        child: _TabButton(
          icon: icon,
          selectedIcon: selectedIcon,
          label: label,
          selected: currentIndex == index,
          onTap: () => onTabSelected(index),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.superficie,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // Material transparente: aquí se dibujan las ondas al tocar.
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                tab(0, Icons.home_outlined, Icons.home_rounded, l10n.navHome),
                tab(1, Icons.groups_outlined, Icons.groups_rounded, l10n.navGroups),
                Expanded(
                  child: Center(
                    child: _CreateButton(
                      tooltip: l10n.navCreate,
                      onTap: onCreateTap,
                    ),
                  ),
                ),
                tab(
                  2,
                  Icons.chat_bubble_outline_rounded,
                  Icons.chat_bubble_rounded,
                  l10n.navMessages,
                ),
                tab(
                  3,
                  Icons.person_outline_rounded,
                  Icons.person_rounded,
                  l10n.navProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
      required this.icon,
      required this.selectedIcon,
      required this.label,
      required this.selected,
      required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.verdeUpc : AppColors.tintaSuave;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.1 : 1,
              duration: const Duration(milliseconds: 180),
              child: Icon(selected ? selectedIcon : icon, color: color, size: 26),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón "+" central. Dos capas de color desplazadas detrás (verde claro y
/// amarillo) le dan el toque de TikTok con los colores de la UPC.
class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  static const double _width = 50;
  static const double _height = 34;
  static final BorderRadius _radius = BorderRadius.circular(10);

  @override
  Widget build(BuildContext context) {
    Widget layer(Color color, double dx) {
      return Positioned(
        left: 4 + dx,
        top: 0,
        child: Container(
          width: _width,
          height: _height,
          decoration: BoxDecoration(color: color, borderRadius: _radius),
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: _width + 8,
            height: _height,
            child: Stack(
              children: [
                layer(AppColors.verdeBrote, -4),
                layer(AppColors.amarillo, 4),
                Positioned(
                  left: 4,
                  top: 0,
                  child: Container(
                    width: _width,
                    height: _height,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.verdeHoja, AppColors.verdeUpc],
                      ),
                      borderRadius: _radius,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
