import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import '../../application/adaptive_analysis_provider.dart';

class AdaptiveSuggestionsCard extends ConsumerWidget {
  final bool isDark;
  const AdaptiveSuggestionsCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adaptiveAnalysisProvider);

    return async.when(
      loading: () => _LoadingCard(isDark: isDark),
      error: (_, __) => const SizedBox.shrink(),
      data: (result) {
        if (result == null) return const SizedBox.shrink();
        return _SuggestionsContent(
            result: result, isDark: isDark, ref: ref);
      },
    );
  }
}

// ── Loading placeholder ───────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  final bool isDark;
  const _LoadingCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.softIndigo),
          ),
          const SizedBox(width: 14),
          Text(
            'Analysing your last 7 days…',
            style: TextStyle(
                fontSize: 13,
                color:
                    isDark ? Colors.white54 : AppColors.lightTextSecondary),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 800.ms);
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _SuggestionsContent extends StatelessWidget {
  final AdaptiveAnalysisResult result;
  final bool isDark;
  final WidgetRef ref;

  const _SuggestionsContent({
    required this.result,
    required this.isDark,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softIndigo.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.softIndigo, Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(PhosphorIconsFill.sparkle,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Weekly Analysis',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (result.weekSummary.isNotEmpty)
                        Text(
                          result.weekSummary,
                          style: TextStyle(
                            fontSize: 11,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.45)
                                  : AppColors.lightTextSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Refresh button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(adaptiveAnalysisProvider.notifier)
                        .refresh();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(PhosphorIconsRegular.arrowClockwise,
                        size: 15,
                        color: isDark
                            ? Colors.white38
                            : AppColors.lightTextSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Suggestions list
          ...result.suggestions.asMap().entries.map((e) {
            return _SuggestionTile(
              suggestion: e.value,
              isDark: isDark,
            )
                  .animate(delay: Duration(milliseconds: 80 * e.key))
                .fadeIn(duration: 350.ms)
                .slideX(begin: 0.04, end: 0);
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Single suggestion tile ────────────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  final AdaptiveSuggestion suggestion;
  final bool isDark;

  const _SuggestionTile(
      {required this.suggestion, required this.isDark});

  IconData get _icon {
    switch (suggestion.type) {
      case 'increase_weight':
        return PhosphorIconsFill.arrowUp;
      case 'add_volume':
        return PhosphorIconsFill.plusCircle;
      case 'deload':
        return PhosphorIconsFill.arrowDown;
      default:
        return PhosphorIconsFill.lightbulb;
    }
  }

  Color get _accent {
    switch (suggestion.type) {
      case 'increase_weight':
        return AppColors.dynamicMint;
      case 'add_volume':
        return AppColors.softIndigo;
      case 'deload':
        return AppColors.warning;
      default:
        return const Color(0xFF9B8BFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: isDark ? 0.06 : 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _accent.withValues(alpha: isDark ? 0.15 : 0.10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 13, color: _accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.87)
                            : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (suggestion.body.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      suggestion.body,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white54
                            : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
