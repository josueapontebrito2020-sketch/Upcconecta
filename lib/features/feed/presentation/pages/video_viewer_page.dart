import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Video de una publicación en pantalla completa, sobre fondo negro.
/// Se reproduce solo y en bucle; tocar la pantalla pausa o continúa.
class VideoViewerPage extends StatefulWidget {
  const VideoViewerPage({super.key, required this.url});

  final String url;

  @override
  State<VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  late final VideoPlayerController _controller =
      VideoPlayerController.networkUrl(Uri.parse(widget.url));
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    if (mounted) setState(() {});
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = _controller.value;

    final Widget content;
    if (_failed || value.hasError) {
      content = Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          l10n.videoError,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    } else if (!value.isInitialized) {
      content = const CircularProgressIndicator(color: Colors.white);
    } else {
      content = GestureDetector(
        onTap: _togglePlay,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _controller,
              builder: (context, value, _) => AnimatedOpacity(
                opacity: value.isPlaying ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 48,
                    color: Colors.white,
                    semanticLabel: l10n.videoPlay,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(child: content),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: l10n.closeTooltip,
                  color: Colors.white,
                  icon: const Icon(Icons.close_rounded, size: 28),
                ),
              ),
              if (value.isInitialized && !_failed)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppColors.verdeBrote,
                      bufferedColor: Colors.white38,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
