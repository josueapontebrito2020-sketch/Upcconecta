import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// Fondo de las pantallas de acceso: foto del campus bajo un velo verde
/// translúcido, con dos manchas de luz suaves para dar profundidad.
///
/// - [scale] anima un acercamiento de la foto (para un fondo quieto se pasa
///   `kAlwaysCompleteAnimation`).
/// - [onImageShown] se llama cuando la foto ya se ve en pantalla; sirve
///   para empezar la animación de entrada en ese momento y no antes.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.scale, this.onImageShown});

  final Animation<double> scale;
  final VoidCallback? onImageShown;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ScaleTransition(
          scale: scale,
          child: Image.asset(
            AppAssets.campusBackground,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame != null || wasSynchronouslyLoaded) {
                onImageShown?.call();
              }
              return child;
            },
            errorBuilder: (context, error, stackTrace) {
              onImageShown?.call();
              return const SizedBox.shrink();
            },
          ),
        ),
        // Velo verde translúcido: un poco más intenso arriba y más claro
        // abajo, para que se vea el campus detrás de la tarjeta.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.55, 1],
              colors: [
                AppColors.verdeProfundo.withValues(alpha: 0.62),
                AppColors.verdeUpc.withValues(alpha: 0.48),
                AppColors.verdeHoja.withValues(alpha: 0.30),
              ],
            ),
          ),
        ),
        // Mancha de luz arriba a la izquierda.
        const Positioned(
          top: -120,
          left: -100,
          child: _GlowSpot(size: 340, color: AppColors.verdeBrote, alpha: 0.30),
        ),
      ],
    );
  }
}

class _GlowSpot extends StatelessWidget {
  const _GlowSpot({
    required this.size,
    required this.color,
    required this.alpha,
  });

  final double size;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
