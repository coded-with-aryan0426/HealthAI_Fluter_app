import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:health_app/src/theme/app_colors.dart';
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

  // ── Form state ───────────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  DateTime? _dob;
  String _gender = 'male';
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _goal = 'general_fitness';
  String _fitnessLevel = 'beginner';
  final List<String> _dietary = [];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 4) {
      HapticFeedback.lightImpact();
      _pageCtrl.animateToPage(_page + 1,
          duration: 400.ms, curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) {
      HapticFeedback.lightImpact();
      _pageCtrl.previousPage(
          duration: 400.ms, curve: Curves.easeOutCubic);
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
    if (mounted) context.go('/home');
  }

  bool get _canNext {
    switch (_page) {
      case 0: return _nameCtrl.text.trim().isNotEmpty;
      case 1: return true; // DOB optional
      case 2: return true; // Height/weight optional
      case 3: return true;
      case 4: return true;
      default: return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepObsidian,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A0A1A), Color(0xFF0D1B2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Ambient orb top-right
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.softIndigo.withOpacity(0.08),
              ),
            ),
          ),
          // Ambient orb bottom-left
          Positioned(
            bottom: -40, left: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.dynamicMint.withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      if (_page > 0)
                        GestureDetector(
                          onTap: _back,
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(PhosphorIconsRegular.caretLeft,
                                color: Colors.white, size: 18),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                      const Spacer(),
                      // Step dots
                      Row(
                        children: List.generate(5, (i) => AnimatedContainer(
                          duration: 300.ms,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? AppColors.softIndigo
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        )),
                      ),
                      const Spacer(),
                      if (_page < 4)
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Text('Skip',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Page content ────────────────────────────────────────
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
                      _PageBody(
                        heightCtrl: _heightCtrl,
                        weightCtrl: _weightCtrl,
                      ),
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

                // ── Bottom CTA ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: (_canNext && !_saving) ? _next : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.softIndigo,
                        disabledBackgroundColor: AppColors.softIndigo.withOpacity(0.3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        shadowColor: AppColors.softIndigo.withOpacity(0.4),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              _page < 4 ? 'Continue' : 'Get Started',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: 0.3),
                            ),
                    ),
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 1: Welcome + Name ────────────────────────────────────────────────────
class _PageWelcome extends StatelessWidget {
  final TextEditingController nameCtrl;
  final VoidCallback onChanged;
  const _PageWelcome({required this.nameCtrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [AppColors.softIndigo, AppColors.dynamicMint],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(PhosphorIconsFill.heartbeat,
                color: Colors.white, size: 36),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 28),
          const Text('Welcome to\nHealthAI',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1))
              .animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 12),
          Text('Your personal AI health coach.\nLet\'s start by getting to know you.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                  height: 1.5))
              .animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 40),
          Text('What should we call you?',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600))
              .animate(delay: 300.ms).fadeIn(),
          const SizedBox(height: 10),
          TextField(
            controller: nameCtrl,
            onChanged: (_) => onChanged(),
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.softIndigo, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              prefixIcon: const Icon(PhosphorIconsRegular.user,
                  color: AppColors.softIndigo, size: 20),
            ),
          ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1),
        ],
      ),
    );
  }
}

// ── Page 2: Personal (DOB + Gender) ─────────────────────────────────────────
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
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            icon: PhosphorIconsFill.calendar,
            title: 'About You',
            subtitle: 'Help us personalize your experience.',
          ),
          const SizedBox(height: 36),
          _FieldLabel('Date of Birth'),
          const SizedBox(height: 10),
          GestureDetector(
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: dob != null
                    ? Border.all(color: AppColors.softIndigo.withOpacity(0.5))
                    : null,
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.calendarBlank,
                      color: dob != null ? AppColors.softIndigo : Colors.white.withOpacity(0.4),
                      size: 20),
                  const SizedBox(width: 12),
                  Text(dobLabel,
                      style: TextStyle(
                          color: dob != null ? Colors.white : Colors.white.withOpacity(0.3),
                          fontSize: 16,
                          fontWeight: dob != null ? FontWeight.w600 : FontWeight.normal)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          _FieldLabel('Gender'),
          const SizedBox(height: 10),
          Row(
            children: [
              _GenderChip(label: 'Male', value: 'male', icon: PhosphorIconsFill.genderMale, selected: gender, onTap: onGenderChanged),
              const SizedBox(width: 12),
              _GenderChip(label: 'Female', value: 'female', icon: PhosphorIconsFill.genderFemale, selected: gender, onTap: onGenderChanged),
              const SizedBox(width: 12),
              _GenderChip(label: 'Other', value: 'other', icon: PhosphorIconsFill.genderNeuter, selected: gender, onTap: onGenderChanged),
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
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            icon: PhosphorIconsFill.ruler,
            title: 'Body Metrics',
            subtitle: 'Used to calculate your calorie goals.',
          ),
          const SizedBox(height: 36),
          _FieldLabel('Height (cm)'),
          const SizedBox(height: 10),
          _DarkTextField(ctrl: heightCtrl, hint: 'e.g. 175', keyboardType: TextInputType.number,
              icon: PhosphorIconsRegular.arrowsVertical),
          const SizedBox(height: 20),
          _FieldLabel('Weight (kg)'),
          const SizedBox(height: 10),
          _DarkTextField(ctrl: weightCtrl, hint: 'e.g. 72', keyboardType: TextInputType.number,
              icon: PhosphorIconsRegular.scales),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softIndigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.softIndigo.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(PhosphorIconsFill.info, color: AppColors.softIndigo, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'These metrics help us calculate your daily calorie goal using the Mifflin-St Jeor formula. You can update them anytime.',
                    style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12, height: 1.4),
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
    ('weight_loss',     PhosphorIconsFill.arrowDown,       'Weight Loss',      'Burn fat, feel lighter'),
    ('muscle_gain',     PhosphorIconsFill.barbell,          'Muscle Gain',      'Build strength & mass'),
    ('general_fitness', PhosphorIconsFill.heartbeat,        'Stay Fit',         'Overall health & energy'),
    ('endurance',       PhosphorIconsFill.personSimpleRun,  'Endurance',        'Run further, last longer'),
    ('flexibility',     PhosphorIconsFill.flowerLotus,      'Flexibility',      'Mobility & stress relief'),
  ];

  static const _levels = [
    ('beginner',     'Beginner',      'New to regular exercise'),
    ('intermediate', 'Intermediate',  '1–2 years of training'),
    ('advanced',     'Advanced',      '3+ years, consistent'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            icon: PhosphorIconsFill.target,
            title: 'Your Goal',
            subtitle: 'We\'ll tailor everything around this.',
          ),
          const SizedBox(height: 28),
          ..._goals.map((g) {
            final (val, icon, label, sub) = g;
            final isSel = val == goal;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onGoalChanged(val);
              },
              child: AnimatedContainer(
                duration: 200.ms,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.softIndigo.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? AppColors.softIndigo : Colors.white.withOpacity(0.08),
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon,
                        color: isSel ? AppColors.softIndigo : Colors.white.withOpacity(0.5),
                        size: 22),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: TextStyle(
                                color: isSel ? Colors.white : Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(sub,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4), fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    if (isSel)
                      const Icon(PhosphorIconsFill.checkCircle,
                          color: AppColors.softIndigo, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          _FieldLabel('Fitness Level'),
          const SizedBox(height: 10),
          Row(
            children: _levels.map((l) {
              final (val, label, _) = l;
              final isSel = val == fitnessLevel;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onLevelChanged(val);
                  },
                  child: AnimatedContainer(
                    duration: 200.ms,
                      margin: EdgeInsets.only(right: val != 'advanced' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.dynamicMint.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel ? AppColors.dynamicMint : Colors.white.withOpacity(0.08),
                        width: isSel ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(label,
                          style: TextStyle(
                              color: isSel ? AppColors.dynamicMint : Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w700, fontSize: 12)),
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
    ('vegetarian',   PhosphorIconsFill.leaf,      'Vegetarian'),
    ('vegan',        PhosphorIconsFill.plant,      'Vegan'),
    ('keto',         PhosphorIconsFill.egg,        'Keto'),
    ('gluten_free',  PhosphorIconsFill.bread,      'Gluten Free'),
    ('dairy_free',   PhosphorIconsFill.drop,       'Dairy Free'),
    ('halal',        PhosphorIconsFill.star,       'Halal'),
    ('paleo',        PhosphorIconsFill.fire,       'Paleo'),
    ('intermittent', PhosphorIconsFill.clockCountdown, 'Intermittent Fasting'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            icon: PhosphorIconsFill.forkKnife,
            title: 'Dietary Needs',
            subtitle: 'Select all that apply. You can skip this.',
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _options.map((opt) {
              final (val, icon, label) = opt;
              final isSel = selected.contains(val);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggle(val);
                },
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.dynamicMint.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isSel ? AppColors.dynamicMint : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon,
                          color: isSel ? AppColors.dynamicMint : Colors.white.withOpacity(0.4),
                          size: 16),
                      const SizedBox(width: 8),
                      Text(label,
                          style: TextStyle(
                              color: isSel ? AppColors.dynamicMint : Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.softIndigo.withOpacity(0.15), AppColors.dynamicMint.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.softIndigo.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(PhosphorIconsFill.sparkle, color: AppColors.softIndigo, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("You're all set!",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('HealthAI will generate a personalized plan based on your profile.',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4)),
                    ],
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

// ── Shared helpers ────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PageHeader({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: AppColors.softIndigo.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.softIndigo.withOpacity(0.3)),
          ),
          child: Icon(icon, color: AppColors.softIndigo, size: 26),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 20),
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 30,
                fontWeight: FontWeight.w900, letterSpacing: -0.8))
            .animate(delay: 80.ms).fadeIn().slideY(begin: 0.08),
        const SizedBox(height: 8),
        Text(subtitle,
            style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 14, height: 1.4))
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
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2));
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
      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.softIndigo, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        prefixIcon: Icon(icon, color: AppColors.softIndigo.withOpacity(0.7), size: 20),
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
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(value);
        },
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSel ? AppColors.softIndigo.withOpacity(0.2) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSel ? AppColors.softIndigo : Colors.white.withOpacity(0.08),
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSel ? AppColors.softIndigo : Colors.white.withOpacity(0.4),
                  size: 20),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      color: isSel ? Colors.white : Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
