import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health_app/src/services/wger_service.dart';

/// Shows a real exercise illustration from the wger open-source database.
///
/// Fetches exercise data by [exerciseName] and displays the illustration(s).
/// When there are two images (start + end position), it auto-animates between them.
/// Falls back gracefully to a styled letter-avatar if no images are found.
class WgerExerciseWidget extends ConsumerStatefulWidget {
  final String exerciseName;
  final Color accentColor;
  final double height;
  /// If true, shows a small "wger" attribution badge
  final bool showAttribution;

  const WgerExerciseWidget({
    super.key,
    required this.exerciseName,
    this.accentColor = const Color(0xFF6C63FF),
    this.height = 240,
    this.showAttribution = false,
  });

  @override
  ConsumerState<WgerExerciseWidget> createState() => _WgerExerciseWidgetState();
}

class _WgerExerciseWidgetState extends ConsumerState<WgerExerciseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  int _imgIndex = 0;

  @override
  void initState() {
    super.initState();
    // Slowly cycle between the two exercise position images
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) setState(() => _imgIndex = _imgIndex == 0 ? 1 : 0);
            _animCtrl.forward(from: 0);
          });
        }
      });
  }

  void _startAnimation(int imageCount) {
    if (imageCount >= 2 && !_animCtrl.isAnimating) {
      _animCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(wgerExerciseProvider(widget.exerciseName));

    return async.when(
      loading: () => _buildSkeleton(),
      error: (_, __) => _buildPlaceholder(),
      data: (exercise) {
        if (exercise == null || exercise.allImageUrls.isEmpty) {
          return _buildPlaceholder();
        }
        final urls = exercise.allImageUrls;
        // Start the animation once we have 2+ images
        WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation(urls.length));

        final currentUrl = urls[_imgIndex.clamp(0, urls.length - 1)];

        return _buildImageDisplay(currentUrl, urls.length);
      },
    );
  }

  Widget _buildImageDisplay(String imageUrl, int totalImages) {
    return Stack(
      children: [
        // Main exercise illustration — crossfade between positions
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: _ExerciseImage(
            key: ValueKey(imageUrl),
            imageUrl: imageUrl,
            height: widget.height,
            accentColor: widget.accentColor,
          ),
        ),

        // Position indicator dots (when 2 images)
        if (totalImages >= 2)
          Positioned(
            bottom: 10,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalImages.clamp(0, 2),
                (i) => AnimatedContainer(
                  duration: 300.ms,
                  width: i == _imgIndex ? 18 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _imgIndex
                        ? widget.accentColor
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

        // "FRONT" / "END" label
        if (totalImages >= 2)
          Positioned(
            top: 10, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _imgIndex == 0 ? 'START' : 'END',
                style: TextStyle(
                  color: widget.accentColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

        // Attribution
        if (widget.showAttribution)
          Positioned(
            bottom: 10, right: 10,
            child: Text(
              'wger.de / CC-BY-SA',
              style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: widget.accentColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final letter = widget.exerciseName.isNotEmpty
        ? widget.exerciseName[0].toUpperCase()
        : '?';
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            widget.accentColor.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: widget.accentColor.withOpacity(0.12),
            fontSize: 120,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ExerciseImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final Color accentColor;

  const _ExerciseImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (_, __) => Center(
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: accentColor),
          ),
        ),
        errorWidget: (_, __, ___) => Center(
          child: Icon(Icons.fitness_center, color: accentColor.withOpacity(0.3), size: 48),
        ),
      ),
    );
  }
}
