import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post_media.dart';

/// Fotos o video de la publicación. Con varias fotos se deslizan de lado,
/// con un contador "1/3" y puntos abajo.
class PostMediaGallery extends StatefulWidget {
  const PostMediaGallery({
    super.key,
    required this.media,
    required this.onVideoTap,
  });

  final List<PostMedia> media;
  final VoidCallback onVideoTap;

  @override
  State<PostMediaGallery> createState() => _PostMediaGalleryState();
}

class _PostMediaGalleryState extends State<PostMediaGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    final many = media.length > 1;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (many)
              PageView.builder(
                itemCount: media.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) => _MediaTile(
                  media: media[index],
                  onVideoTap: widget.onVideoTap,
                ),
              )
            else
              _MediaTile(media: media.first, onVideoTap: widget.onVideoTap),
            if (many) ...[
              Positioned(
                top: 10,
                right: 10,
                child: _Pill(
                  text: context.l10n.mediaCounter(_index + 1, media.length),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: _Dots(count: media.length, index: _index),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.media, required this.onVideoTap});

  final PostMedia media;
  final VoidCallback onVideoTap;

  @override
  Widget build(BuildContext context) {
    final bytes = media.bytes;
    final thumbnail = media.thumbnailUrl;
    final Widget image;
    if (bytes != null) {
      // Archivo aún sin subir (vista previa al publicar).
      image = Image.memory(bytes, fit: BoxFit.cover);
    } else if (media.isVideo && thumbnail == null) {
      // Video sin miniatura: fondo oscuro con el botón de reproducir.
      image = const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.verdeProfundo, AppColors.tinta],
          ),
        ),
      );
    } else {
      image = _NetworkImage(url: media.isVideo ? thumbnail! : media.url);
    }

    if (!media.isVideo) return image;

    return GestureDetector(
      onTap: onVideoTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          const ColoredBox(color: Color(0x33000000)),
          Center(
            child: Semantics(
              button: true,
              label: context.l10n.mediaVideo,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.45),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: _Pill(text: context.l10n.mediaVideo, icon: Icons.videocam),
          ),
        ],
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: AppColors.campo,
          child: Center(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: AppColors.campo,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: AppColors.tintaSuave,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final pillIcon = icon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pillIcon != null) ...[
            Icon(pillIcon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}
