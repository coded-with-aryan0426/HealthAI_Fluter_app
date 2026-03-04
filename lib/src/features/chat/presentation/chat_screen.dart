import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';
import '../application/chat_controller.dart';
import '../application/chat_suggestions_provider.dart';
import 'widgets/chat_bubble.dart';
import 'gemma_setup_screen.dart';
import '../../../services/gemma_service.dart';
import 'package:isar/isar.dart';
import '../../../services/local_db_service.dart' as health_app;
import '../../../database/models/chat_session_doc.dart' as health_app;

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasText = false;
  bool _showScrollDown = false;

  late AnimationController _sendButtonController;
  late AnimationController _micPulseController;

  // ── Speech-to-text ──────────────────────────────────────────────────────────
  late stt.SpeechToText _speech;
  bool _sttAvailable = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _speech = stt.SpeechToText();
    _speech.initialize(onStatus: (status) {
      if (status == 'done' || status == 'notListening') {
        if (mounted) setState(() => _isListening = false);
      }
    }).then((available) {
      if (mounted) setState(() => _sttAvailable = available);
    });

    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) {
        setState(() => _hasText = has);
        if (has) {
          _sendButtonController.forward();
        } else {
          _sendButtonController.reverse();
        }
      }
    });

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
      _scrollToBottom();
      // Consume any prefilled message (e.g. from "Chat about this" on dashboard)
      final prefilled = ref.read(chatPrefilledMessageProvider);
      if (prefilled != null && prefilled.isNotEmpty) {
        ref.read(chatPrefilledMessageProvider.notifier).state = null;
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _sendMessage(prefilled);
        });
      }
    });
  }

  /// Only create a new session if none exists at all.
  /// If sessions exist, load the most recent one instead of creating a blank new one.
  Future<void> _initSession() async {
    if (ref.read(chatControllerProvider) != null) return; // already loaded

    final isar = ref.read(health_app.isarProvider);
    final sessions = await isar.chatSessionDocs
        .where()
        .sortByUpdatedAtDesc()
        .limit(1)
        .findAll();

    if (sessions.isNotEmpty) {
      // Resume most recent session
      ref.read(chatControllerProvider.notifier).loadSession(sessions.first.id);
    } else {
      // No sessions at all — start fresh
      ref.read(chatControllerProvider.notifier).startNewSession();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final atBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 80;
    final shouldShow = !atBottom &&
        _scrollController.position.maxScrollExtent > 0;
    if (shouldShow != _showScrollDown) {
      setState(() => _showScrollDown = shouldShow);
    }
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    _micPulseController.dispose();
    _speech.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (!_sttAvailable) {
      _showToast('Microphone not available on this device');
      return;
    }
    if (_isListening) {
      await _speech.stop();
      _micPulseController.stop();
      setState(() => _isListening = false);
    } else {
      HapticFeedback.mediumImpact();
      setState(() => _isListening = true);
      _micPulseController.repeat(reverse: true);
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
              _hasText = _controller.text.trim().isNotEmpty;
            });
            if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
              _micPulseController.stop();
              setState(() => _isListening = false);
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.dictation,
            cancelOnError: true,
            partialResults: true,
          ),
        );
    }
  }

  void _sendMessage([String? override]) {
    HapticFeedback.lightImpact();
    final text = override ?? _controller.text;
    if (text.trim().isEmpty) return;
    if (override == null) _controller.clear();
    FocusScope.of(context).unfocus();
    ref.read(chatControllerProvider.notifier).sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.charcoalGlass,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSession = ref.watch(chatControllerProvider);
    final isTyping = ref.watch(chatTypingProvider);
    final rateLimitSecs = ref.watch(chatRateLimitProvider);
    final streamingText = ref.watch(chatStreamingTextProvider);
    final messages = currentSession?.messages ?? [];
    final isStreaming = streamingText != null;
    final isEmpty = messages.isEmpty && !isTyping && !isStreaming;

    // Auto-scroll when new message arrives
    ref.listen(chatControllerProvider, (prev, next) {
      if (prev?.id != next?.id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(
                  _scrollController.position.maxScrollExtent);
            }
            if (mounted) setState(() => _showScrollDown = false);
          });
        });
      } else {
        _scrollToBottom();
      }
    });
    ref.listen(chatTypingProvider, (_, __) => _scrollToBottom());
    ref.listen(chatStreamingTextProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildChatDrawer(context),
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.deepObsidian
          : AppColors.cloudGray,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.dark
                    ? const RadialGradient(
                        center: Alignment(0, -0.6),
                        radius: 1.2,
                        colors: [Color(0xFF1A1D35), AppColors.deepObsidian],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, AppColors.cloudGray],
                      ),
              ),
            ),
          ),
          Column(
            children: [
              // Messages list
              Expanded(
                child: isEmpty
                    ? _buildWelcomeState(context)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(
                          left: 14,
                          right: 14,
                          top: MediaQuery.of(context).padding.top + 72,
                          bottom: 12,
                        ),
                        itemCount:
                            messages.length + (isTyping || isStreaming ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length) {
                            if (isStreaming) {
                            return ChatBubble(
                              message: health_app.ChatMessageDoc()
                                ..isUser = false
                                ..text = streamingText
                                ..timestamp = DateTime.now(),
                              isTyping: false,
                              isStreaming: true,
                            ).animate().fadeIn(duration: 180.ms);
                          }
                          return ChatBubble(
                            message: health_app.ChatMessageDoc()
                              ..isUser = false
                              ..text = '',
                            isTyping: true,
                          ).animate().fadeIn(duration: 180.ms);
                        }
                        return ChatBubble(
                          message: messages[index],
                          onReply: _sendMessage,
                        )
                              .animate()
                              .slideY(
                                  begin: 0.06,
                                  end: 0,
                                  duration: 300.ms,
                                  curve: Curves.easeOutCubic)
                              .fadeIn(duration: 260.ms);
                        },
                      ),
              ),

              // Status banners
              if (_isListening) _buildListeningBanner(),
              if (rateLimitSecs > 0) _buildRateLimitBanner(rateLimitSecs),

              // Input bar
              _buildInputBar(context, rateLimitSecs),
            ],
          ),

          // Floating scroll-down button — above input bar, not inside it
          if (_showScrollDown)
            Positioned(
              bottom: _inputBarHeight(context) + 8,
              left: 0,
              right: 0,
              child: Center(
              child: AppAnimatedPressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _scrollToBottom();
                },
                haptic: HapticFeedbackType.none,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.softIndigo, AppColors.dynamicMint],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                        BoxShadow(
                          color: AppColors.softIndigo.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      PhosphorIconsRegular.caretDoubleDown,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ).animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 220.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 180.ms),
              ),
            ),
        ],
      ),
    );
  }

  double _inputBarHeight(BuildContext context) {
    return 78 + MediaQuery.of(context).padding.bottom;
  }

  Widget _buildListeningBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsFill.microphone,
              color: Colors.redAccent, size: 15),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Listening… tap mic to stop',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                color: Colors.redAccent, shape: BoxShape.circle),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(duration: 550.ms),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildRateLimitBanner(int rateLimitSecs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsFill.timer, color: Colors.orange, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Quota reached — ready in $rateLimitSecs second${rateLimitSecs == 1 ? '' : 's'}.',
              style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isOffline = ref.watch(offlineModeProvider);
    final modelState = ref.watch(gemmaModelStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            leadingWidth: 44,
            leading: IconButton(
              icon: Icon(PhosphorIconsRegular.caretLeft,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary, size: 22),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/dashboard');
                  }
                },
            ),
            titleSpacing: 0,
            centerTitle: false,
            title: Row(
              children: [
                // Custom AI logo
                _AiLogoWidget(isOffline: isOffline, size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'HealthAI Coach',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOffline
                                  ? const Color(0xFF4A90D9)
                                  : AppColors.dynamicMint,
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .fade(duration: 1200.ms),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              isOffline
                                  ? 'On-Device · Offline'
                                  : 'AI · Ready',
                              style: TextStyle(
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isOffline &&
                              modelState.status ==
                                  GemmaModelStatus.loading) ...[
                            const SizedBox(width: 5),
                            const SizedBox(
                              width: 8,
                              height: 8,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.dynamicMint,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Weekly Report
              _AppBarButton(
                icon: Icons.insert_chart_outlined_rounded,
                label: 'Report',
                color: AppColors.dynamicMint,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(chatControllerProvider.notifier)
                      .requestWeeklyReport();
                },
              ),
              // AI Mode toggle
              _AppBarButton(
                icon: isOffline ? Icons.memory_rounded : Icons.cloud_outlined,
                label: isOffline ? 'On-Device' : 'Cloud',
                color: isOffline
                    ? const Color(0xFF4A90D9)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                isDark: isDark,
                isActive: isOffline,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (!isOffline) {
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
                  } else {
                    ref.read(offlineModeProvider.notifier).state = false;
                  }
                },
              ),
              // History
              Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(PhosphorIconsRegular.clockCounterClockwise,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary, size: 21),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Scaffold.of(ctx).openEndDrawer();
                  },
                ),
              ),
              const SizedBox(width: 4),
            ],
            backgroundColor: isDark
                ? AppColors.deepObsidian.withValues(alpha: 0.72)
                : Colors.white.withValues(alpha: 0.85),
            elevation: 0,
            scrolledUnderElevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.softIndigo.withValues(alpha: 0.3),
                      AppColors.dynamicMint.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeState(BuildContext context) {
    final suggestions = ref.watch(chatSuggestionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      controller: _scrollController,
      physics: scrollPhysics,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 80,
        left: 22,
        right: 22,
        bottom: _inputBarHeight(context) + 16,
      ),
      children: [
        // Hero area
        Column(
          children: [
            // Large animated AI logo
            _AiLogoWidget(isOffline: false, size: 80)
                .animate()
                .scale(
                  begin: const Offset(0.6, 0.6),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.softIndigo, AppColors.dynamicMint],
              ).createShader(bounds),
              child: const Text(
                'Your Personal\nHealth Coach',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.6,
                  color: Colors.white,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms)
                .slideY(begin: 0.12, end: 0, delay: 150.ms, duration: 400.ms),
            const SizedBox(height: 10),
            Text(
              'Ask me anything about workouts,\nnutrition, sleep, or your health goals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ).animate().fadeIn(delay: 280.ms),
            const SizedBox(height: 28),
          ],
        ),

        // Capability pills
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _CapabilityPill(icon: PhosphorIconsFill.barbell, label: 'Workouts', isDark: isDark),
            _CapabilityPill(icon: PhosphorIconsFill.forkKnife, label: 'Nutrition', isDark: isDark),
            _CapabilityPill(icon: PhosphorIconsFill.heartbeat, label: 'Recovery', isDark: isDark),
            _CapabilityPill(icon: PhosphorIconsFill.moon, label: 'Sleep', isDark: isDark),
          ],
        ).animate().fadeIn(delay: 360.ms),

        const SizedBox(height: 30),

        // Suggestions heading
        Row(
          children: [
            Text(
              'SUGGESTED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.softIndigo, AppColors.dynamicMint],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 420.ms),

        const SizedBox(height: 12),

        // Suggestion tiles
        ...suggestions.asMap().entries.map((e) {
          final idx = e.key;
          final s = e.value;
          return _SuggestionTile(
            icon: s.icon,
            label: s.text,
            isHighlighted: s.isHighlighted,
            isDark: isDark,
            onTap: () => _sendMessage(s.text),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 480 + idx * 70))
              .slideX(
                begin: 0.06,
                end: 0,
                delay: Duration(milliseconds: 480 + idx * 70),
                duration: 320.ms,
                curve: Curves.easeOutCubic,
              );
        }),
      ],
    );
  }

  void _showAttachSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final prompts = [
      (icon: PhosphorIconsFill.forkKnife,    color: Colors.orange,           label: 'Log a meal',         text: 'Help me log what I just ate.'),
      (icon: PhosphorIconsFill.barbell,       color: AppColors.softIndigo,    label: 'Log a workout',      text: 'Help me log my recent workout.'),
      (icon: PhosphorIconsFill.drop,          color: const Color(0xFF41C9E2), label: 'Log water intake',   text: 'I want to log my water intake for today.'),
      (icon: PhosphorIconsFill.moon,          color: Colors.deepPurple,       label: 'Log sleep',          text: 'Help me log my sleep last night.'),
      (icon: PhosphorIconsFill.chartBar,      color: AppColors.dynamicMint,   label: 'Weekly progress',    text: 'Give me a summary of my health progress this week.'),
      (icon: PhosphorIconsFill.sparkle,       color: Colors.amber,            label: 'Daily tip',          text: 'Give me a personalized health tip for today.'),
      (icon: PhosphorIconsFill.heartbeat,     color: AppColors.danger,        label: 'Check my metrics',   text: 'Analyze my current health metrics and tell me how I\'m doing.'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12151F) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.07 : 0),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
                const SizedBox(height: 16),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.softIndigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(PhosphorIconsFill.paperclip,
                        color: AppColors.softIndigo, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text('Quick Actions',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1E23),
                      )),
                ]),
                const SizedBox(height: 4),
                Text('Scan food or start a conversation',
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                    )),
                const SizedBox(height: 14),

                // ── Food scan row ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _ImageScanButton(
                        icon: PhosphorIconsFill.camera,
                        label: 'Scan Food\n(Camera)',
                        color: AppColors.dynamicMint,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(ctx);
                          Future.delayed(const Duration(milliseconds: 150), () {
                            if (mounted) {
                              ref.read(chatControllerProvider.notifier)
                                  .sendImageMessage(source: ImageSource.camera);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ImageScanButton(
                        icon: PhosphorIconsFill.image,
                        label: 'Scan Food\n(Gallery)',
                        color: AppColors.softIndigo,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(ctx);
                          Future.delayed(const Duration(milliseconds: 150), () {
                            if (mounted) {
                              ref.read(chatControllerProvider.notifier)
                                  .sendImageMessage(source: ImageSource.gallery);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.06, duration: 220.ms),
                const SizedBox(height: 14),

                // ── Divider ────────────────────────────────────────────────
                Row(children: [
                  Expanded(child: Divider(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('PROMPTS',
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                        )),
                  ),
                  Expanded(child: Divider(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1))),
                ]),
                const SizedBox(height: 10),

                ...prompts.asMap().entries.map((e) {
                    final p = e.value;
                    return AppAnimatedPressable(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(ctx);
                        Future.delayed(const Duration(milliseconds: 150), () {
                          if (mounted) _sendMessage(p.text);
                        });
                      },
                      haptic: HapticFeedbackType.none,
                      child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: p.color.withValues(alpha: isDark ? 0.10 : 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.color.withValues(alpha: 0.2)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: p.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(p.icon, color: p.color, size: 17),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(p.label,
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white.withValues(alpha: 0.88)
                                  : const Color(0xFF1C1E23),
                            ))),
                        Icon(PhosphorIconsRegular.caretRight,
                            size: 14,
                            color: p.color.withValues(alpha: 0.5)),
                      ]),
                    ),
                  ).animate(delay: Duration(milliseconds: 40 * e.key))
                      .fadeIn(duration: 220.ms)
                      .slideY(begin: 0.06, duration: 220.ms, curve: Curves.easeOutCubic);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar(BuildContext context, int rateLimitSecs) {
    final isBlocked = rateLimitSecs > 0;
    final isOffline = ref.watch(offlineModeProvider);
    final modelLoading =
        ref.watch(gemmaModelStateProvider).status == GemmaModelStatus.loading;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Colors.transparent,
                  AppColors.deepObsidian.withValues(alpha: 0.4),
                  AppColors.deepObsidian.withValues(alpha: 0.7),
                ]
              : [
                  Colors.transparent,
                  AppColors.cloudGray.withValues(alpha: 0.4),
                  AppColors.cloudGray.withValues(alpha: 0.7),
                ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          8, 10, 8, bottomPadding > 0 ? bottomPadding + 4 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Emoji Button (Separate & Circular) ─────────────────────────────
          AppAnimatedPressable(
            onTap: () {}, // To be implemented
            pressScale: 0.88,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark 
                    ? const Color(0xFF1F2C34).withValues(alpha: 0.95) 
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  PhosphorIconsRegular.smiley,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  size: 26,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Refined Input Pill ──────────────────────────────────────────────
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF1F2C34).withValues(alpha: 0.95) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  // Main Text Input
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(
                          color: isDark 
                              ? Colors.white.withValues(alpha: 0.3) 
                              : Colors.black.withValues(alpha: 0.3),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      enabled: !isBlocked && !modelLoading,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  
                  // Attachment Icon (Inside Pill)
                  IconButton(
                    icon: Icon(
                      PhosphorIconsRegular.paperclip,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      size: 24,
                    ),
                    onPressed: () => _showAttachSheet(context),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Main Action Button (Mic / Send) ─────────────────────────────────
          AppAnimatedPressable(
            key: ValueKey(_hasText ? 'send' : 'mic'),
            onTap: _hasText ? _sendMessage : _toggleListening,
            pressScale: 0.88,
            haptic: HapticFeedbackType.medium,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.dynamicMint,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dynamicMint.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _hasText
                      ? PhosphorIconsFill.paperPlaneRight
                      : PhosphorIconsFill.microphone,
                  color: Colors.black.withValues(alpha: 0.8),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatDrawer(BuildContext context) {
    return const ChatHistoryDrawer();
  }
}

// ─── AI Logo Widget ───────────────────────────────────────────────────────────

class _AiLogoWidget extends StatelessWidget {
  final bool isOffline;
  final double size;

  const _AiLogoWidget({required this.isOffline, required this.size});

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        isOffline ? const Color(0xFF4A90D9) : AppColors.softIndigo;
    final accentColor =
        isOffline ? AppColors.dynamicMint : AppColors.dynamicMint;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            primaryColor.withValues(alpha: 0.25),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: size * 0.4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring glow
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryColor, accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Inner icon
          CustomPaint(
            size: Size(size * 0.46, size * 0.46),
            painter: _NeuralIconPainter(primaryColor: primaryColor),
          ),
          // Status dot
                    Positioned(
                      bottom: size * 0.04,
                      right: size * 0.04,
                      child: Container(
                        width: size * 0.22,
                        height: size * 0.22,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.deepObsidian
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                      )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 0.6, end: 1.0, duration: 1400.ms),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .custom(
          duration: 2400.ms,
          builder: (context, value, child) => Transform.scale(
            scale: 1.0 + (value * 0.04),
            child: child,
          ),
        );
  }
}

class _NeuralIconPainter extends CustomPainter {
  final Color primaryColor;
  _NeuralIconPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.18;

    // Neural network nodes
    final nodes = [
      Offset(cx, cy * 0.28),           // top
      Offset(cx - r * 1.6, cy),        // left
      Offset(cx + r * 1.6, cy),        // right
      Offset(cx - r * 0.8, cy * 1.7),  // bottom-left
      Offset(cx + r * 0.8, cy * 1.7),  // bottom-right
      Offset(cx, cy),                   // center
    ];

    // Connections
    final connections = [
      [0, 5], [1, 5], [2, 5], [5, 3], [5, 4],
      [0, 1], [0, 2], [1, 3], [2, 4], [3, 4],
    ];

    paint.color = Colors.white.withValues(alpha: 0.45);
    for (final conn in connections) {
      canvas.drawLine(nodes[conn[0]], nodes[conn[1]], paint);
    }

    // Draw nodes
    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < nodes.length; i++) {
      final nodeRadius = i == 5 ? r * 0.85 : r * 0.65;
      canvas.drawCircle(nodes[i], nodeRadius, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── App Bar Button ───────────────────────────────────────────────────────────

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDark;

  const _AppBarButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isActive = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPressable(
      onTap: onTap,
      pressScale: 0.93,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.18)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.45)
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Suggestion tile ──────────────────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isHighlighted;
  final bool isDark;

  const _SuggestionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPressable(
      onTap: onTap,
      pressScale: 0.97,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.softIndigo.withValues(alpha: 0.14)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlighted
                ? AppColors.softIndigo.withValues(alpha: 0.4)
                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
            width: isHighlighted ? 1.5 : 1.0,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: AppColors.softIndigo.withValues(alpha: 0.12),
                    blurRadius: 16,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isHighlighted
                      ? [
                          AppColors.softIndigo.withValues(alpha: 0.6),
                          AppColors.dynamicMint.withValues(alpha: 0.4),
                        ]
                      : (isDark
                          ? [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.06),
                            ]
                          : [
                              Colors.black.withValues(alpha: 0.06),
                              Colors.black.withValues(alpha: 0.04),
                            ]),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: isHighlighted
                    ? Colors.white
                    : (isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.lightTextPrimary.withValues(alpha: 0.7)),
                size: 17,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isHighlighted
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: isDark
                      ? Colors.white.withValues(alpha: isHighlighted ? 0.95 : 0.75)
                      : AppColors.lightTextPrimary.withValues(alpha: isHighlighted ? 1.0 : 0.8),
                ),
              ),
            ),
            if (isHighlighted)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.softIndigo, AppColors.dynamicMint],
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'For you',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              )
            else
              Icon(
                PhosphorIconsRegular.arrowRight,
                size: 16,
                color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Capability pill ──────────────────────────────────────────────────────────

class _CapabilityPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _CapabilityPill({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.softIndigo.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.softIndigo, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.softIndigo,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── History Drawer ───────────────────────────────────────────────────────────

class ChatHistoryDrawer extends ConsumerStatefulWidget {
  const ChatHistoryDrawer({super.key});

  @override
  ConsumerState<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends ConsumerState<ChatHistoryDrawer> {
  String _searchQuery = '';

  void _showContextMenu(
      BuildContext context, health_app.ChatSessionDoc session) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.charcoalGlass.withValues(alpha: 0.92),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(
                      session.isPinned
                          ? PhosphorIconsRegular.pushPinSlash
                          : PhosphorIconsRegular.pushPin,
                      color: Colors.white,
                    ),
                    title: Text(
                      session.isPinned ? 'Unpin' : 'Pin to top',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      session.isPinned = !session.isPinned;
                      await ref
                          .read(health_app.isarProvider)
                          .writeTxn(() async {
                        await ref
                            .read(health_app.isarProvider)
                            .chatSessionDocs
                            .put(session);
                      });
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.pencilSimple,
                        color: Colors.white),
                    title: const Text('Rename',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      _showRenameDialog(context, session);
                    },
                  ),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.trash,
                        color: Colors.redAccent),
                    title: const Text('Delete',
                        style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      Navigator.pop(context);
                      await ref
                          .read(health_app.isarProvider)
                          .writeTxn(() async {
                        await ref
                            .read(health_app.isarProvider)
                            .chatSessionDocs
                            .delete(session.id);
                      });
                      if (ref.read(chatControllerProvider)?.id == session.id) {
                        ref
                            .read(chatControllerProvider.notifier)
                            .startNewSession();
                      }
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, health_app.ChatSessionDoc session) {
    final controller = TextEditingController(text: session.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.charcoalGlass,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rename Chat',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                session.title = controller.text.trim();
                await ref.read(health_app.isarProvider).writeTxn(() async {
                  await ref
                      .read(health_app.isarProvider)
                      .chatSessionDocs
                      .put(session);
                });
                if (ref.read(chatControllerProvider)?.id == session.id) {
                  ref
                      .read(chatControllerProvider.notifier)
                      .loadSession(session.id);
                }
                if (mounted) {
                  setState(() {});
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.softIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Drawer(
          backgroundColor: isDark
              ? AppColors.deepObsidian.withValues(alpha: 0.88)
              : Colors.white.withValues(alpha: 0.97),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      _AiLogoWidget(isOffline: false, size: 34),
                      const SizedBox(width: 10),
                      Text(
                        'Chat History',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (val) =>
                        setState(() => _searchQuery = val),
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search chats...',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade500),
                      prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass,
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                          size: 17),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.08)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: AppColors.softIndigo.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                ),

                // New chat button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.softIndigo, AppColors.dynamicMint],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.softIndigo.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref
                            .read(chatControllerProvider.notifier)
                            .startNewSession();
                        Navigator.pop(context);
                      },
                      icon: const Icon(PhosphorIconsRegular.plus, size: 16),
                      label: const Text('New Chat',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                    child: Text(
                      'RECENT',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  Expanded(
                    child: StreamBuilder<List<health_app.ChatSessionDoc>>(
                      stream: ref
                          .read(health_app.isarProvider)
                          .chatSessionDocs
                          .where()
                          .filter()
                          .titleContains(_searchQuery, caseSensitive: false)
                          .sortByIsPinnedDesc()
                          .thenByUpdatedAtDesc()
                          .watch(fireImmediately: true),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2));
                        }
                        final sessions = snapshot.data!;
                        if (sessions.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(PhosphorIconsRegular.chatCircle,
                                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade400, size: 36),
                                const SizedBox(height: 10),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No chats yet'
                                      : 'No matches',
                                  style: TextStyle(
                                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          final isActive =
                              ref.watch(chatControllerProvider)?.id ==
                                  session.id;
                          return _SessionTile(
                            session: session,
                            isActive: isActive,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(chatControllerProvider.notifier)
                                  .loadSession(session.id);
                              Navigator.pop(context);
                            },
                            onLongPress: () =>
                                _showContextMenu(context, session),
                          )
                              .animate()
                              .fadeIn(
                                  delay:
                                      Duration(milliseconds: index * 30),
                                  duration: 200.ms)
                              .slideX(
                                  begin: 0.04,
                                  end: 0,
                                  delay:
                                      Duration(milliseconds: index * 30),
                                  duration: 200.ms);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final health_app.ChatSessionDoc session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _SessionTile({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: isActive
            ? AppColors.softIndigo.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(13),
          splashColor: AppColors.softIndigo.withValues(alpha: 0.12),
          child: Container(
            decoration: isActive
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border(
                      left: BorderSide(
                        color: AppColors.softIndigo,
                        width: 3,
                      ),
                    ),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  session.isPinned
                      ? PhosphorIconsFill.pushPin
                      : PhosphorIconsRegular.chatCircle,
                  color: isActive
                      ? AppColors.softIndigo
                      : (session.isPinned
                          ? AppColors.dynamicMint
                          : (isDark ? Colors.grey.shade600 : Colors.grey.shade500)),
                  size: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isActive
                              ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                              : (isDark ? Colors.grey.shade300 : AppColors.lightTextPrimary.withValues(alpha: 0.85)),
                          fontSize: 14,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(session.updatedAt),
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.dynamicMint,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fade(duration: 1200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── Image Scan Button ────────────────────────────────────────────────────────

class _ImageScanButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ImageScanButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimatedPressable(
      onTap: onTap,
      pressScale: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF1C1E23),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
