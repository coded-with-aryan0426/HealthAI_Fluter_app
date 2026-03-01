import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/shell/presentation/app_shell.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/habits/presentation/habits_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/diet_scanner/presentation/scanner_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/workout/presentation/workout_player_screen.dart';
import '../features/workout/presentation/workout_plan_preview_screen.dart';
import '../features/workout/presentation/workout_library_screen.dart';
import '../features/workout/presentation/workout_programs_screen.dart';
import '../features/workout/presentation/strength_charts_screen.dart';
import '../features/workout/domain/workout_plan_model.dart';
import '../database/models/workout_plan_doc.dart';
import '../database/models/workout_program_doc.dart';
import '../features/nutrition/presentation/nutrition_screen.dart';
import '../features/workout/presentation/workout_summary_screen.dart';
import '../features/dashboard/presentation/weekly_overview_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/fasting/presentation/fasting_screen.dart';
import '../features/body_composition/presentation/body_composition_screen.dart';
import '../features/supplements/presentation/supplement_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final shellNavigatorHabitsKey = GlobalKey<NavigatorState>(debugLabel: 'habits');
final shellNavigatorNutritionKey = GlobalKey<NavigatorState>(debugLabel: 'nutrition');
final shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

GoRouter buildAppRouter({bool showOnboarding = false}) => GoRouter(
  initialLocation: '/splash',
  navigatorKey: rootNavigatorKey,
  routes: _buildRoutes(showOnboarding),
);


List<RouteBase> _buildRoutes(bool showOnboarding) => [
  // ── Splash ────────────────────────────────────────────────────────────────
  GoRoute(
    path: '/splash',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => NoTransitionPage(
      child: SplashScreen(showOnboarding: showOnboarding),
    ),
  ),

  // ── Onboarding (full-screen, no nav bar) ─────────────────────────────────
  GoRoute(
    path: '/onboarding',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => const MaterialPage(
      fullscreenDialog: true,
      child: OnboardingScreen(),
    ),
  ),

  // ── Shell with bottom nav ────────────────────────────────────────────────
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        AppShell(navigationShell: navigationShell),
    branches: [
      // index 0 – Home
      StatefulShellBranch(
        navigatorKey: shellNavigatorHomeKey,
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
        ],
      ),
      // index 1 – Habits
      StatefulShellBranch(
        navigatorKey: shellNavigatorHabitsKey,
        routes: [
          GoRoute(
            path: '/habits',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HabitsScreen()),
          ),
        ],
      ),
      // index 2 – Nutrition
      StatefulShellBranch(
        navigatorKey: shellNavigatorNutritionKey,
        routes: [
          GoRoute(
            path: '/nutrition',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: NutritionScreen()),
          ),
        ],
      ),
      // index 3 – Profile
      StatefulShellBranch(
        navigatorKey: shellNavigatorProfileKey,
        routes: [
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  ),

  // ── Full-screen pages ────────────────────────────────────────────────────
  GoRoute(
    path: '/chat',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => const MaterialPage(child: ChatScreen()),
  ),
  GoRoute(
    path: '/scanner',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => const MaterialPage(
      fullscreenDialog: true,
      child: ScannerScreen(),
    ),
  ),
  GoRoute(
    path: '/workout/library',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) =>
        const MaterialPage(child: WorkoutLibraryScreen()),
  ),
  GoRoute(
    path: '/workout/preview',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) {
      final extra = state.extra;
      return MaterialPage(
        fullscreenDialog: true,
        child: WorkoutPlanPreviewScreen(
          planData: extra is WorkoutPlanData ? extra : null,
          planDoc: extra is WorkoutPlanDoc ? extra : null,
        ),
      );
    },
  ),
  GoRoute(
    path: '/workout',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) {
      final extra = state.extra;
      return MaterialPage(
        fullscreenDialog: true,
        child: WorkoutPlayerScreen(
          planDoc: extra is WorkoutPlanDoc ? extra : null,
        ),
      );
    },
  ),
  GoRoute(
    path: '/workout/summary',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) {
      final data = state.extra as WorkoutSummaryData;
      return MaterialPage(
        fullscreenDialog: true,
        child: WorkoutSummaryScreen(data: data),
      );
    },
  ),
  GoRoute(
    path: '/workout/progress',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) =>
        const MaterialPage(child: StrengthChartsScreen()),
  ),
  GoRoute(
    path: '/workout/programs',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) =>
        const MaterialPage(child: WorkoutProgramsScreen()),
  ),
  GoRoute(
    path: '/workout/program-detail',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) {
      final program = state.extra as WorkoutProgramDoc;
      return MaterialPage(
        child: WorkoutProgramDetailScreen(program: program),
      );
    },
  ),
  GoRoute(
    path: '/weekly',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) =>
        const MaterialPage(child: WeeklyOverviewScreen()),
  ),
  GoRoute(
    path: '/settings',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) =>
        const MaterialPage(child: SettingsScreen()),
  ),
  GoRoute(
    path: '/fasting',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) =>
        const MaterialPage(child: FastingScreen()),
  ),
  GoRoute(
    path: '/body',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) =>
        const MaterialPage(child: BodyCompositionScreen()),
  ),
  GoRoute(
    path: '/supplements',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) =>
        const MaterialPage(child: SupplementScreen()),
  ),
];
