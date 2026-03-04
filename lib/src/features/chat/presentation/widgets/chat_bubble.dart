import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme/app_colors.dart';
import '../../../../database/models/chat_session_doc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../workout/presentation/widgets/workout_plan_card.dart';
import '../../../nutrition/presentation/widgets/meal_plan_card.dart';
import 'weekly_report_card.dart';
import 'food_scan_card.dart';
import '../gemma_setup_screen.dart';

// Callback type for when user selects an option or submits a form
typedef OnReplyCallback = void Function(String message);

class ChatBubble extends ConsumerStatefulWidget {
  final ChatMessageDoc message;
  final bool isTyping;
  final bool isStreaming;
  final OnReplyCallback? onReply;

  const ChatBubble({
    super.key,
    required this.message,
    this.isTyping = false,
    this.isStreaming = false,
    this.onReply,
  });

  @override
  ConsumerState<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends ConsumerState<ChatBubble> {
  bool _showActions = false;
  bool _showTimestamp = false;
  bool _optionsDismissed = false;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() => _showActions = !_showActions);
      },
      onTap: () {
        if (_showActions || _showTimestamp) {
          setState(() {
            _showActions = false;
            _showTimestamp = false;
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 10,
          left: isUser ? 52 : 0,
          right: isUser ? 0 : (widget.message.isWidget ? 0 : 52),
        ),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              _AiAvatar(),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (widget.message.isWidget)
                    _buildWidgetBubble(context)
                  else if (widget.isTyping)
                    _buildTypingBubble()
                  else if (widget.isStreaming)
                    _buildStreamingBubble()
                  else
                    _buildTextBubble(context, isUser),

                  // Interactive option buttons (AI messages only, not dismissed)
                  if (!isUser &&
                      !widget.isTyping &&
                      !widget.isStreaming &&
                      !widget.message.isWidget &&
                      !_optionsDismissed &&
                      widget.onReply != null)
                    _buildInteractiveExtras(context),

                  // Timestamp on tap
                  if (_showTimestamp)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                      child: Text(
                        _formatTimestamp(widget.message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ).animate().fadeIn(duration: 150.ms),

                  // Action row on long-press
                  if (_showActions &&
                      !widget.isTyping &&
                      !widget.message.isWidget)
                    _buildActionRow(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Parse numbered options from AI text ──────────────────────────────────────
  // Matches lines like: "1. Gym Workout", "2. Home Workout", "3. Something else"
  // Also matches "A) Fast results..." / "B) Steady..." style
  static final _numberedOptionRe =
      RegExp(r'^\s*(\d+|[A-F])[.)]\s+(.+)$', multiLine: true);

  /// Strip markdown formatting characters from a label so buttons show clean text.
  static String _cleanLabel(String raw) {
    return raw
        .replaceAll(RegExp(r'\*+'), '')   // **bold** / *italic*
        .replaceAll(RegExp(r'_+'), '')    // __bold__ / _italic_
        .replaceAll(RegExp(r'`+'), '')    // `code`
        .replaceAll(RegExp(r'#+\s*'), '') // ## heading
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]*\)'), r'$1') // [text](url)
        .trim();
  }

  List<String> _parseOptions(String text) {
    final matches = _numberedOptionRe.allMatches(text);
    if (matches.length < 2) return [];
    return matches.map((m) => _cleanLabel(m.group(2)!)).toList();
  }

  /// Returns the text with all option lines stripped out.
  String _stripOptions(String text) {
    return text
        .split('\n')
        .where((line) => !_numberedOptionRe.hasMatch(line))
        .join('\n')
        .trim();
  }

  // ── Detect form-style question ────────────────────────────────────────────────
  // Returns a list of {label, type} maps for detected form fields.
  // Checks for common prompts the AI uses when it needs a single specific value.
  List<Map<String, String>> _detectFormFields(String text) {
    final lower = text.toLowerCase();
    final fields = <Map<String, String>>[];

    if (lower.contains('how many days') ||
        lower.contains('days per week') ||
        lower.contains('days a week')) {
      fields.add({'label': 'Days per week', 'type': 'slider', 'min': '1', 'max': '7'});
    }
    if (lower.contains('how many hours') || lower.contains('hours of sleep')) {
      fields.add({'label': 'Hours of sleep', 'type': 'slider', 'min': '4', 'max': '12'});
    }
    if (lower.contains('how long') && lower.contains('session')) {
      fields.add({'label': 'Session duration (minutes)', 'type': 'slider', 'min': '20', 'max': '120'});
    }
    if ((lower.contains('injury') || lower.contains('medical condition') ||
        lower.contains('health condition'))) {
      fields.add({'label': 'Any injuries or conditions?', 'type': 'text'});
    }
    return fields;
  }

  Widget _buildInteractiveExtras(BuildContext context) {
    final text = widget.message.text;
    final options = _parseOptions(text);
    final formFields = options.isEmpty ? _detectFormFields(text) : <Map<String, String>>[];

    if (options.isEmpty && formFields.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: options.isNotEmpty
          ? _buildOptionButtons(context, options)
          : _buildFormCard(context, formFields),
    ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.1, end: 0, duration: 280.ms);
  }

  Widget _buildOptionButtons(BuildContext context, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: options.asMap().entries.map((e) {
        final idx = e.key;
        final label = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _OptionButton(
            label: label,
            index: idx,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _optionsDismissed = true);
              widget.onReply!(label);
            },
          ).animate().fadeIn(delay: Duration(milliseconds: 60 + idx * 60))
              .slideX(begin: -0.06, end: 0, duration: 260.ms,
                  delay: Duration(milliseconds: 60 + idx * 60)),
        );
      }).toList(),
    );
  }

  Widget _buildFormCard(BuildContext context, List<Map<String, String>> fields) {
    return _InlineFormCard(
      fields: fields,
      onSubmit: (values) {
        setState(() => _optionsDismissed = true);
        final msg = values.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        widget.onReply!(msg);
      },
    );
  }

  // ── Text bubble (strips option lines so they don't duplicate) ────────────────
  Widget _buildTextBubble(BuildContext context, bool isUser) {
    // For AI messages, strip the raw option lines from displayed markdown
    // (they'll be shown as buttons instead)
    final rawText = widget.message.text;
    final displayText = (!isUser && widget.onReply != null)
        ? _stripOptions(rawText)
        : rawText;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // AI bubble colours
    final aiBubbleBg = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFF0F2F8); // light grey-blue tint
    final aiBubbleBorder = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);
    final aiTextColor = isDark ? Colors.white.withValues(alpha: 0.88) : const Color(0xFF1A1D35);
    final aiSubColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return GestureDetector(
      onTap: () {
        setState(() => _showTimestamp = !_showTimestamp);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF7B6FFF), Color(0xFF5468FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser ? null : aiBubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isUser ? 22 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 22),
          ),
          border: isUser
              ? null
              : Border.all(color: aiBubbleBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? AppColors.softIndigo.withValues(alpha: 0.3)
                  : (isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.06)),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: MarkdownBody(
          data: displayText,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              fontSize: 15,
              height: 1.52,
              letterSpacing: 0.1,
              color: isUser ? Colors.white : aiTextColor,
            ),
            strong: TextStyle(
              fontWeight: FontWeight.w700,
              color: isUser ? Colors.white : AppColors.softIndigo,
            ),
            em: TextStyle(
              fontStyle: FontStyle.italic,
              color: isUser ? Colors.white70 : aiSubColor,
            ),
            code: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              backgroundColor: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.06),
              color: isDark ? AppColors.dynamicMint : AppColors.softIndigo,
            ),
            blockquote: TextStyle(color: aiSubColor, fontSize: 14),
            listBullet: TextStyle(
              color: isUser ? Colors.white70 : AppColors.softIndigo,
            ),
            h1: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isUser ? Colors.white : aiTextColor,
            ),
            h2: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isUser ? Colors.white : aiTextColor,
            ),
            h3: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isUser ? Colors.white : aiTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreamingBubble() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white.withValues(alpha: 0.88) : const Color(0xFF1A1D35);
    final bgColor = isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF0F2F8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(22),
        ),
        border: Border.all(
          color: AppColors.softIndigo.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.softIndigo.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: MarkdownBody(
              data: widget.message.text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(fontSize: 15, height: 1.52, color: textColor),
                strong: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.softIndigo,
                ),
                h1: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                h2: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
                h3: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Blinking cursor
          Container(
            width: 2.5,
            height: 17,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.softIndigo, AppColors.dynamicMint],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.1, end: 1.0, duration: 520.ms),
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(22),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: const _TypingIndicator(),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionChip(
            icon: PhosphorIconsRegular.copy,
            label: 'Copy',
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.message.text));
              HapticFeedback.lightImpact();
              setState(() => _showActions = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppColors.charcoalGlass,
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          _ActionChip(
            icon: PhosphorIconsRegular.thumbsUp,
            label: 'Good',
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _showActions = false);
            },
          ),
          const SizedBox(width: 6),
          _ActionChip(
            icon: PhosphorIconsRegular.thumbsDown,
            label: 'Bad',
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _showActions = false);
            },
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 160.ms)
          .slideY(begin: -0.15, end: 0, duration: 160.ms),
    );
  }

  Widget _buildWidgetBubble(BuildContext context) {
    if (widget.message.widgetType == 'meal') {
      return MealPlanCard(planJson: widget.message.text);
    }
    if (widget.message.widgetType == 'report') {
      return const WeeklyReportCard();
    }
    if (widget.message.widgetType == 'food_scan') {
      return FoodScanCard(scanJson: widget.message.text);
    }
    if (widget.message.widgetType == 'offline_setup') {
      return _buildOfflineSetupWidget(context);
    }
    return WorkoutPlanCard(planJson: widget.message.text);
  }

  Widget _buildOfflineSetupWidget(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E243A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.dynamicMint.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsFill.cloudArrowDown,
                  color: AppColors.dynamicMint, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI Model Required',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dynamicMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.message.text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dynamicMint,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.9,
                    maxChildSize: 0.95,
                    minChildSize: 0.5,
                    builder: (_, __) => const GemmaSetupScreen(),
                  ),
                );
              },
              child: const Text(
                'Open Offline AI Setup',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) return '$h:$m';
    return '${dt.day}/${dt.month} $h:$m';
  }
}

// ─── Option Button ─────────────────────────────────────────────────────────────

class _OptionButton extends StatefulWidget {
  final String label;
  final int index;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.index,
    required this.onTap,
  });

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton> {
  bool _pressed = false;

  static const _palettes = [
    (base: Color(0xFF7B6FFF), light: Color(0xFFA99FFF)), // indigo
    (base: Color(0xFF00C2A8), light: Color(0xFF4DDECE)), // mint
    (base: Color(0xFF5488FF), light: Color(0xFF88AAFF)), // blue
    (base: Color(0xFFFF6B8A), light: Color(0xFFFFADBD)), // pink
    (base: Color(0xFFFFB347), light: Color(0xFFFFCF7F)), // orange
    (base: Color(0xFF6BCB77), light: Color(0xFF9EE0A8)), // green
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _palettes[widget.index % _palettes.length];
    final color = palette.base;
    final lightColor = palette.light;
    final cardBg = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white;
    final labelColor = isDark ? Colors.white : const Color(0xFF1A1D35);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        transform: Matrix4.diagonal3Values(
            1.0, _pressed ? 0.97 : 1.0, 1.0),
          decoration: BoxDecoration(
            color: _pressed
                ? color.withValues(alpha: 0.18)
                : cardBg,
            borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: _pressed ? 0.7 : 0.35),
            width: 1.5,
          ),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, lightColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Number badge
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: lightColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Label — expands to fill, wraps cleanly
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                        height: 1.35,
                      ),
                  ),
                ),
              ),
              // Arrow hint
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: color.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Inline Form Card ──────────────────────────────────────────────────────────

class _InlineFormCard extends StatefulWidget {
  final List<Map<String, String>> fields;
  final void Function(Map<String, String> values) onSubmit;

  const _InlineFormCard({required this.fields, required this.onSubmit});

  @override
  State<_InlineFormCard> createState() => _InlineFormCardState();
}

class _InlineFormCardState extends State<_InlineFormCard> {
  final Map<String, String> _values = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      final label = field['label']!;
      if (field['type'] == 'text') {
        _controllers[label] = TextEditingController();
      } else if (field['type'] == 'slider') {
        final min = double.parse(field['min'] ?? '1');
        _values[label] = min.toInt().toString();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.softIndigo.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softIndigo.withValues(alpha: 0.1),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.fields.map((field) => _buildField(field)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.softIndigo, AppColors.dynamicMint],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.softIndigo.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(Map<String, String> field) {
    final label = field['label']!;
    final type = field['type']!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.65),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          if (type == 'text')
            _buildTextField(label)
          else if (type == 'slider')
            _buildSlider(field),
        ],
      ),
    );
  }

  Widget _buildTextField(String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: TextField(
        controller: _controllers[label],
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Type here…',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        onChanged: (v) => _values[label] = v,
      ),
    );
  }

  Widget _buildSlider(Map<String, String> field) {
    final label = field['label']!;
    final min = double.parse(field['min'] ?? '1');
    final max = double.parse(field['max'] ?? '10');
    final current = double.tryParse(_values[label] ?? '') ?? min;
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.softIndigo,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
            thumbColor: AppColors.dynamicMint,
            overlayColor: AppColors.softIndigo.withValues(alpha: 0.2),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: current,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: (v) {
              setState(() => _values[label] = v.toInt().toString());
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.toInt()}',
                style: TextStyle(
                    fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.softIndigo, AppColors.dynamicMint]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                current.toInt().toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Text('${max.toInt()}',
                style: TextStyle(
                    fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
          ],
        ),
      ],
    );
  }

  void _submit() {
    // Collect text field values
    for (final entry in _controllers.entries) {
      if (entry.value.text.trim().isNotEmpty) {
        _values[entry.key] = entry.value.text.trim();
      }
    }
    if (_values.isEmpty) return;
    widget.onSubmit(_values);
  }
}

// ─── AI Avatar ────────────────────────────────────────────────────────────────

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6B7AFF), Color(0xFF00D4B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softIndigo.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 15),
    );
  }
}

// ─── Action chip ──────────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.1), width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.15), blurRadius: 8),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Typing indicator ─────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        const SizedBox(width: 5),
        _buildDot(180),
        const SizedBox(width: 5),
        _buildDot(360),
      ],
    );
  }

  Widget _buildDot(int delayMs) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.softIndigo, AppColors.dynamicMint],
        ),
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .slideY(
          begin: 0.5,
          end: -0.5,
          curve: Curves.easeInOut,
          duration: 560.ms,
          delay: delayMs.ms,
        )
        .fade(begin: 0.3, end: 1.0, duration: 560.ms, delay: delayMs.ms);
  }
}
