import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../features/shell/presentation/app_shell.dart';
import '../features/habits/presentation/habits_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/diet_scanner/presentation/scanner_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/workout/presentation/workout_player_screen.dart';
import '../features/workout/presentation/workout_plan_preview_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/workout/presentation/workout_library_screen.dart';
import '../features/workout/presentation/workout_programs_screen.dart';
import '../features/workout/presentation/strength_charts_screen.dart';
import '../features/workout/domain/workout_plan_model.dart';
import '../database/models/workout_plan_doc.dart';
import '../database/models/workout_program_doc.dart';
import '../features/nutrition/presentation/nutrition_screen.dart';
import '../features/nutrition/presentation/meal_planner_screen.dart';
import '../features/nutrition/presentation/weekly_report_screen.dart';
import '../features/nutrition/presentation/food_search_screen.dart';
import '../features/workout/presentation/workout_summary_screen.dart';
import '../features/dashboard/presentation/weekly_overview_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/fasting/presentation/fasting_screen.dart';
import '../features/body_composition/presentation/body_composition_screen.dart';
import '../features/supplements/presentation/supplement_screen.dart';
import '../features/splash/presentation/splash_screen.dart';

// ── Smooth page transitions ───────────────────────────────────────────────────

/// Fade + subtle slide-up — used for overlay/modal-style routes.
CustomTransitionPage<T> _slidePage<T>(Widget child, GoRouterState state) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppDurations.page,
      reverseTransitionDuration: AppDurations.page,
      transitionsBuilder: (ctx, anim, secondAnim, c) {
        final tween = Tween(
          begin: const Offset(0.0, 0.06),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: SlideTransition(position: anim.drive(tween), child: c),
        );
      },
    );

/// Fade + slide-in from right — used for drill-down routes.
CustomTransitionPage<T> _slideRightPage<T>(Widget child, GoRouterState state) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppDurations.page,
      reverseTransitionDuration: AppDurations.page,
      transitionsBuilder: (ctx, anim, secondAnim, c) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: SlideTransition(position: anim.drive(tween), child: c),
        );
      },
    );

// ── Navigator keys ────────────────────────────────────────────────────────────

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final shellNavigatorWorkoutKey = GlobalKey<NavigatorState>(debugLabel: 'workout');
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
    pageBuilder: (context, state) => _slidePage(
      const OnboardingScreen(), state),
  ),

  // ── Shell with bottom nav ────────────────────────────────────────────────
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        AppShell(navigationShell: navigationShell),
    branches: [
      // index 0 – Dashboard (home)
      StatefulShellBranch(
        navigatorKey: shellNavigatorDashboardKey,
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
        ],
      ),
      // index 1 – Workout
      StatefulShellBranch(
        navigatorKey: shellNavigatorWorkoutKey,
        routes: [
          GoRoute(
            path: '/workout-tab',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WorkoutLibraryScreen()),
          ),
        ],
      ),
      // index 2 – Habits
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
      // index 3 – Nutrition
        StatefulShellBranch(
          navigatorKey: shellNavigatorNutritionKey,
          routes: [
            GoRoute(
              path: '/nutrition-tab',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: NutritionScreen()),
            ),
          ],
        ),
    ],
  ),

  // ── Full-screen pages ────────────────────────────────────────────────────
  GoRoute(
    path: '/chat',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slidePage(
      _SafePopScope(child: const ChatScreen()), state),
  ),
  GoRoute(
    path: '/scanner',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slidePage(
      _SafePopScope(child: const ScannerScreen()), state),
  ),
  GoRoute(
    path: '/workout/library',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const WorkoutLibraryScreen()), state),
  ),
  GoRoute(
    path: '/workout/preview',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) {
      final extra = state.extra;
      return _slideRightPage(
        _SafePopScope(
          child: WorkoutPlanPreviewScreen(
            planData: extra is WorkoutPlanData ? extra : null,
            planDoc: extra is WorkoutPlanDoc ? extra : null,
          ),
        ), state);
    },
  ),
  GoRoute(
    path: '/workout',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) {
      final extra = state.extra;
      return _slidePage(
        _SafePopScope(
          child: WorkoutPlayerScreen(
            planDoc: extra is WorkoutPlanDoc ? extra : null,
          ),
        ), state);
    },
  ),
  GoRoute(
    path: '/workout/summary',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) {
      final data = state.extra as WorkoutSummaryData;
      return _slidePage(
        _SafePopScope(child: WorkoutSummaryScreen(data: data)), state);
    },
  ),
  GoRoute(
    path: '/workout/progress',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const StrengthChartsScreen()), state),
  ),
  GoRoute(
    path: '/workout/programs',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const WorkoutProgramsScreen()), state),
  ),
  GoRoute(
    path: '/workout/program-detail',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) {
      final program = state.extra as WorkoutProgramDoc;
      return _slideRightPage(
        _SafePopScope(child: WorkoutProgramDetailScreen(program: program)), state);
    },
  ),
  GoRoute(
    path: '/weekly',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slidePage(
      _SafePopScope(child: const WeeklyOverviewScreen()), state),
  ),
  GoRoute(
    path: '/settings',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const SettingsScreen()), state),
  ),
  GoRoute(
    path: '/nutrition',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const NutritionScreen()), state),
  ),
  GoRoute(
    path: '/profile',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const ProfileScreen()), state),
  ),
  GoRoute(
    path: '/fasting',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const FastingScreen()), state),
  ),
  GoRoute(
    path: '/body',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const BodyCompositionScreen()), state),
  ),
  GoRoute(
    path: '/meal-planner',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const MealPlannerScreen()), state),
  ),
  GoRoute(
    path: '/nutrition/weekly-report',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const WeeklyNutritionReportScreen()), state),
  ),
  GoRoute(
    path: '/nutrition/food-search',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const FoodSearchScreen()), state),
  ),
  GoRoute(
    path: '/supplements',
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _slideRightPage(
      _SafePopScope(child: const SupplementScreen()), state),
  ),
];

/// Wraps a full-screen route so that the hardware/gesture back button
/// pops the route if possible, otherwise goes home — never exits the app.
class _SafePopScope extends StatelessWidget {
  const _SafePopScope({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
      },
      child: child,
    );
  }
}
