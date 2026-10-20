import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botón principal de cada pantalla: degradado verde con un brillo debajo
/// (efecto 3D). Mientras [isLoading] es true muestra un indicador de carga y
/// no se puede presionar (evita envíos dobles).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  static final BorderRadius _radius = BorderRadius.circular(14);

  @override
  Widget build(BuildContext context) {
    // Mientras carga se ve activo (con el indicador), aunque no responda.
    final looksActive = onPressed != null || isLoading;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _radius,
        gradient: looksActive
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.verdeHoja, AppColors.verdeUpc],
              )
            : null,
        color: looksActive ? null : AppColors.borde,
        boxShadow: looksActive
            ? [
                BoxShadow(
                  color: AppColors.verdeUpc.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: looksActive
              ? Colors.white
              : AppColors.tintaSuave,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: _radius),
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                  semanticsLabel: label,
                ),
              )
            : Text(label),
      ),
    );
  }
}
