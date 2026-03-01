import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:health_app/src/theme/app_colors.dart';
import 'package:health_app/src/theme/theme_provider.dart';
import '../../profile/application/user_provider.dart';
import '../../../services/notification_service.dart';
import '../../../services/data_export_service.dart';
import '../../../services/local_db_service.dart';

// ── Settings providers ─────────────────────────────────────────────────────────
final _notifEnabledProvider = FutureProvider<bool>((ref) async =>
    NotificationService.instance.getNotificationsEnabled());
final _morningMotivationProvider = FutureProvider<bool>((ref) async =>
    NotificationService.instance.getMorningMotivationEnabled());
final _habitReminderProvider = FutureProvider<bool>((ref) async =>
    NotificationService.instance.getHabitReminderEnabled());
final _waterReminderProvider = FutureProvider<bool>((ref) async =>
    NotificationService.instance.getWaterReminderEnabled());
final _weeklyReportProvider = FutureProvider<bool>((ref) async =>
    NotificationService.instance.getWeeklyReportEnabled());

final _aiProviderPref = FutureProvider<String>((ref) async {
  final p = await SharedPreferences.getInstance();
  return p.getString('ai_provider') ?? 'cloud';
});

final _hapticEnabledProvider = FutureProvider<bool>((ref) async {
  final p = await SharedPreferences.getInstance();
  return p.getBool('haptic_enabled') ?? true;
});

final _contextMemoryProvider = FutureProvider<bool>((ref) async {
  final p = await SharedPreferences.getInstance();
  return p.getBool('context_memory_enabled') ?? true;
});

final _streamingResponsesProvider = FutureProvider<bool>((ref) async {
  final p = await SharedPreferences.getInstance();
  return p.getBool('streaming_responses_enabled') ?? true;
});

final _biometricLockProvider = FutureProvider<bool>((ref) async {
  final p = await SharedPreferences.getInstance();
  return p.getBool('biometric_lock_enabled') ?? false;
});

final _analyticsProvider = FutureProvider<bool>((ref) async {
  final p = await SharedPreferences.getInstance();
  return p.getBool('analytics_enabled') ?? true;
});

final _exportLoadingProvider = StateProvider((_) => false);

// ── Convenience helpers ────────────────────────────────────────────────────────
Future<void> _setPref(String key, bool value) async {
  final p = await SharedPreferences.getInstance();
  await p.setBool(key, value);
}

void _haptic(WidgetRef ref) {
  // Read synchronously from already-loaded cache; default true
  final enabled = ref.read(_hapticEnabledProvider).valueOrNull ?? true;
  if (enabled) HapticFeedback.selectionClick();
}

// ── Screen ─────────────────────────────────────────────────────────────────────
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepObsidian : AppColors.cloudGray,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _SettingsAppBar(isDark: isDark),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 12),
                _AppearanceSection(isDark: isDark)
                    .animate().fadeIn(delay: 40.ms)
                    .slideY(begin: 0.05, duration: 360.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _AIModelSection(isDark: isDark)
                    .animate().fadeIn(delay: 90.ms)
                    .slideY(begin: 0.05, duration: 360.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _NotificationsSection(isDark: isDark)
                    .animate().fadeIn(delay: 140.ms)
                    .slideY(begin: 0.05, duration: 360.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _HealthDataSection(isDark: isDark)
                    .animate().fadeIn(delay: 190.ms)
                    .slideY(begin: 0.05, duration: 360.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _UnitsSection(isDark: isDark)
                    .animate().fadeIn(delay: 240.ms)
                    .slideY(begin: 0.05, duration: 360.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _PrivacySection(isDark: isDark)
                    .animate().fadeIn(delay: 290.ms)
                    .slideY(begin: 0.05, duration: 360.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _AboutSection(isDark: isDark)
                    .animate().fadeIn(delay: 340.ms)
                    .slideY(begin: 0.05, duration: 360.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                _AccountSection(isDark: isDark)
                    .animate().fadeIn(delay: 390.ms)
                    .slideY(begin: 0.05, duration: 360.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App Bar ────────────────────────────────────────────────────────────────────
class _SettingsAppBar extends ConsumerWidget {
  final bool isDark;
  const _SettingsAppBar({required this.isDark});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: isDark ? AppColors.deepObsidian : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: _NavBtn(icon: PhosphorIconsRegular.arrowLeft, isDark: isDark),
        onPressed: () { HapticFeedback.lightImpact(); context.pop(); },
      ),
      title: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.softIndigo, AppColors.dynamicMint]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(PhosphorIconsFill.gear, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Text('Settings', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary)),
      ]),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  const _NavBtn({required this.icon, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(isDark ? 0.08 : 0.85),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(isDark ? 0.1 : 0.3)),
    ),
    child: Icon(icon,
        color: isDark ? Colors.white70 : AppColors.lightTextPrimary, size: 17),
  );
}

// ── Appearance ─────────────────────────────────────────────────────────────────
class _AppearanceSection extends ConsumerWidget {
  final bool isDark;
  const _AppearanceSection({required this.isDark});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final haptic = ref.watch(_hapticEnabledProvider).valueOrNull ?? true;

    return _SCard(isDark: isDark, children: [
      _SHeader(label: 'Appearance', icon: PhosphorIconsFill.palette,
          color: const Color(0xFF9B59B6)),
      const SizedBox(height: 16),
      _RowLabel(label: 'Theme', isDark: isDark),
      const SizedBox(height: 8),
      _SegmentedRow(
        items: const ['Light', 'Dark', 'System'],
        icons: [PhosphorIconsFill.sun, PhosphorIconsFill.moon, PhosphorIconsFill.deviceMobile],
        selected: themeMode == ThemeMode.light ? 0 : themeMode == ThemeMode.dark ? 1 : 2,
        onSelected: (i) {
          _haptic(ref);
          final modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
          ref.read(themeProvider.notifier).setTheme(modes[i]);
        },
        isDark: isDark,
      ),
      const SizedBox(height: 16),
      _ToggleTile(
        icon: PhosphorIconsFill.vibrate,
        color: const Color(0xFF9B59B6),
        label: 'Haptic Feedback',
        subtitle: 'Vibration on interactions',
        value: haptic,
        onChanged: (v) async {
          if (v) HapticFeedback.mediumImpact();
          await _setPref('haptic_enabled', v);
          ref.invalidate(_hapticEnabledProvider);
        },
      ),
    ]);
  }
}

// ── AI Model ───────────────────────────────────────────────────────────────────
class _AIModelSection extends ConsumerWidget {
  final bool isDark;
  const _AIModelSection({required this.isDark});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(_aiProviderPref).valueOrNull ?? 'cloud';
    final contextMemory = ref.watch(_contextMemoryProvider).valueOrNull ?? true;
    final streaming = ref.watch(_streamingResponsesProvider).valueOrNull ?? true;

    return _SCard(isDark: isDark, children: [
      _SHeader(label: 'AI Model', icon: PhosphorIconsFill.brain,
          color: AppColors.softIndigo),
      const SizedBox(height: 16),
      _RowLabel(label: 'AI Provider', isDark: isDark),
      const SizedBox(height: 8),
      _SegmentedRow(
        items: const ['On-Device', 'Cloud'],
        icons: [PhosphorIconsFill.deviceMobileCamera, PhosphorIconsFill.cloud],
        selected: provider == 'on_device' ? 0 : 1,
        onSelected: (i) async {
          _haptic(ref);
          final p = await SharedPreferences.getInstance();
          await p.setString('ai_provider', i == 0 ? 'on_device' : 'cloud');
          ref.invalidate(_aiProviderPref);
        },
        isDark: isDark,
        activeColor: AppColors.softIndigo,
      ),
      const SizedBox(height: 16),
      if (provider == 'cloud') ...[
        _InfoTile(
          icon: PhosphorIconsFill.sparkle,
          color: AppColors.softIndigo,
          label: 'Cloud Model',
          value: 'gemini-2.0-flash',
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _InfoTile(
          icon: PhosphorIconsFill.key,
          color: AppColors.dynamicMint,
          label: 'API Status',
          value: 'Connected',
          valueColor: AppColors.dynamicMint,
          isDark: isDark,
        ),
      ] else ...[
        _InfoTile(
          icon: PhosphorIconsFill.hardDrive,
          color: AppColors.warning,
          label: 'On-Device Model',
          value: 'Gemma (Local)',
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _InfoTile(
          icon: PhosphorIconsFill.wifiNone,
          color: AppColors.dynamicMint,
          label: 'Works Offline',
          value: 'Yes',
          valueColor: AppColors.dynamicMint,
          isDark: isDark,
        ),
      ],
      _SDivider(),
      _ToggleTile(
        icon: PhosphorIconsFill.brain,
        color: AppColors.softIndigo,
        label: 'Context Memory',
        subtitle: 'AI remembers your health profile',
        value: contextMemory,
        onChanged: (v) async {
          _haptic(ref);
          await _setPref('context_memory_enabled', v);
          ref.invalidate(_contextMemoryProvider);
        },
      ),
      _SDivider(),
      _ToggleTile(
        icon: PhosphorIconsFill.arrowsClockwise,
        color: AppColors.dynamicMint,
        label: 'Streaming Responses',
        subtitle: 'See AI reply word-by-word',
        value: streaming,
        onChanged: (v) async {
          _haptic(ref);
          await _setPref('streaming_responses_enabled', v);
          ref.invalidate(_streamingResponsesProvider);
        },
      ),
    ]);
  }
}

// ── Notifications ──────────────────────────────────────────────────────────────
class _NotificationsSection extends ConsumerWidget {
  final bool isDark;
  const _NotificationsSection({required this.isDark});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notif = ref.watch(_notifEnabledProvider).valueOrNull ?? true;
    final morning = ref.watch(_morningMotivationProvider).valueOrNull ?? true;
    final habit = ref.watch(_habitReminderProvider).valueOrNull ?? true;
    final water = ref.watch(_waterReminderProvider).valueOrNull ?? false;
    final weekly = ref.watch(_weeklyReportProvider).valueOrNull ?? true;

    return _SCard(isDark: isDark, children: [
      _SHeader(label: 'Notifications', icon: PhosphorIconsFill.bell,
          color: AppColors.softIndigo),
      const SizedBox(height: 8),
      _ToggleTile(
        icon: PhosphorIconsFill.bell,
        color: AppColors.softIndigo,
        label: 'Push Notifications',
        subtitle: 'Master toggle for all notifications',
        value: notif,
        onChanged: (v) {
          _haptic(ref);
          NotificationService.instance.setNotificationsEnabled(v)
              .then((_) => ref.invalidate(_notifEnabledProvider));
        },
      ),
      _SDivider(),
      _ToggleTile(
        icon: PhosphorIconsFill.sun,
        color: AppColors.warning,
        label: 'Morning Motivation',
        subtitle: 'Daily at 8:00 AM',
        value: notif && morning,
        onChanged: notif ? (v) {
          _haptic(ref);
          NotificationService.instance.setMorningMotivationEnabled(v)
              .then((_) => ref.invalidate(_morningMotivationProvider));
        } : null,
      ),
      _SDivider(),
      _ToggleTile(
        icon: PhosphorIconsFill.clockCountdown,
        color: Colors.orange,
        label: 'Habit Reminders',
        subtitle: 'Every evening at 8:00 PM',
        value: notif && habit,
        onChanged: notif ? (v) {
          _haptic(ref);
          NotificationService.instance.setHabitReminderEnabled(v)
              .then((_) => ref.invalidate(_habitReminderProvider));
        } : null,
      ),
      _SDivider(),
      _ToggleTile(
        icon: PhosphorIconsFill.drop,
        color: const Color(0xFF41C9E2),
        label: 'Water Reminders',
        subtitle: 'Every 2h between 9 AM – 7 PM',
        value: notif && water,
        onChanged: notif ? (v) {
          _haptic(ref);
          NotificationService.instance.setWaterReminderEnabled(v)
              .then((_) => ref.invalidate(_waterReminderProvider));
        } : null,
      ),
      _SDivider(),
      _ToggleTile(
        icon: PhosphorIconsFill.chartBar,
        color: AppColors.dynamicMint,
        label: 'Weekly Report',
        subtitle: 'Sunday mornings at 9:00 AM',
        value: notif && weekly,
        onChanged: notif ? (v) {
          _haptic(ref);
          NotificationService.instance.setWeeklyReportEnabled(v)
              .then((_) => ref.invalidate(_weeklyReportProvider));
        } : null,
      ),
      _SDivider(),
      _ActionTile(
        icon: PhosphorIconsFill.testTube,
        color: Colors.grey,
        label: 'Test Notification',
        subtitle: 'Send a test notification now',
        onTap: () async {
          _haptic(ref);
          await NotificationService.instance.showTestNotification();
        },
      ),
    ]);
  }
}

// ── Health & Data ──────────────────────────────────────────────────────────────
class _HealthDataSection extends ConsumerWidget {
  final bool isDark;
  const _HealthDataSection({required this.isDark});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExporting = ref.watch(_exportLoadingProvider);

    return _SCard(isDark: isDark, children: [
      _SHeader(label: 'Health & Data', icon: PhosphorIconsFill.heartbeat,
          color: AppColors.danger),
      const SizedBox(height: 8),
      _ToggleTile(
        icon: PhosphorIconsFill.heartbeat,
        color: AppColors.dynamicMint,
        label: 'Health App Sync',
        subtitle: 'Apple Health / Google Fit',
        value: true,
        onChanged: (_) { _haptic(ref); },
      ),
      _SDivider(),
      _ActionTile(
        icon: isExporting ? PhosphorIconsFill.hourglass : PhosphorIconsFill.export,
        color: Colors.blueGrey,
        label: 'Export Health Data',
        subtitle: isExporting ? 'Preparing CSV files…' : 'Share as CSV (last 30 days)',
        onTap: isExporting ? () {} : () async {
          _haptic(ref);
          ref.read(_exportLoadingProvider.notifier).state = true;
          try {
            final isar = ref.read(isarProvider);
            await DataExportService.exportAndShare(isar);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Export failed: $e'),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
            }
          } finally {
            ref.read(_exportLoadingProvider.notifier).state = false;
          }
        },
      ),
      _SDivider(),
      _ActionTile(
        icon: PhosphorIconsFill.trash,
        color: AppColors.danger,
        label: 'Clear Cached AI Data',
        subtitle: 'Remove stored AI summaries & context',
        onTap: () => _confirmClearAI(context, ref),
      ),
    ]);
  }

  void _confirmClearAI(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Clear AI Cache?',
        body: 'This will remove all cached AI summaries and context. The AI will start fresh.',
        confirmLabel: 'Clear',
        confirmColor: AppColors.danger,
        onConfirm: () async {
          await ref.read(userProvider.notifier).cacheWeeklySummary('');
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }
}

// ── Units ──────────────────────────────────────────────────────────────────────
class _UnitsSection extends ConsumerWidget {
  final bool isDark;
  const _UnitsSection({required this.isDark});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isMetric = user.preferences.unitSystem == 'metric';

    return _SCard(isDark: isDark, children: [
      _SHeader(label: 'Units & Locale', icon: PhosphorIconsFill.ruler,
          color: AppColors.warning),
      const SizedBox(height: 16),
      _RowLabel(label: 'Unit System', isDark: isDark),
      const SizedBox(height: 8),
      _SegmentedRow(
        items: const ['Metric', 'Imperial'],
        icons: [PhosphorIconsFill.thermometerSimple, PhosphorIconsFill.flag],
        selected: isMetric ? 0 : 1,
        onSelected: (i) async {
          _haptic(ref);
          final unit = i == 0 ? 'metric' : 'imperial';
          await ref.read(userProvider.notifier).updateUnitSystem(unit);
        },
        isDark: isDark,
        activeColor: AppColors.warning,
      ),
    ]);
  }
}

// ── Privacy & Security ─────────────────────────────────────────────────────────
class _PrivacySection extends ConsumerWidget {
  final bool isDark;
  const _PrivacySection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometric = ref.watch(_biometricLockProvider).valueOrNull ?? false;
    final analytics = ref.watch(_analyticsProvider).valueOrNull ?? true;

    return _SCard(isDark: isDark, children: [
      _SHeader(label: 'Privacy & Security', icon: PhosphorIconsFill.shieldCheck,
          color: AppColors.dynamicMint),
      const SizedBox(height: 8),
      _ToggleTile(
        icon: PhosphorIconsFill.fingerprint,
        color: AppColors.dynamicMint,
        label: 'Biometric Lock',
        subtitle: 'Use Face ID / fingerprint to open app',
        value: biometric,
        onChanged: (v) => _toggleBiometric(context, ref, v),
      ),
      _SDivider(),
      _ToggleTile(
        icon: PhosphorIconsFill.chartPieSlice,
        color: Colors.blueGrey,
        label: 'Analytics',
        subtitle: 'Help improve the app anonymously',
        value: analytics,
        onChanged: (v) async {
          _haptic(ref);
          await _setPref('analytics_enabled', v);
          ref.invalidate(_analyticsProvider);
        },
      ),
      _SDivider(),
      _ActionTile(
        icon: PhosphorIconsFill.newspaper,
        color: Colors.grey,
        label: 'Privacy Policy',
        subtitle: 'How your data is used',
        onTap: () {
          _haptic(ref);
          _launchUrl('https://healthai.app/privacy');
        },
      ),
      _SDivider(),
      _ActionTile(
        icon: PhosphorIconsFill.fileText,
        color: Colors.grey,
        label: 'Terms of Service',
        subtitle: 'User agreement',
        onTap: () {
          _haptic(ref);
          _launchUrl('https://healthai.app/terms');
        },
      ),
    ]);
  }

  Future<void> _toggleBiometric(
      BuildContext context, WidgetRef ref, bool enable) async {
    _haptic(ref);
    if (enable) {
      final auth = LocalAuthentication();
      final canCheck = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      if (!canCheck || !isDeviceSupported) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Biometric authentication not available on this device'),
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }
      final authenticated = await auth.authenticate(
        localizedReason: 'Confirm biometrics to enable lock',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (!authenticated) return;
    }
    await _setPref('biometric_lock_enabled', enable);
    ref.invalidate(_biometricLockProvider);
  }
}

// ── About ──────────────────────────────────────────────────────────────────────
class _AboutSection extends ConsumerWidget {
  final bool isDark;
  const _AboutSection({required this.isDark});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SCard(isDark: isDark, children: [
      _SHeader(label: 'About', icon: PhosphorIconsFill.info,
          color: Colors.blueGrey),
      const SizedBox(height: 8),
      _InfoTile(
        icon: PhosphorIconsFill.package,
        color: AppColors.softIndigo,
        label: 'Version',
        value: '1.0.0 (Build 42)',
        isDark: isDark,
      ),
      _SDivider(),
      _ActionTile(
        icon: PhosphorIconsFill.star,
        color: AppColors.warning,
        label: 'Rate the App',
        subtitle: 'Enjoying HealthAI? Leave a review',
        onTap: () => _rateApp(context, ref),
      ),
      _SDivider(),
      _ActionTile(
        icon: PhosphorIconsFill.envelope,
        color: AppColors.dynamicMint,
        label: 'Send Feedback',
        subtitle: 'Report bugs or suggest features',
        onTap: () {
          _haptic(ref);
          _launchUrl('mailto:feedback@healthai.app?subject=HealthAI%20Feedback');
        },
      ),
      _SDivider(),
      _ActionTile(
        icon: PhosphorIconsFill.code,
        color: Colors.grey,
        label: 'Open Source Licenses',
        subtitle: 'Third-party packages used',
        onTap: () {
          _haptic(ref);
          showLicensePage(context: context, applicationName: 'HealthAI',
              applicationVersion: '1.0.0');
        },
      ),
    ]);
  }

  Future<void> _rateApp(BuildContext context, WidgetRef ref) async {
    _haptic(ref);
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    } else {
      await review.openStoreListing(appStoreId: 'YOUR_APP_STORE_ID');
    }
  }
}

// ── Account / Danger ───────────────────────────────────────────────────────────
class _AccountSection extends ConsumerWidget {
  final bool isDark;
  const _AccountSection({required this.isDark});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SCard(isDark: isDark, children: [
      _SHeader(label: 'Account', icon: PhosphorIconsFill.user,
          color: AppColors.warning),
      const SizedBox(height: 8),
      _ActionTile(
        icon: PhosphorIconsFill.signOut,
        color: AppColors.warning,
        label: 'Sign Out',
        subtitle: 'You can sign back in anytime',
        onTap: () => _confirmSignOut(context, ref),
      ),
      _SDivider(),
      _ActionTile(
        icon: PhosphorIconsFill.trash,
        color: AppColors.danger,
        label: 'Delete Account',
        subtitle: 'Permanently delete all data',
        onTap: () => _confirmDelete(context, ref),
      ),
    ]);
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Sign Out?',
        body: 'You will be taken back to the setup screen. Your data will be kept.',
        confirmLabel: 'Sign Out',
        confirmColor: AppColors.warning,
        onConfirm: () async {
          await ref.read(userProvider.notifier).signOut();
          if (context.mounted) context.go('/onboarding');
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete Account?',
        body: 'This action is permanent and cannot be undone. All your health data will be lost forever.',
        confirmLabel: 'Delete Forever',
        confirmColor: AppColors.danger,
        onConfirm: () async {
          await ref.read(userProvider.notifier).deleteAccount();
          if (context.mounted) context.go('/onboarding');
        },
      ),
    );
  }
}

// ── URL helper ─────────────────────────────────────────────────────────────────
Future<void> _launchUrl(String urlString) async {
  final uri = Uri.parse(urlString);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ── Shared Primitives ──────────────────────────────────────────────────────────
class _SCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _SCard({required this.isDark, required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalGlass : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0 : 0.04),
              blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _SHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SHeader({required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75))),
      ]),
    );
  }
}

class _SDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
    height: 0, indent: 56, thickness: 0.5,
    color: Theme.of(context).dividerColor.withOpacity(0.06),
  );
}

class _RowLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _RowLabel({required this.label, required this.isDark});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(label, style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
  );
}

class _SegmentedRow extends StatelessWidget {
  final List<String> items;
  final List<IconData> icons;
  final int selected;
  final ValueChanged<int> onSelected;
  final bool isDark;
  final Color? activeColor;
  const _SegmentedRow({
    required this.items, required this.icons,
    required this.selected, required this.onSelected,
    required this.isDark, this.activeColor,
  });
  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.softIndigo;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : AppColors.cloudGray,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: items.asMap().entries.map((e) {
          final isSelected = e.key == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); onSelected(e.key); },
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? active : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected ? [
                    BoxShadow(color: active.withOpacity(0.3), blurRadius: 8)
                  ] : null,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icons[e.key],
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      size: 13),
                  const SizedBox(width: 5),
                  Text(e.value, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ]),
              ),
            ),
          );
        }).toList()),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _ToggleTile({
    required this.icon, required this.color,
    required this.label, required this.subtitle,
    required this.value, this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(subtitle, style: TextStyle(fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45))),
          ])),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ]),
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label, subtitle;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon, required this.color,
    required this.label, required this.subtitle, required this.onTap,
  });
  @override
  State<_ActionTile> createState() => _ActionTileState();
}
class _ActionTileState extends State<_ActionTile> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.6 : 1.0, duration: 100.ms,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(widget.icon, color: widget.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: widget.color == AppColors.danger ? widget.color : null)),
              Text(widget.subtitle, style: TextStyle(fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45))),
            ])),
            Icon(PhosphorIconsRegular.caretRight, size: 15,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25)),
          ]),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  final Color? valueColor;
  final bool isDark;
  const _InfoTile({
    required this.icon, required this.color,
    required this.label, required this.value,
    this.valueColor, required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
        Text(value, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: valueColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
      ]),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title, body, confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;
  const _ConfirmDialog({
    required this.title, required this.body,
    required this.confirmLabel, required this.confirmColor,
    required this.onConfirm,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(body, style: const TextStyle(height: 1.5)),
      actions: [
        TextButton(
          onPressed: () { HapticFeedback.lightImpact(); Navigator.pop(context); },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
