/// app_ui.dart — Shared premium UI components used across all screens.
///
/// Exports:
///   • AppAnimatedPressable  — spring-scale press feedback wrapper
///   • AppGlassCard          — frosted-glass surface card
///   • AppSectionHeader      — uniform section title with accent dash
///   • AppGradientButton     — full-width gradient CTA button
///   • AppStatPill           — small accent-coloured stat chip
///   • AppEmptyState         — illustrated empty-state placeholder
///   • AppProgressBar        — animated gradient progress bar (6px, glow)
///   • AppShimmer            — skeleton shimmer container
///   • AppTypewriterText     — character-by-character typewriter reveal
///   • AppWeeklyBarChart     — 7-column animated bar chart
///   • AppPillTabBar         — Swiggy-style sliding pill tab bar
///   • AppParticleBurst      — ConfettiPainter celebration overlay
///   • scrollPhysics         — platform-adaptive scroll physics
library;

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'app_colors.dart';

// ── Platform-adaptive scroll physics ─────────────────────────────────────────

ScrollPhysics get scrollPhysics => const BouncingScrollPhysics(
      decelerationRate: ScrollDecelerationRate.fast,
    );

// ── AnimatedPressable ─────────────────────────────────────────────────────────
/// Wraps any widget with a spring scale-down on press — used for all tappable
/// cards, buttons, and chips to give tactile press feedback.

class AppAnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressScale;
  final Duration duration;
  final HapticFeedbackType haptic;

  const AppAnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressScale = 0.95,
    this.duration = const Duration(milliseconds: 130),
    this.haptic = HapticFeedbackType.light,
  });

  @override
  State<AppAnimatedPressable> createState() => _AppAnimatedPressableState();
}

enum HapticFeedbackType { none, light, medium, heavy, selection }

class _AppAnimatedPressableState extends State<AppAnimatedPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 1.0, end: widget.pressScale).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    switch (widget.haptic) {
      case HapticFeedbackType.light:     HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:    HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavy:     HapticFeedback.heavyImpact();
      case HapticFeedbackType.selection: HapticFeedback.selectionClick();
      case HapticFeedbackType.none:      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        _triggerHaptic();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      onLongPress: widget.onLongPress != null
          ? () {
              _ctrl.reverse();
              HapticFeedback.mediumImpact();
              widget.onLongPress!();
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ── GlassCard ─────────────────────────────────────────────────────────────────
/// A frosted-glass surface card with adaptive dark/light styling.

class AppGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blurSigma;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Gradient? gradient;

  const AppGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppRadius.card,
    this.blurSigma = 12,
    this.color,
    this.border,
    this.boxShadow,
    this.onTap,
    this.onLongPress,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.charcoalCard : AppColors.pureWhite;
    final defaultBorder = isDark
        ? Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1)
        : Border.all(color: AppColors.lightBorder, width: 1);
    final defaultShadow = isDark
        ? <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))]
        : <BoxShadow>[
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4,  offset: const Offset(0, 2)),
          ];

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? defaultColor) : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? defaultBorder,
            boxShadow: boxShadow ?? defaultShadow,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      return AppAnimatedPressable(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }
    return card;
  }
}

// ── SectionHeader ─────────────────────────────────────────────────────────────
/// Uniform section title: accent dash + label + optional action button.

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.dynamicMint;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Accent vertical dash
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withValues(alpha: 0.4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (actionLabel != null && onAction != null) ...[
            const Spacer(),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onAction!();
              },
              child: Text(
                actionLabel!,
                style: tt.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── GradientButton ────────────────────────────────────────────────────────────
/// Full-width gradient CTA button with press scale + loading state.

class AppGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final List<Color>? gradientColors;
  final IconData? icon;
  final double height;
  final double borderRadius;
  final TextStyle? labelStyle;

  const AppGradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.gradientColors,
    this.icon,
    this.height = 56,
    this.borderRadius = AppRadius.button,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [AppColors.dynamicMint, AppColors.mintDark];
    final tt = Theme.of(context).textTheme;

    return AppAnimatedPressable(
      onTap: isLoading ? null : onTap,
      pressScale: 0.97,
      haptic: HapticFeedbackType.medium,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: onTap == null
                ? colors.map((c) => c.withValues(alpha: 0.5)).toList()
                : colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: (labelStyle ?? tt.labelLarge)?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── StatPill ──────────────────────────────────────────────────────────────────
/// Small pill chip displaying a coloured label — used for quick metrics.

class AppStatPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppStatPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ProgressBar ───────────────────────────────────────────────────────────────
/// Animated gradient progress bar.

class AppProgressBar extends StatelessWidget {
  final double progress;
  final List<Color> gradientColors;
  final double height;
  final double borderRadius;
  final Duration animationDuration;

  const AppProgressBar({
    super.key,
    required this.progress,
    required this.gradientColors,
    this.height = 6,
    this.borderRadius = 3,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    final bg = gradientColors.first.withValues(alpha: 0.15);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Stack(
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          FractionallySizedBox(
            widthFactor: v,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────
/// Skeleton shimmer placeholder box.

class AppShimmer extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const AppShimmer({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppRadius.chip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base   = isDark ? AppColors.charcoalBorder : AppColors.surfaceGray;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 1400.ms,
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.6),
        );
  }
}

// ── EmptyState ────────────────────────────────────────────────────────────────
/// Consistent illustrated empty-state placeholder.

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;
  final Color? accentColor;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButtonTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.dynamicMint;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.1 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: accent, size: 36),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.95, end: 1.05, duration: 2000.ms, curve: Curves.easeInOut),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: tt.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onButtonTap != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppGradientButton(
                label: buttonLabel!,
                onTap: onButtonTap,
                gradientColors: [accent, accent.withValues(alpha: 0.7)],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── IconBadge ─────────────────────────────────────────────────────────────────
/// Gradient-background icon badge used in card headers.

class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final double size;
  final double iconSize;

  const AppIconBadge({
    super.key,
    required this.icon,
    required this.gradientColors,
    this.size = 38,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: iconSize),
    );
  }
}

// ── CountUpText ───────────────────────────────────────────────────────────────
/// Animates a number from 0 to [value] on first render.

class AppCountUpText extends StatelessWidget {
  final double value;
  final String Function(double) formatter;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const AppCountUpText({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (_, v, __) => Text(formatter(v), style: style),
    );
  }
}

// ── ThreeDotsLoader ───────────────────────────────────────────────────────────
/// Pulsing three-dot typing indicator.

class AppThreeDotsLoader extends StatelessWidget {
  final Color? color;
  final double dotSize;

  const AppThreeDotsLoader({super.key, this.color, this.dotSize = 7});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.dynamicMint;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: dotSize,
          height: dotSize,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        )
            .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
            .scaleXY(
              begin: 0.5,
              end: 1.0,
              duration: 600.ms,
              delay: Duration(milliseconds: i * 150),
              curve: Curves.easeInOut,
            )
            .fadeIn(
              duration: 600.ms,
              delay: Duration(milliseconds: i * 150),
            );
      }),
    );
  }
}

// ── DividerWithLabel ──────────────────────────────────────────────────────────
class AppDividerWithLabel extends StatelessWidget {
  final String label;
  const AppDividerWithLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = isDark ? AppColors.charcoalBorder : AppColors.lightBorder;

    return Row(
      children: [
        Expanded(child: Divider(color: color, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Expanded(child: Divider(color: color, thickness: 1)),
      ],
    );
  }
}

// ── SettingsRow ───────────────────────────────────────────────────────────────
/// Uniform settings list tile used across settings/profile screens.

class AppSettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBgColor;
  final bool danger;

  const AppSettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBgColor,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    final ic = danger ? AppColors.danger : (iconColor ?? AppColors.dynamicMint);
    final ibg = danger
        ? AppColors.danger.withValues(alpha: 0.12)
        : (iconBgColor ?? ic.withValues(alpha: 0.1));

    return AppAnimatedPressable(
      onTap: onTap,
      pressScale: 0.98,
      haptic: HapticFeedbackType.light,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ibg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: ic, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: danger ? AppColors.danger : null,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: tt.bodySmall),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 16,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
          ],
        ),
      ),
    );
  }
}

// ── SettingsSectionCard ───────────────────────────────────────────────────────
/// Wraps a list of settings rows in a rounded card.

class AppSettingsSectionCard extends StatelessWidget {
  final String? headerLabel;
  final List<Widget> children;

  const AppSettingsSectionCard({
    super.key,
    this.headerLabel,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headerLabel != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                headerLabel!.toUpperCase(),
                style: tt.labelSmall?.copyWith(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.charcoalCard : AppColors.pureWhite,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.lightBorder,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Column(
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i < children.length - 1)
                      Divider(
                        indent: 68,
                        endIndent: 0,
                        height: 1,
                        thickness: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.lightBorder,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── TypewriterText ─────────────────────────────────────────────────────────────
/// Reveals text character-by-character with a blinking cursor.
/// MI-10 — triggers automatically when [text] changes.

class AppTypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  /// Delay between each character in ms (default 28ms ≈ 35 chars/sec)
  final int charDelayMs;
  final bool showCursor;

  const AppTypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDelayMs = 28,
    this.showCursor = true,
  });

  @override
  State<AppTypewriterText> createState() => _AppTypewriterTextState();
}

class _AppTypewriterTextState extends State<AppTypewriterText>
    with TickerProviderStateMixin {
  late AnimationController _cursorCtrl;
  late Animation<double> _cursorOpacity;
  String _displayed = '';
  int _charIndex = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
    _cursorOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cursorCtrl, curve: Curves.easeInOut),
    );
    _typeNext();
  }

  @override
  void didUpdateWidget(AppTypewriterText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _displayed = '';
      _charIndex = 0;
      _done = false;
      _typeNext();
    }
  }

  void _typeNext() {
    if (!mounted) return;
    if (_charIndex >= widget.text.length) {
      setState(() => _done = true);
      return;
    }
    Future.delayed(Duration(milliseconds: widget.charDelayMs), () {
      if (!mounted) return;
      setState(() {
        _charIndex++;
        _displayed = widget.text.substring(0, _charIndex);
      });
      _typeNext();
    });
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: _displayed, style: widget.style),
          if (widget.showCursor && !_done)
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: FadeTransition(
                opacity: _cursorOpacity,
                child: Text(
                  '|',
                  style: widget.style?.copyWith(
                    color: AppColors.dynamicMint,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── WeeklyBarChart ─────────────────────────────────────────────────────────────
/// 7-column animated bar chart for weekly overview.
/// Each bar animates from 0 → value on first render.
/// Pass [values] as normalized 0.0–1.0 list of 7 items (Mon–Sun).

class AppWeeklyBarChart extends StatelessWidget {
  final List<double> values;
  final List<Color> barColors;
  final List<String> labels;
  final double height;
  final double barWidth;
  final Color? highlightColor;
  final int? highlightIndex;

  const AppWeeklyBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.barColors = const [AppColors.dynamicMint],
    this.height = 60,
    this.barWidth = 20,
    this.highlightColor,
    this.highlightIndex,
  }) : assert(values.length == 7 && labels.length == 7);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hl = highlightColor ?? AppColors.amberGlow;

    return SizedBox(
      height: height + 22,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final isHighlight = i == highlightIndex;
          final barColor = isHighlight
              ? hl
              : (barColors.length > i ? barColors[i] : barColors.first);
          final normalized = values[i].clamp(0.0, 1.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: normalized),
                duration: Duration(milliseconds: 600 + i * 80),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Container(
                  width: barWidth,
                  height: height * v + 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        barColor.withValues(alpha: isHighlight ? 1.0 : 0.85),
                        barColor.withValues(alpha: isHighlight ? 0.75 : 0.45),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: isHighlight
                        ? [
                            BoxShadow(
                              color: barColor.withValues(alpha: 0.45),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 9,
                  fontWeight:
                      isHighlight ? FontWeight.w700 : FontWeight.w500,
                  color: isHighlight
                      ? hl
                      : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── PillTabBar ─────────────────────────────────────────────────────────────────
/// Swiggy-style sliding pill tab bar.
/// The selected pill slides with an AnimatedPositioned indicator underneath.

class AppPillTabBar extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? activeColor;
  final Color? activeTextColor;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AppPillTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.activeColor,
    this.activeTextColor,
    this.height = 38,
    this.padding,
  });

  @override
  State<AppPillTabBar> createState() => _AppPillTabBarState();
}

class _AppPillTabBarState extends State<AppPillTabBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = widget.activeColor ?? AppColors.dynamicMint;
    final activeTextColor = widget.activeTextColor ?? Colors.white;

    return Padding(
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.charcoalGlass
              : AppColors.surfaceGray,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: LayoutBuilder(builder: (ctx, constraints) {
          final pillW = constraints.maxWidth / widget.tabs.length;
          return Stack(
            children: [
              // Sliding pill indicator — direct Stack child (required by AnimatedPositioned)
              AnimatedPositioned(
                duration: AppDurations.normal,
                curve: AppCurves.popIn,
                left: pillW * widget.selectedIndex,
                top: 3,
                bottom: 3,
                width: pillW,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Labels row
              Row(
                children: List.generate(widget.tabs.length, (i) {
                  final isSelected = i == widget.selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onChanged(i);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: AppDurations.fast,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? activeTextColor
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                            letterSpacing: 0.1,
                          ),
                          child: Text(widget.tabs[i]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── ParticleBurst ──────────────────────────────────────────────────────────────
/// One-shot confetti / particle burst overlay triggered on habit completion,
/// water goal met, or any celebration moment.
///
/// Usage:
///   final _key = GlobalKey<AppParticleBurstState>();
///   AppParticleBurst(key: _key)
///   _key.currentState?.burst(); // call to trigger

class AppParticleBurst extends StatefulWidget {
  final Color primaryColor;
  final int particleCount;
  final double radius;

  const AppParticleBurst({
    super.key,
    this.primaryColor = AppColors.dynamicMint,
    this.particleCount = 18,
    this.radius = 60,
  });

  @override
  State<AppParticleBurst> createState() => AppParticleBurstState();
}

class AppParticleBurstState extends State<AppParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 700.ms);
    _rebuildParticles();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        if (mounted) setState(() => _visible = false);
      }
    });
  }

  void _rebuildParticles() {
    final rng = math.Random();
    _particles = List.generate(widget.particleCount, (_) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final speed = widget.radius * (0.5 + rng.nextDouble() * 0.5);
      return _Particle(
        angle: angle,
        distance: speed,
        size: 4 + rng.nextDouble() * 5,
        color: HSLColor.fromColor(widget.primaryColor)
            .withLightness(0.45 + rng.nextDouble() * 0.35)
            .withSaturation(0.8 + rng.nextDouble() * 0.2)
            .toColor(),
      );
    });
  }

  void burst() {
    _rebuildParticles();
    _ctrl.forward(from: 0);
    if (mounted) setState(() => _visible = true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _ctrl.value,
          ),
          size: const Size(120, 120),
        ),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  const _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  const _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final eased = Curves.easeOutCubic.transform(progress);
    final fadeOut = 1.0 - progress;

    for (final p in particles) {
      final dx = math.cos(p.angle) * p.distance * eased;
      final dy = math.sin(p.angle) * p.distance * eased;
      final paint = Paint()
        ..color = p.color.withValues(alpha: fadeOut.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      final radius = p.size * (1.0 - progress * 0.4);
      canvas.drawCircle(center + Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
