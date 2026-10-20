import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Cinco estrellas de solo lectura, con medias estrellas (ej. 3.5).
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.size = 18,
    this.color = const Color(0xFFF2B01E),
  });

  /// De 0 a 5.
  final double value;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            value >= i
                ? Icons.star_rounded
                : value >= i - 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            size: size,
            color: value >= i - 0.5 ? color : AppColors.borde,
          ),
      ],
    );
  }
}
