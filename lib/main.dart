import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemma/core/api/flutter_gemma.dart';
import 'package:go_router/go_router.dart';
import 'src/routing/app_router.dart';
import 'src/theme/app_theme.dart';
import 'src/theme/theme_provider.dart';
import 'src/services/local_db_service.dart';
import 'src/services/notification_service.dart';
import 'package:isar/isar.dart';
import 'src/database/models/user_doc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final isar = await LocalDBService.init();

  // Initialise notifications — defer permission + scheduling so they never
  // block startup or race with other permission requests.
  await NotificationService.instance.init();
  Future.delayed(const Duration(seconds: 2), () async {
    try {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.scheduleAllDefaults();
    } catch (_) {}
  });

  await FlutterGemma.initialize();

  for (final oldFile in [
    'gemma3-270m-it-q8.task',
    'gemma3n-e2b-it-int4.task',
  ]) {
    try {
      await FlutterGemma.uninstallModel(oldFile);
    } catch (_) {}
  }

    // Detect first launch: no UserDoc = show onboarding.
    // Guard against stale/corrupt DB causing a RangeError during deserialization.
    UserDoc? existingUser;
    try {
      existingUser = isar.userDocs.where().idGreaterThan(0).findFirstSync();
    } catch (_) {
      // Corrupt data — close, wipe, and reopen a clean DB.
      await isar.close(deleteFromDisk: true);
      final freshIsar = await LocalDBService.init();
      existingUser = null;
      runApp(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(freshIsar)],
          child: const HealthAIApp(showOnboarding: true),
        ),
      );
      return;
    }
    final showOnboarding = existingUser == null || (existingUser.displayName ?? '').isEmpty;

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: HealthAIApp(showOnboarding: showOnboarding),
    ),
  );
}

class HealthAIApp extends ConsumerStatefulWidget {
  final bool showOnboarding;
  const HealthAIApp({super.key, required this.showOnboarding});

  @override
  ConsumerState<HealthAIApp> createState() => _HealthAIAppState();
}

class _HealthAIAppState extends ConsumerState<HealthAIApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter(showOnboarding: widget.showOnboarding);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'HealthAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
