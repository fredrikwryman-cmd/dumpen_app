/// # Videospelare — omarbetad med nya färger
library;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../constants/app_colors.dart';

class HtmlVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double? aspectRatio;

  const HtmlVideoPlayer({
    super.key,
    required this.videoUrl,
    this.aspectRatio,
  });

  @override
  State<HtmlVideoPlayer> createState() => _HtmlVideoPlayerState();
}

class _HtmlVideoPlayerState extends State<HtmlVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      _controller = controller;
      await controller.initialize();
      controller.setLooping(false);
      if (mounted) setState(() => _isReady = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _controller == null) {
      return _buildPlaceholder(Icons.error_outline, 'Videon kunde inte laddas');
    }
    if (!_isReady) {
      return _buildPlaceholder(Icons.play_circle_outline, 'Laddar video...');
    }

    final controller = _controller!;
    final ratio = widget.aspectRatio ?? controller.value.aspectRatio;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: ratio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(controller),
              _VideoControls(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.foregroundDark),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(fontFamily: 'sans-serif', color: AppColors.foregroundMuted),
          ),
        ],
      ),
    );
  }
}

class _VideoControls extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoControls({required this.controller});

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () => setState(() {});
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isPlaying = controller.value.isPlaying;

    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
      child: AnimatedOpacity(
        opacity: isPlaying ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: Colors.black45,
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.accentYellow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
