import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Foto de perfil redonda. Sin foto (o si no carga) muestra las iniciales
/// sobre un verde que siempre es el mismo para la misma persona.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
  });

  final String name;
  final String? imageUrl;
  final double size;

  static const List<Color> _palette = [
    AppColors.verdeUpc,
    AppColors.verdeHoja,
    AppColors.verdeProfundo,
    Color(0xFF2E7D6B),
    Color(0xFF5B8C2A),
  ];

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = [
      for (final part in parts.take(2))
        if (part.isNotEmpty) part[0].toUpperCase(),
    ];
    return letters.isEmpty ? '?' : letters.join();
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final fallback = ColoredBox(
      color: _palette[name.hashCode.abs() % _palette.length],
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );

    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(
          child: url == null
              ? fallback
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => fallback,
                ),
        ),
      ),
    );
  }
}
