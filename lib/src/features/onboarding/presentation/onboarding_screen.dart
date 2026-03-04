import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/app_ui.dart';
import '../../profile/application/user_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  bool _saving = false;

  final _nameCtrl    = TextEditingController();
  DateTime? _dob;
  String _gender     = 'male';
  final _heightCtrl  = TextEditingController();
  final _weightCtrl  = TextEditingController();
  String _goal       = 'general_fitness';
  String _fitnessLevel = 'beginner';
  final List<String> _dietary = [];

  static const int _totalPages = 5;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _totalPages - 1) {
      HapticFeedback.lightImpact();
      _pageCtrl.animateToPage(_page + 1,
          duration: 380.ms, curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) {
      HapticFeedback.lightImpact();
      _pageCtrl.previousPage(duration: 380.ms, curve: Curves.easeOutCubic);
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    await ref.read(userProvider.notifier).completeOnboarding(
          name: _nameCtrl.text.trim().isEmpty ? 'Friend' : _nameCtrl.text.trim(),
          heightCm: double.tryParse(_heightCtrl.text),
          weightKg: double.tryParse(_weightCtrl.text),
          dob: _dob,
          gender: _gender,
          primaryGoal: _goal,
          fitnessLevel: _fitnessLevel,
          dietary: _dietary,
        );
    if (mounted) context.go('/dashboard');
  }

  bool get _canNext {
    if (_page == 0) return _nameCtrl.text.trim().isNotEmpty;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.deepObsidian,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF080A16), Color(0xFF0C1422)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Ambient orb top-right
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.softIndigo.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Ambient orb bottom-left
          Positioned(
            bottom: -60, left: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.dynamicMint.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button
                      AnimatedOpacity(
                        opacity: _page > 0 ? 1.0 : 0.0,
                        duration: 200.ms,
                        child: AppAnimatedPressable(
                          onTap: _page > 0 ? _back : null,
                          pressScale: 0.88,
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: const Icon(PhosphorIconsRegular.caretLeft,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Segmented progress bar
                      SizedBox(
                        width: size.width * 0.42,
                        height: 4,
                        child: Row(
                          children: List.generate(_totalPages, (i) {
                            return Expanded(
                              child: AnimatedContainer(
                                duration: 350.ms,
                                curve: Curves.easeOutCubic,
                                margin: EdgeInsets.only(right: i < _totalPages - 1 ? 4 : 0),
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: i <= _page
                                      ? const LinearGradient(
                                          colors: [AppColors.softIndigo, AppColors.dynamicMint],
                                        )
                                      : null,
                                  color: i > _page
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const Spacer(),
                      // Skip / step indicator
                      AnimatedOpacity(
                        opacity: _page < _totalPages - 1 ? 1.0 : 0.0,
                        duration: 200.ms,
                        child: GestureDetector(
                          onTap: _page < _totalPages - 1
                              ? () {
                                  HapticFeedback.lightImpact();
                                  context.go('/dashboard');
                                }
                              : null,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // ── Page content ─────────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _page = i),
                    children: [
                      _PageWelcome(nameCtrl: _nameCtrl, onChanged: () => setState(() {})),
                      _PagePersonal(
                        dob: _dob,
                        gender: _gender,
                        onDobChanged: (d) => setState(() => _dob = d),
                        onGenderChanged: (g) => setState(() => _gender = g),
                      ),
                      _PageBody(heightCtrl: _heightCtrl, weightCtrl: _weightCtrl),
                      _PageGoal(
                        goal: _goal,
                        fitnessLevel: _fitnessLevel,
                        onGoalChanged: (g) => setState(() => _goal = g),
                        onLevelChanged: (l) => setState(() => _fitnessLevel = l),
                      ),
                      _PageDietary(
                        selected: _dietary,
                        onToggle: (d) => setState(() {
                          _dietary.contains(d) ? _dietary.remove(d) : _dietary.add(d);
                        }),
                      ),
                    ],
                  ),
                ),

                // ── Bottom CTA ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
                  child: AppGradientButton(
                    label: _page < _totalPages - 1 ? 'Continue' : 'Get Started',
                    isLoading: _saving,
                    onTap: (_canNext && !_saving) ? _next : null,
                    gradientColors: _canNext
                        ? [AppColors.softIndigo, AppColors.dynamicMint]
                        : [
                            AppColors.softIndigo.withValues(alpha: 0.4),
                            AppColors.dynamicMint.withValues(alpha: 0.4),
                          ],
                    height: 58,
                    icon: _page < _totalPages - 1 ? PhosphorIconsFill.arrowRight : PhosphorIconsFill.rocketLaunch,
                    borderRadius: AppRadius.hero,
                  ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 1: Welcome + Name ─────────────────────────────────────────────────────
class _PageWelcome extends StatelessWidget {
  final TextEditingController nameCtrl;
  final VoidCallback onChanged;
  const _PageWelcome({required this.nameCtrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 74, height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [AppColors.softIndigo, AppColors.dynamicMint],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.softIndigo.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(PhosphorIconsFill.heartbeat, color: Colors.white, size: 36),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 28),

          const Text('Welcome to\nHealthAI',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1.2))
              .animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 14),

          Text(
            'Your personal AI health coach.\nLet\'s start by getting to know you.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 15,
              height: 1.55,
            ),
          ).animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 40),

          Text('What should we call you?',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3))
              .animate(delay: 280.ms).fadeIn(),

          const SizedBox(height: 10),

          TextField(
            controller: nameCtrl,
            onChanged: (_) => onChanged(),
            autofocus: true,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            cursorColor: AppColors.softIndigo,
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.28)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.softIndigo, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              prefixIcon: const Icon(PhosphorIconsRegular.user,
                  color: AppColors.softIndigo, size: 20),
            ),
          ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 24),

          // Feature pills row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FeaturePill(icon: PhosphorIconsFill.brain, label: 'AI-Powered'),
              _FeaturePill(icon: PhosphorIconsFill.lock, label: 'Private'),
              _FeaturePill(icon: PhosphorIconsFill.chartBar, label: 'Smart Insights'),
            ],
          ).animate(delay: 500.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.dynamicMint, size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 2: Personal (DOB + Gender) ──────────────────────────────────────────
class _PagePersonal extends StatelessWidget {
  final DateTime? dob;
  final String gender;
  final ValueChanged<DateTime> onDobChanged;
  final ValueChanged<String> onGenderChanged;

  const _PagePersonal({
    required this.dob,
    required this.gender,
    required this.onDobChanged,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dobLabel = dob == null
        ? 'Select date of birth'
        : '${dob!.day}/${dob!.month}/${dob!.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            icon: PhosphorIconsFill.calendar,
            gradientColors: [const Color(0xFF6B7AFF), AppColors.dynamicMint],
            title: 'About You',
            subtitle: 'Help us personalise your experience.',
          ),
          const SizedBox(height: 36),

          _FieldLabel('Date of Birth'),
          const SizedBox(height: 10),

          AppAnimatedPressable(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000, 1, 1),
                firstDate: DateTime(1930),
                lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                builder: (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(primary: AppColors.softIndigo),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onDobChanged(picked);
            },
            child: AnimatedContainer(
              duration: 200.ms,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: dob != null
                      ? AppColors.softIndigo.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.1),
                  width: dob != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.calendarBlank,
                    color: dob != null ? AppColors.softIndigo : Colors.white.withValues(alpha: 0.35),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    dobLabel,
                    style: TextStyle(
                      color: dob != null ? Colors.white : Colors.white.withValues(alpha: 0.28),
                      fontSize: 16,
                      fontWeight: dob != null ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),
          _FieldLabel('Gender'),
          const SizedBox(height: 10),

          Row(
            children: [
              _GenderChip(label: 'Male',   value: 'male',   icon: PhosphorIconsFill.genderMale,   selected: gender, onTap: onGenderChanged),
              const SizedBox(width: 10),
              _GenderChip(label: 'Female', value: 'female', icon: PhosphorIconsFill.genderFemale, selected: gender, onTap: onGenderChanged),
              const SizedBox(width: 10),
              _GenderChip(label: 'Other',  value: 'other',  icon: PhosphorIconsFill.genderNeuter, selected: gender, onTap: onGenderChanged),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Page 3: Body Metrics ──────────────────────────────────────────────────────
class _PageBody extends StatelessWidget {
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  const _PageBody({required this.heightCtrl, required this.weightCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            icon: PhosphorIconsFill.ruler,
            gradientColors: [AppColors.dynamicMint, const Color(0xFF00B4D8)],
            title: 'Body Metrics',
            subtitle: 'Used to calculate your calorie goals.',
          ),
          const SizedBox(height: 36),

          _FieldLabel('Height (cm)'),
          const SizedBox(height: 10),
          _DarkTextField(
            ctrl: heightCtrl,
            hint: 'e.g. 175',
            keyboardType: TextInputType.number,
            icon: PhosphorIconsRegular.arrowsVertical,
          ),

          const SizedBox(height: 20),
          _FieldLabel('Weight (kg)'),
          const SizedBox(height: 10),
          _DarkTextField(
            ctrl: weightCtrl,
            hint: 'e.g. 72',
            keyboardType: TextInputType.number,
            icon: PhosphorIconsRegular.scales,
          ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softIndigo.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.softIndigo.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(PhosphorIconsFill.info, color: AppColors.softIndigo, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Used for your daily calorie goal via the Mifflin-St Jeor formula. Update anytime in Settings.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 4: Goal + Fitness Level ──────────────────────────────────────────────
class _PageGoal extends StatelessWidget {
  final String goal;
  final String fitnessLevel;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<String> onLevelChanged;

  const _PageGoal({
    required this.goal,
    required this.fitnessLevel,
    required this.onGoalChanged,
    required this.onLevelChanged,
  });

  static const _goals = [
    ('weight_loss',     PhosphorIconsFill.arrowDown,        'Weight Loss',    'Burn fat, feel lighter'),
    ('muscle_gain',     PhosphorIconsFill.barbell,           'Muscle Gain',    'Build strength & mass'),
    ('general_fitness', PhosphorIconsFill.heartbeat,         'Stay Fit',       'Overall health & energy'),
    ('endurance',       PhosphorIconsFill.personSimpleRun,   'Endurance',      'Run further, last longer'),
    ('flexibility',     PhosphorIconsFill.flowerLotus,       'Flexibility',    'Mobility & stress relief'),
  ];

  static const _levels = [
    ('beginner',     'Beginner',      'New to exercise'),
    ('intermediate', 'Intermediate',  '1–2 years'),
    ('advanced',     'Advanced',      '3+ years'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            icon: PhosphorIconsFill.target,
            gradientColors: [AppColors.warning, const Color(0xFFFF6B35)],
            title: 'Your Goal',
            subtitle: 'We\'ll tailor everything around this.',
          ),
          const SizedBox(height: 24),

          ..._goals.asMap().entries.map((entry) {
            final i = entry.key;
            final (val, icon, label, sub) = entry.value;
            final isSel = val == goal;

            return AppAnimatedPressable(
              onTap: () {
                HapticFeedback.selectionClick();
                onGoalChanged(val);
              },
              child: AnimatedContainer(
                duration: 200.ms,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isSel
                      ? AppColors.softIndigo.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSel
                        ? AppColors.softIndigo.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.08),
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: 200.ms,
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.softIndigo.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon,
                          color: isSel ? AppColors.softIndigo : Colors.white.withValues(alpha: 0.45),
                          size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: TextStyle(
                                color: isSel ? Colors.white : Colors.white.withValues(alpha: 0.65),
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        Text(sub,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: isSel ? 1.0 : 0.0,
                      duration: 200.ms,
                      child: const Icon(PhosphorIconsFill.checkCircle,
                          color: AppColors.softIndigo, size: 20),
                    ),
                  ],
                ),
              ),
            ).animate(delay: Duration(milliseconds: 80 + i * 50))
                .fadeIn().slideX(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
          }),

          const SizedBox(height: 20),
          _FieldLabel('Fitness Level'),
          const SizedBox(height: 10),

          Row(
            children: _levels.asMap().entries.map((entry) {
              final i = entry.key;
              final (val, label, sub) = entry.value;
              final isSel = val == fitnessLevel;

              return Expanded(
                child: AppAnimatedPressable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onLevelChanged(val);
                  },
                  child: AnimatedContainer(
                    duration: 200.ms,
                    margin: EdgeInsets.only(right: i < _levels.length - 1 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.dynamicMint.withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel
                            ? AppColors.dynamicMint.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.08),
                        width: isSel ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(label,
                            style: TextStyle(
                                color: isSel ? AppColors.dynamicMint : Colors.white.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(sub,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Page 5: Dietary Preferences ───────────────────────────────────────────────
class _PageDietary extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const _PageDietary({required this.selected, required this.onToggle});

  static const _options = [
    ('vegetarian',   PhosphorIconsFill.leaf,           'Vegetarian'),
    ('vegan',        PhosphorIconsFill.plant,           'Vegan'),
    ('keto',         PhosphorIconsFill.egg,             'Keto'),
    ('gluten_free',  PhosphorIconsFill.bread,           'Gluten Free'),
    ('dairy_free',   PhosphorIconsFill.drop,            'Dairy Free'),
    ('halal',        PhosphorIconsFill.star,            'Halal'),
    ('paleo',        PhosphorIconsFill.fire,            'Paleo'),
    ('intermittent', PhosphorIconsFill.clockCountdown,  'Intermittent Fasting'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            icon: PhosphorIconsFill.forkKnife,
            gradientColors: [const Color(0xFFFF9F43), const Color(0xFFFF6B35)],
            title: 'Dietary Needs',
            subtitle: 'Select all that apply. You can skip this.',
          ),
          const SizedBox(height: 28),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _options.asMap().entries.map((entry) {
              final i = entry.key;
              final (val, icon, label) = entry.value;
              final isSel = selected.contains(val);

              return AppAnimatedPressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggle(val);
                },
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.dynamicMint.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isSel
                          ? AppColors.dynamicMint.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.1),
                      width: isSel ? 1.5 : 1,
                    ),
                    boxShadow: isSel
                        ? [BoxShadow(color: AppColors.dynamicMint.withValues(alpha: 0.15), blurRadius: 10)]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon,
                          color: isSel ? AppColors.dynamicMint : Colors.white.withValues(alpha: 0.35),
                          size: 15),
                      const SizedBox(width: 7),
                      Text(label,
                          style: TextStyle(
                              color: isSel ? AppColors.dynamicMint : Colors.white.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: 60 + i * 40))
                  .fadeIn().scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), curve: Curves.easeOutBack);
            }).toList(),
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.softIndigo.withValues(alpha: 0.15),
                  AppColors.dynamicMint.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.softIndigo.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.softIndigo.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(PhosphorIconsFill.sparkle,
                      color: AppColors.softIndigo, size: 18),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "You're all set!",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'HealthAI will generate a personalised plan based on your profile.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;

  const _PageHeader({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

        const SizedBox(height: 22),

        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.9,
                height: 1.1))
            .animate(delay: 80.ms).fadeIn().slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 8),

        Text(subtitle,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
                height: 1.45))
            .animate(delay: 150.ms).fadeIn(),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5));
  }
}

class _DarkTextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextInputType keyboardType;
  final IconData icon;

  const _DarkTextField({
    required this.ctrl,
    required this.hint,
    required this.keyboardType,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(
          color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
      cursorColor: AppColors.softIndigo,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.28)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.softIndigo, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        prefixIcon: Icon(icon,
            color: AppColors.softIndigo.withValues(alpha: 0.7), size: 20),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String selected;
  final ValueChanged<String> onTap;

  const _GenderChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSel = value == selected;
    return Expanded(
      child: AppAnimatedPressable(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(value);
        },
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSel
                ? AppColors.softIndigo.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSel
                  ? AppColors.softIndigo.withValues(alpha: 0.65)
                  : Colors.white.withValues(alpha: 0.08),
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSel ? AppColors.softIndigo : Colors.white.withValues(alpha: 0.35),
                  size: 20),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      color: isSel ? Colors.white : Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
