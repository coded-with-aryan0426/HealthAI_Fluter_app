
# HealthAI — Master Improvement & Implementation Plan
> Last Updated: 2026-03-01
> Purpose: Every fix, improvement, and new feature — with wireframes, UI/UX specs, and micro-implementation details.
> Scope: Covers ALL fake, hardcoded, non-functional, and dummy-only UI elements found in the codebase.

---

## Completed Work Log

| # | Task | Files Changed | Status |
|---|------|--------------|--------|
| 1 | Remove dead static `appRouter` instance | `app_router.dart` | ✅ Done |
| 2 | Profile 7-day bar chart — real `DailyLogDoc` data via `weeklyStatsProvider` | `profile_screen.dart` | ✅ Done |
| 3 | Profile heatmap — real active days from current month `DailyLogDoc` | `profile_screen.dart` | ✅ Done |
| 4 | Profile streak — real current/best streak calculated from `DailyLogDoc` | `profile_screen.dart` | ✅ Done |
| 5 | Achievements — removed fake `early_bird`/`scan_master` forced badges | `profile_screen.dart` | ✅ Done |
| 6 | Settings unit system — added `updateUnitSystem()` to `UserNotifier`, wired segmented control | `user_provider.dart`, `settings_screen.dart` | ✅ Done |
| 7 | Settings theme selector — fixed `.state =` external access violation via `setTheme()` method | `theme_provider.dart`, `settings_screen.dart` | ✅ Done |
| 8 | Section 2.7: `WorkoutSummaryScreen` — "View My Progress" button → `/workout/progress` | `workout_summary_screen.dart` | ✅ Done |
| 9 | Section 4.2: Sleep bento card — `onTap` wired → `_SleepLogSheet` (bedtime/wake picker, quality selector, live duration preview, saves via `updateSleep()`) | `dashboard_screen.dart` | ✅ Done |

---

## Table of Contents

1. [Critical Bugs (Fix First)](#1-critical-bugs-fix-first)
2. [Hidden Screens — Wire Navigation](#2-hidden-screens--wire-navigation)
3. [Onboarding — Unlock the Flow](#3-onboarding--unlock-the-flow)
4. [Dashboard — Real Data & Functional Buttons](#4-dashboard--real-data--functional-buttons)
5. [Profile — Fix Hardcoded Data & Complete](#5-profile--fix-hardcoded-data--complete)
6. [Habits — Real Data Wiring](#6-habits--real-data-wiring)
7. [Nutrition — Complete the Feature](#7-nutrition--complete-the-feature)
8. [Fasting Screen — Improvements](#8-fasting-screen--improvements)
9. [Body Composition — Improvements](#9-body-composition--improvements)
10. [Supplements — Improvements](#10-supplements--improvements)
11. [Workout Library & Programs](#11-workout-library--programs)
12. [Strength Progress Charts](#12-strength-progress-charts)
13. [Weekly Overview Screen](#13-weekly-overview-screen)
14. [AI Chat — Functional Buttons & Improvements](#14-ai-chat--functional-buttons--improvements)
15. [Settings Screen — Wire Every Item](#15-settings-screen--wire-every-item)
16. [Global UI/UX Tokens & Consistency](#16-global-uiux-tokens--consistency)
17. [Implementation Order (Priority Queue)](#17-implementation-order-priority-queue)
18. [Complete Fake/Non-Functional UI Audit](#18-complete-fakenon-functional-ui-audit)

---

## 1. Critical Bugs (Fix First)

### 1.1 Onboarding Never Shown — ✅ FIXED (main.dart already reads Isar before building router)

**File:** `lib/src/routing/app_router.dart` line 41
**File:** `lib/src/features/splash/presentation/splash_screen.dart`

**Problem:**
```dart
// app_router.dart line 41 — hardcoded false, onboarding dead forever
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: _buildRoutes(false),  // <-- THIS LINE
);
```

**Fix Required:**
- In `main.dart` (wherever `appRouter` is created), read `UserDoc` from Isar before building the router.
- If `UserDoc.displayName == null`, pass `showOnboarding: true`.
- Use `buildAppRouter(showOnboarding: !isOnboarded)` instead of the static `appRouter`.

**Exact Logic:**
```
cold start → splash loads → reads Isar UserDoc
  if UserDoc.displayName == null → show onboarding
  else → go to /home
```

**Impact of fixing this:** User name on dashboard, personalized calorie/protein goals, fitness level in AI context — all start working automatically because the data is already wired.

---

### 1.2 Profile 7-Day Bar Chart Uses Hardcoded Data — ✅ FIXED

**File:** `lib/src/features/profile/presentation/profile_screen.dart` line 772
```dart
final values = [0.7, 0.5, 0.9, 0.6, 0.8, 0.3, 0.1]; // HARDCODED
```

**Fix:** Read last 7 `DailyLogDoc` entries from Isar. Normalize `caloriesBurned` against `calorieGoal` for bar height.

---

### 1.3 Profile Heatmap Uses Hardcoded Active Days — ✅ FIXED

**File:** `lib/src/features/profile/presentation/profile_screen.dart` line 1202
```dart
final activeSimulated = {3, 4, 5, 8, 9, 10, ...}; // HARDCODED
```

**Fix:** Query `DailyLogDoc` for current month. A day is "active" if `caloriesBurned > 0 || stepCount > 0`.

---

### 1.4 Profile Streak Uses Hardcoded Numbers — ✅ FIXED

**File:** `lib/src/features/profile/presentation/profile_screen.dart` line 1134
```dart
const currentStreak = 5;    // HARDCODED
const longestStreak = 21;   // HARDCODED
```

**Fix:** Calculate streak from `DailyLogDoc` records — count consecutive days with activity going backwards from today.

---

### 1.5 Achievements Force-Adds 2 Fake Badges — ✅ FIXED

**File:** `lib/src/features/profile/presentation/profile_screen.dart` line 975
```dart
final unlocked = [...user.unlockedAchievements, 'early_bird', 'scan_master']; // FAKE
```

**Fix:** Remove the hardcoded additions. Wire real unlock conditions (see Section 5.2).

---

### 1.6 Settings — Units Section `updateProfile()` Call Is Empty — ✅ FIXED

**File:** `lib/src/features/settings/presentation/settings_screen.dart` line 457–461
```dart
await ref.read(userProvider.notifier).updateProfile(
  // Store via preferences; unitSystem field    // EMPTY CALL — DOES NOTHING
);
```

**Fix:** Add a `updateUnitSystem(String unit)` method to `UserNotifier`. Wire the segmented control:
```dart
onSelected: (i) async {
  HapticFeedback.selectionClick();
  final unit = i == 0 ? 'metric' : 'imperial';
  await ref.read(userProvider.notifier).updateUnitSystem(unit);
},
```

---

## 2. Hidden Screens — Wire Navigation

### 2.1–2.5: Already Wired
Fasting, Body Composition, Supplements, Nutrition bento cards, Weekly Overview — all have entry points. No fix needed.

### 2.6 Workout Programs — Already Fixed ✅
`WorkoutLibraryScreen` has a "Programs" tab that navigates to `/workout/programs`. Done.

### 2.7 Strength Charts — Add Second Entry Point — ✅ FIXED
**Fix:** In `WorkoutSummaryScreen`, added "View My Progress" button → `context.push('/workout/progress')`.

---

## 3. Onboarding — Unlock the Flow

### Current State
Full 5-screen onboarding exists with real `completeOnboarding()` call. It's just never triggered (hardcoded `false` in router).

### 3.1 Fix Router Initialization

**File:** `lib/main.dart`

```
Before app launches:
  1. Open Isar
  2. Read UserDoc (id: 1)
  3. Pass showOnboarding: (user.displayName == null) to buildAppRouter()
```

Replace:
```dart
final appRouter = GoRouter(initialLocation: '/splash', routes: _buildRoutes(false));
```
With a `FutureProvider` or init sequence that checks Isar first, then creates the router.

### 3.2 Onboarding Screen UI Improvements

**Screen 3 — Body Metrics:** Add a live BMI preview pill that updates as user types height/weight.
```
┌─────────────────────────────────────────┐
│  Height (cm)  [175]   Weight (kg)  [72] │
│                                          │
│  BMI  ●───────────────●  22.2  Normal   │
│       ↑ Updates live as you type         │
└─────────────────────────────────────────┘
```

**Screen 5 — Dietary:**
- "You're all set!" summary card animates in after at least 1 dietary chip is tapped.
- On final "Get Started" button press: confetti/sparkle burst, then navigate.

### 3.3 After Onboarding Completes
- `completeOnboarding()` already saves data and recalculates calorie/protein goals.
- Navigate to `/home` (already done).
- On first dashboard load, show a **Welcome Banner** (see Section 4.2).

---

## 4. Dashboard — Real Data & Functional Buttons

### 4.1 Current Layout
```
┌─────────────────────────────────────────┐
│  AppBar: Greeting + Name | Theme | Avatar│
│  [Active Workout Banner if active]       │
│  [Upcoming Habits Banner]               │
│  Hero Activity Rings (3 rings)          │
│  Ring Legend                            │
│  Water Tracker Card                     │
│  AI Insight Card                        │
│  Weekly Overview Banner                 │
│  2x2 Bento Grid (Sleep/Steps/Protein/Cal│
│  Health Tools (Fasting/Body/Supplements) │
└─────────────────────────────────────────┘
```

### 4.2 Non-Functional Items to Fix

#### Sleep Bento Card — No onTap — ✅ FIXED
**File:** `dashboard_screen.dart` line ~718 — `_BentoCard` for SLEEP has no `onTap:`.

**Fix:** Add `onTap: () => _showSleepLogSheet(context, ref)`.

**Sleep Log Bottom Sheet Wireframe:**
```
┌──────────────────────────────────────────────┐
│  ⌄   Log Sleep                               │
│                                              │
│  Bedtime                                     │
│  ┌──────────────────────────────────────┐    │
│  │  10:30 PM           [Change]         │    │
│  └──────────────────────────────────────┘    │
│                                              │
│  Wake Time                                   │
│  ┌──────────────────────────────────────┐    │
│  │  6:45 AM            [Change]         │    │
│  └──────────────────────────────────────┘    │
│                                              │
│  Duration Preview:  8h 15m  🌙              │
│                                              │
│  Quality   ○Poor  ○Fair  ●Good  ○Great      │
│                                              │
│          [  Save Sleep  ]                    │
└──────────────────────────────────────────────┘
```
- Save calls `dailyActivityProvider.notifier.logSleep(minutes: X)`.
- Haptic `mediumImpact()` on save.
- Snackbar: "Sleep logged: 8h 15m ✓"
- Sheet closes, bento card updates immediately (reactive Isar).

#### Steps Bento Card — No onTap
**File:** `dashboard_screen.dart` line ~727 — `_BentoCard` for STEPS has no `onTap:`.

**Fix:** Add `onTap: () => _showStepsDetailSheet(context, today)`.

**Steps Detail Bottom Sheet Wireframe:**
```
┌──────────────────────────────────────────────┐
│  ⌄   Steps Today                             │
│                                              │
│   8,432  steps  ·  Goal: 10,000             │
│   ████████████░░░░  84%                     │
│                                              │
│  Distance:  ~6.7 km   (steps × 0.000762)    │
│  Calories:  ~320 kcal from walking          │
│                                              │
│  ──────── Hourly Breakdown ─────────────────│
│  (bar chart: 0–23h buckets from HealthKit,  │
│   or a single "Total" bar if no hourly data)│
│                                              │
│  [Set Daily Goal]    → number picker popup  │
└──────────────────────────────────────────────┘
```
- "Set Daily Goal" → `showModalBottomSheet` with `NumberPicker` (5000–20000, step 500).
- On save goal: `userProvider.notifier.updateProfile(stepGoal: N)`.
- Snackbar: "Step goal updated to 12,000 ✓"

#### Water Tracker — Long-Press Custom Amount
**File:** `dashboard_screen.dart` line ~527

**Fix:** Wrap the big "Add 250ml" button in a `GestureDetector` with `onLongPress: () => _showWaterAmountSheet(context, ref)`.

**Custom Amount Picker Sheet Wireframe:**
```
┌─────────────────────────────────────────────┐
│  ⌄   Add Water                              │
│                                             │
│   [ 100 ][ 150 ][ 200 ][ 250 ]             │
│   [ 300 ][ 350 ][ 400 ][ 500 ]             │
│                                             │
│   Or enter custom:  [  ___  ] ml           │
│                     (50 – 2000 ml)          │
│                                             │
│   [  Add Custom Amount  ]                   │
└─────────────────────────────────────────────┘
```
- Each chip: `ref.read(dailyActivityProvider.notifier).addWater(amount)` + `selectionClick()` + dismiss.
- Custom: `TextField` with number keyboard, validate 50–2000, then add.
- After any add: ripple animation on the blue progress bar.

#### AI Insight Card — Add "Chat About This" CTA
**File:** `dashboard_screen.dart` line ~1228

**Fix:** Below the AI insight text, add:
```dart
GestureDetector(
  onTap: () {
    HapticFeedback.lightImpact();
    ref.read(chatPrefilledMessageProvider.notifier).state = insightText;
    context.push('/chat');
  },
  child: Text('Chat about this →', style: TextStyle(
    fontSize: 12,
    color: AppColors.softIndigo,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
  )),
)
```
- In `chat_screen.dart` `initState()`: if `chatPrefilledMessageProvider != null`, set `_controller.text` to the prefilled value and clear the provider.

#### First-Launch Empty States
When dashboard loads with all zeros (new user after onboarding):
- Activity rings: ghost/faded rings + subtitle "Sync Apple Watch or log manually"
- Sleep bento: shows "—" with shimmer pulse + subtitle "Tap to log"
- Steps bento: shows "—" + shimmer
- Water: "Start your day hydrated" instead of 0/3000ml label
- AI Insight: "Log your first activity to get a personalized insight."

#### Welcome Banner (first-time only)
After onboarding, show once:
```
┌─────────────────────────────────────────────┐
│ ✦  Welcome, Aryan!                        × │
│    Daily calorie goal: 2,400 kcal           │
│    Protein target: 180g · Step goal: 10,000 │
│    Let's crush today's goals!               │
└─────────────────────────────────────────────┘
```
- Store `hasSeenWelcomeBanner` as `SharedPreferences` bool.
- Dismiss: X tap (`lightImpact()`) or auto-fade after 10 seconds.
- Slide in from top with 400ms easeOutCubic.

---

## 5. Profile — Fix Hardcoded Data & Complete

### 5.1 Wire Real Weekly Data

**7-Day Bar Chart (`_WeeklyActivityCard`)**
Replace `values = [0.7, 0.5, ...]` with:
```
Query DailyLogDoc for last 7 days (today and 6 prior)
Each day value = (caloriesBurned / calorieGoal).clamp(0.0, 1.0)
Days with no data: use 0.03 (tiny stub bar — shows the day exists)
Bar colors: mint gradient for days with data, gray/30% for empty days
```

**Monthly Heatmap (`_HeatmapGrid`)**
Replace `activeSimulated` set:
```
Query DailyLogDoc for all days in current month
Active if: stepCount > 500 || caloriesBurned > 100
Color intensity (3 levels):
  - Low   (stepCount 500–3000):   AppColors.dynamicMint at 30% opacity
  - Mid   (stepCount 3000–7000):  AppColors.dynamicMint at 60% opacity
  - High  (stepCount > 7000):     AppColors.dynamicMint at 100%
```

**Heatmap interaction:** Tap any day → shows a mini tooltip: "Mar 5 — 8,432 steps, 1,840 kcal"

**Streak Calculation**
Create/update `streakProvider`:
1. Fetch all `DailyLogDoc` sorted by date descending.
2. Walk backwards from today, count consecutive active days.
3. "Active" = `stepCount > 500 || caloriesBurned > 100`.
4. Return `{current: int, longest: int}`.
5. Run this calculation in the provider, not inline in the widget.

---

### 5.2 Wire Real Achievements

**Achievement unlock conditions:**

| ID | Label | Unlock Condition | Check Frequency |
|---|---|---|---|
| `early_bird` | Early Bird | Any `DailyLogDoc` with `waterMl > 0` before 8 AM | Daily |
| `scan_master` | Scan Master | Total scans in `MealDoc.source == 'scan'` >= 10 | On each scan |
| `marathon` | Marathon | Sum `DailyLogDoc.stepCount * 0.0008` km >= 42 | Daily |
| `hydrated` | Hydration Hero | 7 `DailyLogDoc` with `waterMl >= waterGoalMl` | Daily |
| `streak_7` | Week Warrior | Current streak >= 7 days | Daily |
| `protein_pro` | Protein Pro | 14 days with `proteinGrams >= proteinGoalG` | Daily |
| `gym_rat` | Gym Rat | Total `WorkoutDoc` count >= 20 | After each workout |
| `perf_week` | Perfect Week | Any 7 consecutive days where all goals met | Daily |

**Achievement Unlock Response:**
- When newly unlocked: show a modal trophy overlay for 2.5 seconds:
  ```
  ┌────────────────────────────────────┐
  │           🏆                       │
  │   Achievement Unlocked!            │
  │   "Week Warrior"                   │
  │   7-day streak completed           │
  │                                    │
  │   [  Awesome!  ]                   │
  └────────────────────────────────────┘
  ```
- Haptic: `heavyImpact()` on unlock.
- Persist unlock timestamp in `UserDoc.unlockedAchievements`.

---

### 5.3 Goals Card — Wire Real Progress Rings

Replace hardcoded values with real `dailyActivityProvider` data:
```dart
// Calories ring
value: (today.caloriesConsumed / user.calorieGoal).clamp(0.0, 1.0)

// Protein ring
value: (today.proteinGrams / user.proteinGoalG).clamp(0.0, 1.0)

// Water ring
value: (today.waterMl / user.waterGoalMl).clamp(0.0, 1.0)
```

---

### 5.4 Edit Profile Sheet — Already Saves Correctly
`_showEditSheet` calls `ref.read(userProvider.notifier).updateProfile(...)` and pops. Working.

---

### 5.5 Add "Re-do Setup" to Settings
In `Settings > Account` section:
- Add "Re-do Setup" action tile.
- Show confirmation dialog: "This will reset your profile name and preferences. Your health data stays on this device."
- On confirm: `ref.read(userProvider.notifier).clearDisplayName()` → `context.go('/onboarding')`.

---

## 6. Habits — Real Data Wiring

### 6.1 Current State (Already Working)
- `HabitDoc` Isar model + `HabitsNotifier` persistence: fully implemented.
- `isCompletedOn()` streak logic: fully implemented.
- Dashboard `_UpcomingHabitsBanner`: fully wired.
- Habits screen: fully wired.

### 6.2 Habit AI Insight — Check & Wire

**Wireframe for AI Section:**
```
┌────────────────────────────────────────────┐
│  ✦ AI INSIGHT                   [Refresh]  │
│  "Your completion rate this week is 73%.   │
│   Try habit stacking: pair your morning    │
│   meditation with your coffee routine."    │
└────────────────────────────────────────────┘
```

Wire a `habitInsightProvider` that calls Gemini with:
- Total habits count
- Today's completion % (completed / total)
- Longest active streak across all habits

**Refresh button response:**
- Button icon spins (300ms rotation animation) while fetching.
- New insight fades in (opacity 0 → 1, 400ms).
- Haptic: `lightImpact()` on tap.

### 6.3 Habit Creation — Add Reminder Time

Add to the existing habit add sheet:

**Habit Add Sheet — Wireframe:**
```
┌──────────────────────────────────────────────┐
│  ⌄   New Habit                              │
│                                              │
│  Name       [Morning Meditation          ]  │
│  Icon       [🧘] [💪] [📖] [💧] ...        │
│  Color      [●] [●] [●] [●] ...            │
│  Frequency  [Daily] [5x/wk] [3x/wk]        │
│                                              │
│  Reminder   [○ None]  [● Set Time]          │
│             Time: 08:00 AM  [Change]        │
│                                              │
│         [  Create Habit  ]                  │
└──────────────────────────────────────────────┘
```

- "Set Time" toggle → shows `showTimePicker(context: context, ...)`.
- Store `reminderTime` in `HabitDoc`.
- Schedule `flutter_local_notifications` repeating daily notification.
- **Response after create:**
  - Sheet closes with `mediumImpact()`.
  - New habit slides in at top of list (300ms easeOutCubic).
  - Snackbar: "Morning Meditation added! Reminder set for 8:00 AM ✓"

### 6.4 Date Strip — Real History

**Wireframe:**
```
  M    T    W    T    F    S    S
 [✓]  [✓]  [✗]  [✓]  [✓]  [ ]  [ ]
  ↑                         ↑today
past days show ✓/✗ based on actual completions
```

- Each past day tappable: highlights that day, the habit list shows that day's state (read-only).
- Header subtitle updates: "Monday, Feb 24 — 4 of 5 habits completed"
- Today's habits remain interactive (toggle-able).
- Visual: selected day gets a soft indigo background bubble.

---

## 7. Nutrition — Complete the Feature

### 7.1 Current State
- `NutritionScreen` with `MealDoc` Isar: built.
- Date nav, meal grouping: built.
- Dashboard bento cards: wired.
- Gallery picker `_onGalleryPick`: already implemented.
- Manual entry sheet `_showManualEntrySheet`: already implemented.

### 7.2 Scanner Flash Toggle — Guard Fix

**File:** `scanner_screen.dart` line ~351–355

The flash toggle calls `_cameraController?.setFlashMode(...)` but the camera controller may not be initialized yet. Silent null-check ignores the call silently.

**Fix:** Guard explicitly:
```dart
onTap: () {
  if (!_isCameraInitialized || _cameraController == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera not ready')));
    return;
  }
  setState(() => _flashOn = !_flashOn);
  _cameraController!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
},
```

### 7.3 Manual Food Entry Sheet — Verify & Enhance

Already implemented (`_showManualEntrySheet`). Verify complete wireframe:
```
┌────────────────────────────────────────┐
│  ⌄   Add Food Manually                 │
│                                        │
│  Food Name   [Chicken Breast        ]  │
│  Calories    [165     ] kcal           │
│  Protein     [31      ] g              │
│  Carbs       [0       ] g              │
│  Fats        [3.6     ] g              │
│                                        │
│  Meal Type   [○ Breakfast] [● Lunch]   │
│              [○ Dinner  ] [○ Snack ]   │
│                                        │
│  Portion     ●──────────○  1.0x        │
│                                        │
│         [  Add to Log  ]               │
└────────────────────────────────────────┘
```

**Response on save:**
- Sheet dismisses with `mediumImpact()`.
- Nutrition screen refreshes immediately (Isar reactive query).
- Snackbar: "Chicken Breast added to Lunch ✓"
- Tap on the new item in the list expands macros.

### 7.4 Per-Meal Totals Row
Add after each meal section header:
```
LUNCH                              580 kcal  ·  42g protein
────────────────────────────────────────────────────────────
  Chicken Breast  165 kcal  31g P
  Rice            206 kcal  4g P
  Broccoli        55 kcal   3.7g P
```
- Totals update reactively as items are added/removed.
- Animate totals: number rolls up when first appearing (300ms).

### 7.5 Daily Macro Summary Bar
At the top of `NutritionScreen`, add:

**Wireframe:**
```
┌────────────────────────────────────────────────┐
│  Tue, March 1                    1,240 / 2,400 │
│                                                 │
│  Calories  ████████░░░░░░  52%  1,240 kcal     │
│  Protein   ██████░░░░░░░░  40%  72 / 180g      │
│  Carbs     ████████████░░  80%  240 / 300g     │
│  Fats      ███████░░░░░░░  55%  44 / 80g       │
└────────────────────────────────────────────────┘
```
- Animate progress bars on screen mount: 1200ms easeOutCubic.
- Colors: Calories=orange, Protein=red, Carbs=indigo, Fats=mint.
- Tap any row → tooltip: "X remaining" or "X over goal" with haptic `selectionClick()`.

### 7.6 Barcode Scanner (Phase 10 — Future)
- `mobile_scanner` is already in `pubspec.yaml`.
- Add barcode icon button in scanner top-right.
- Hit Open Food Facts API: `https://world.openfoodfacts.org/api/v0/product/{barcode}.json`
- Parse: `product.product_name`, `product.nutriments.energy-kcal_100g`, `proteins_100g`, `carbohydrates_100g`, `fat_100g`.

---

## 8. Fasting Screen — Improvements

### 8.1 Current State
- `FastingScreen` with `FastingDoc` Isar: built and wired.
- Active state, phase display, target hours: working.
- History bottom sheet (`_showHistory`): working.

### 8.2 Improvements

**Improved Layout Wireframe:**
```
┌──────────────────────────────────────┐
│  ←  Intermittent Fasting             │
│                                      │
│         [Phase Badge: Ketosis]       │
│                                      │
│    ┌─────────────────────────┐       │
│    │      13.2h / 16h        │       │
│    │    ████████████░░░░     │       │
│    │        82.5%            │       │
│    └─────────────────────────┘       │
│                                      │
│   Phase Timeline (horizontal scroll) │
│   [Fed]──[Fasted]──[Ketosis]──[Auto] │
│              Now ↑                   │
│                                      │
│   Target  [ 16h ] [ 18h ] [ 24h ]   │
│                                      │
│   Last 7 Fasts (mini bar chart)      │
│   ▄ ▄ █ ▄ ▅ ▄ █                     │
│                                      │
│         [  End Fast  ]               │
└──────────────────────────────────────┘
```

**Phase Timeline Row:**
- Horizontal `ListView` of phase chips: Fed / Early Fasted / Fasted / Ketosis / Autophagy.
- Colors: gray / blue / green / purple / gold.
- Current phase chip glows with `BoxShadow` at 0.4 opacity.
- Tap a chip: shows a tooltip with phase description + health benefits.

**7-Day History Mini Bar Chart:**
- `fastingHistoryProvider` already returns list of `FastingDoc`.
- Take last 7, show each as a bar: `height = (fast.durationH / 24).clamp(0, 1)`.
- Bar colored by phase achieved (same color map as timeline).
- Below each bar: day label (M/T/W etc).
- Tap bar: shows "Mon Feb 24 — 18.5h fast, Ketosis reached ✓"

---

## 9. Body Composition — Improvements

### 9.1 Current State
- `BodyCompositionScreen` with `BodyEntryDoc` Isar: built and wired.
- Add entry, weight/body fat tracking: working.
- `_LineChartPainter`: already uses real `bodyEntries` data.

### 9.2 Metric Chip Selector
Add chip row above the chart:
```
[ Weight kg ▾ ]  [ Body Fat % ]  [ BMI ]
```
- Switching chips re-renders the chart line with the selected metric.
- Animate line transition: 400ms ease, old line fades out while new line draws in.

### 9.3 BMI Category Banner
Below the chart:
```
┌──────────────────────────────────────┐
│  BMI: 22.4              Normal ✓     │
│  ─────────────────────────────────   │
│  Underweight | Normal | Overweight | Obese │
│                  ↑ you are here      │
└──────────────────────────────────────┘
```

**Tap the BMI banner:**
- Shows a modal with:
  - BMI explanation text
  - Healthy range for the user's age/gender
  - AI tip: "Your BMI is in the healthy range. Focus on maintaining your muscle mass with protein intake of X g/day."
- Haptic: `lightImpact()` on tap.

### 9.4 Goal Weight Progress Bar
- "Set Goal Weight" button in app bar or within the log sheet.
- After setting: show a progress card:
  ```
  Current: 72.5 kg  →  Goal: 68 kg  (4.5 kg remaining)
  ████████████████░░░░░░  78%
  ```
- Progress = `(startWeight - currentWeight) / (startWeight - goalWeight)`.
- "Start weight" is earliest `BodyEntryDoc` entry.
- Estimated time label: "~4 weeks at current rate" (based on last 4-week weight delta).

---

## 10. Supplements — Improvements

### 10.1 Current State
- `SupplementScreen` with `SupplementDoc` Isar: built and wired.
- Add/edit/delete: working.
- Mark as taken (`logTaken()`): working.
- Taken count (`takenCountTodayProvider`): working.

### 10.2 Mark as Taken — Add Snackbar Feedback

**File:** `supplement_screen.dart` line ~371–388

After `logTaken(sup.id)`:
```dart
HapticFeedback.mediumImpact();
ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  content: Text('${sup.name} marked as taken ✓'),
  duration: const Duration(seconds: 2),
  behavior: SnackBarBehavior.floating,
  backgroundColor: AppColors.dynamicMint.withOpacity(0.9),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
));
```

Mark-as-taken animation:
- Check icon: scale 0 → 1 with `easeOutBack` curve, 200ms.
- Background: color transition from `accent.withOpacity(0.1)` to `accent` in 150ms.

### 10.3 Time of Day Grouping
Group supplements by their `timeOfDay` field:

```
MORNING                           3 of 4 taken
────────────────────────────────────────────────
 [✓]  Vitamin D    1000 IU  ·  with food
 [✓]  Omega 3      1g       ·  with food
 [✗]  Magnesium    400mg    ·  after meal
 [✓]  Zinc         15mg     ·  morning

EVENING                           0 of 1 taken
────────────────────────────────────────────────
 [✗]  Melatonin    5mg      ·  before sleep
```

Section header tap: collapses/expands that time group (AnimatedSize, 300ms).

### 10.4 Preset Packs Sheet

Add "Browse Stacks" button in the FAB area or empty state:

**Sheet Wireframe:**
```
┌──────────────────────────────────────────────┐
│  ⌄   Supplement Stacks                       │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │  🌱 Beginner Health Stack   [Add All]  │  │
│  │  Vitamin D · Omega 3 · Magnesium       │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │  💪 Athlete Stack           [Add All]  │  │
│  │  Creatine · Protein · BCAA · Zinc      │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │  🌙 Sleep Stack             [Add All]  │  │
│  │  Mag Glycinate · Melatonin · L-Theanine│  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

**Response on "Add All":**
- All supplements added via `supplementProvider.notifier.addAll([...])`.
- Sheet dismisses.
- Snackbar: "Beginner Health Stack added (3 supplements) ✓"
- Haptic: `mediumImpact()`.
- "Add All" button changes to "Added ✓" for 2s before sheet closes.

---

## 11. Workout Library & Programs

### 11.1 Current State
- `WorkoutLibraryScreen`: built, reachable from bottom nav, has "Programs" tab.
- `WorkoutProgramsScreen`: reachable from Programs tab.
- `WorkoutPlayerScreen`, `WorkoutSummaryScreen`: built and wired.

### 11.2 WorkoutSummaryScreen — "View Progress" Button

**File:** `workout_summary_screen.dart` line ~195

Add below existing buttons:
```dart
OutlinedButton(
  onPressed: () {
    HapticFeedback.lightImpact();
    context.push('/workout/progress');
  },
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: BorderSide(color: Colors.white.withOpacity(0.2)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    minimumSize: const Size(double.infinity, 50),
  ),
  child: const Text('VIEW MY PROGRESS',
    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
),
```

Animate with `.animate(delay: 850.ms).fadeIn()`.

### 11.3 Chat Workout Plan — "Save to My Plans"

AI Chat generates `workout_plan` JSON cards. Add "Save to My Plans" button:

**Save Flow:**
1. User sees AI workout plan card in chat.
2. Taps "Save to My Plans".
3. Button shows loading spinner (300ms).
4. Plan saved as `WorkoutPlanDoc` to Isar.
5. Snackbar: "Push Day saved to My Plans ✓"
6. Haptic: `mediumImpact()`.
7. Button changes to "Saved ✓" (disabled, green tint).

---

## 12. Strength Progress Charts

### 12.1 Current State
- `StrengthChartsScreen` at `/workout/progress`.
- Reachable from Profile > Personal Bests.
- New entry point: WorkoutSummaryScreen (Section 11.2).

### 12.2 UI Wireframe
```
┌──────────────────────────────────────┐
│  ←  Strength Progress               │
│                                      │
│  [Bench Press ▾]  ← exercise picker │
│                                      │
│  [Volume]  [1RM]  [Reps]  ← tabs    │
│                                      │
│  Estimated 1RM (kg)                  │
│  100 ┤             ●                 │
│   90 ┤         ●                     │
│   80 ┤    ●●                         │
│   70 ┤●                              │
│      └──────────────────────────     │
│      Jan  Feb  Mar  Apr  May         │
│                                      │
│  Recent Sessions                     │
│  Mar 1  ·  5×5  ·  90 kg  ·  PR ✦  │
│  Feb 25 ·  4×6  ·  87.5 kg         │
└──────────────────────────────────────┘
```

**Exercise picker:** Dropdown populated from all distinct `exerciseName` values in `ExercisePRDoc`.

**Tab switching (Volume / 1RM / Reps):**
- Volume = total kg × reps for that session.
- 1RM = Epley formula: `weight × (1 + reps/30)`.
- Reps = max reps in a set that session.
- Animate chart lines: old line fades out (200ms), new line draws in (600ms).

**PR Badge:** When a session sets a new PR, show gold "PR ✦" badge inline in the recent sessions list.

---

## 13. Weekly Overview Screen

### 13.1 Current State
- `WeeklyOverviewScreen` at `/weekly`: built.
- Uses `weeklyStatsProvider` → real Isar data: confirmed working.
- AI weekly summary (`weeklyInsightProvider`): working.

### 13.2 Add Macro Averages Section

Add below the workouts list:
```
┌─────────────────────────────────────────────┐
│  MACRO AVERAGES (7-day)                     │
│                                             │
│  Calories  1,840 avg / 2,400 goal  77%     │
│  ████████████████████░░░░░░░░             │
│                                             │
│  Protein   122g avg  / 180g goal   68%     │
│  ████████████████░░░░░░░░░░░░              │
│                                             │
│  Water     2.1L avg  / 3.0L goal   70%     │
│  ████████████████░░░░░░░░░░                │
└─────────────────────────────────────────────┘
```

Pull data from: average of last 7 `DailyLogDoc.caloriesConsumed`, `.proteinGrams`, `.waterMl`.

Tap any row → shows a mini 7-day bar chart for that specific macro.

---

## 14. AI Chat — Functional Buttons & Improvements

### 14.1 Current State
- Gemini + Gemma offline: working.
- Mic button (`_toggleListening` with `speech_to_text`): already implemented.
- Message streaming: working.
- Meal/workout plan cards: working.
- **Paperclip attach button: COMPLETELY EMPTY (`onTap: () {}`).**

### 14.2 Attach Button — Does Nothing (CRITICAL FIX)

**File:** `chat_screen.dart` line 744–767
```dart
GestureDetector(
  onTap: () {},  // ← EMPTY — must be fixed
  ...
  Icon(PhosphorIconsRegular.paperclip, ...)
)
```

**Fix:** Show a bottom action sheet on tap:

**Attachment Action Sheet Wireframe:**
```
┌──────────────────────────────────────┐
│  ⌄   Attach                          │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  📷  Take Photo              │    │
│  │  Scan food with your camera  │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  🖼  Choose from Gallery     │    │
│  │  Pick a food photo           │    │
│  └──────────────────────────────┘    │
│                                      │
│  ┌──────────────────────────────┐    │
│  │  📊  Share My Stats          │    │
│  │  Attach today's health data  │    │
│  └──────────────────────────────┘    │
│                                      │
│  [Cancel]                            │
└──────────────────────────────────────┘
```

**Take Photo / Gallery flow:**
1. `image_picker.pickImage(source: ImageSource.camera / .gallery)`.
2. Attached image appears as a 56×56 thumbnail above the text field (with × to remove).
3. On send: Gemini Vision API with `"Identify this food. Return: name, estimated calories, protein, carbs, fats per serving."`.
4. AI reply includes nutrition info + a confirmation card:
   ```
   ┌──────────────────────────────────────┐
   │  🍗 Chicken Breast (~200g)           │
   │  Calories: 330 kcal                  │
   │  Protein: 62g  Carbs: 0g  Fats: 7g  │
   │                                      │
   │  [Add to Today's Log]  [Edit Values] │
   └──────────────────────────────────────┘
   ```
5. "Add to Today's Log" → creates `MealDoc` → Snackbar: "Chicken Breast added to Lunch ✓"
6. "Edit Values" → opens manual entry sheet pre-filled with the AI's values.

**Share My Stats flow:**
- Appends a health context block to the input text field:
  ```
  [My stats today: calories 1,240/2,400, protein 72g/180g,
   water 2.1L/3.0L, 8,432 steps, streak: 5 days]
  ```
- User sees this in their text field, can edit, then send.

**Image thumbnail preview (before send):**
```
┌──────────────────────────────────────┐
│  ┌────┐                              │
│  │ 🍗  │ ×  (tap × to remove)       │
│  │img │                              │
│  └────┘                              │
│  [Type a message...      ] [send ▶] │
└──────────────────────────────────────┘
```

### 14.3 Suggested Prompts — Dynamic

Current: static strings. Make data-driven:
```dart
List<String> buildSuggestedPrompts(UserDoc user, DailyLogDoc today, int streak) {
  final remaining = user.calorieGoal - today.caloriesConsumed;
  return [
    if (today.caloriesConsumed < 100)
      "What should I eat today? I have $remaining kcal remaining.",
    if (streak > 7)
      "I'm on a ${streak}-day streak! What should I focus on next?",
    if (today.waterMl < user.waterGoalMl * 0.5)
      "Remind me why hydration matters. I'm at ${today.waterMl}ml today.",
    "Give me a personalized tip for today.",
    "Create a workout plan for ${user.primaryGoal ?? 'general fitness'}.",
  ];
}
```

Suggested prompts displayed as horizontally scrollable chips above the text field.

### 14.4 Expanded AI Context

Build `buildAiContext(UserDoc user, DailyLogDoc today, int streak)` utility:
```
You are a personal health AI assistant.
User: ${user.displayName}, age ${user.age}, ${user.heightCm}cm, ${user.weightKg}kg
Goal: ${user.primaryGoal}, Fitness Level: ${user.fitnessLevel}
Today (${date}):
  Calories: ${today.caloriesConsumed} / ${user.calorieGoal} kcal
  Protein: ${today.proteinGrams}g / ${user.proteinGoalG}g
  Water: ${today.waterMl}ml / ${user.waterGoalMl}ml
  Steps: ${today.stepCount}
  Active streak: ${streak} days
Dietary: ${user.preferences.dietary.join(', ')}
```

Inject as system prompt into every Gemini API call. This makes every response personalized.

### 14.5 Proactive Daily Notifications

Schedule via `flutter_local_notifications` at 8:00 PM daily:
- Habits < 50% complete: "You have [N] habits left for today — quick win time!"
- Calorie goal not met: "You're [X] kcal under your goal — time for a healthy snack!"
- No workout this week: "[N] days without a workout — AI Coach has a 20-min session ready."
- Everything done: "All goals hit today! You're on a [streak]-day streak. Keep it up!"

These run via `NotificationService.instance.scheduleDailyEveningCheck()`.

---

## 15. Settings Screen — Wire Every Item

### 15.1 Non-Functional Items Found & Fixes

#### Appearance Section
| Item | Line | Issue | Fix |
|---|---|---|---|
| Haptic Feedback toggle | 176–182 | Hardcoded `value: true`, no persistence | Persist `haptics_enabled` to SharedPreferences; wrap all `HapticFeedback.*` calls in a `HapticsService` |

#### AI Model Section
| Item | Line | Issue | Fix |
|---|---|---|---|
| Context Memory toggle | 252–258 | Hardcoded `value: true`, no effect | Persist `ai_context_memory` to SharedPreferences; skip `buildAiContext()` if disabled |
| Streaming Responses toggle | 261–267 | Hardcoded `value: true`, no effect | Persist `ai_streaming` to SharedPreferences; switch between streaming/non-streaming Gemini call |

#### Units Section
| Item | Line | Issue | Fix |
|---|---|---|---|
| Unit System selector | 453–461 | `updateProfile(// empty)` — does nothing | Add `updateUnitSystem()` to `UserNotifier`, save to `UserPreferences.unitSystem` |

#### Notifications Section
| Item | Line | Issue | Fix |
|---|---|---|---|
| Morning Motivation toggle | 301–308 | Toggle change does nothing | Persist `morning_motivation_enabled`; `NotificationService.scheduleMorningMotivation()` or `.cancelMorningMotivation()` |

#### Privacy & Security Section
| Item | Line | Issue | Fix |
|---|---|---|---|
| Biometric Lock toggle | 480–486 | `value: false`, no real auth | `local_auth` package: request, test, gate app on resume |
| Analytics toggle | 489–495 | Hardcoded `value: true`, no persistence | Persist `analytics_enabled` toggle state to SharedPreferences |
| Privacy Policy tap | 498–503 | Opens nothing | `url_launcher` → `https://healthai.app/privacy` or inline `showDialog` |
| Terms of Service tap | 506–511 | Opens nothing | `url_launcher` → `https://healthai.app/terms` or inline `showDialog` |

#### About Section
| Item | Line | Issue | Fix |
|---|---|---|---|
| Rate the App tap | 536–540 | Opens nothing | `in_app_review` package: `InAppReview.instance.requestReview()` |
| Send Feedback tap | 543–548 | Opens nothing | `url_launcher`: `mailto:support@healthai.app?subject=Feedback` |

#### Account Section
| Item | Line | Issue | Fix |
|---|---|---|---|
| Sign Out tap | 576–581 | Does nothing | Reframe as "Re-do Setup": confirm → `clearDisplayName()` → `/onboarding` |
| Delete Account confirm | 594–606 | `onConfirm: () => Navigator.pop(context)` — deletes NOTHING | Clear all Isar collections, then `context.go('/onboarding')` |

**Delete Account fix (full):**
```dart
onConfirm: () async {
  Navigator.pop(context); // close dialog
  final isar = ref.read(isarProvider);
  await isar.writeTxn(() async {
    await isar.userDocs.clear();
    await isar.dailyLogDocs.clear();
    await isar.mealDocs.clear();
    await isar.habitDocs.clear();
    await isar.workoutDocs.clear();
    await isar.bodyEntryDocs.clear();
    await isar.supplementDocs.clear();
    await isar.fastingDocs.clear();
    // clear any other collections
  });
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  if (context.mounted) context.go('/onboarding');
},
```

### 15.2 Delete Account UI Response
- Show loading overlay during deletion ("Deleting your data...").
- HeavyImpact haptic when confirming.
- Navigate to onboarding after completion.

### 15.3 Settings Items to Add

Add to `_AccountSection`:
- **Edit Profile** → `context.push('/profile')` (quick nav, user can tap edit there).
- **Re-do Setup** → confirmation → `clearDisplayName()` → `/onboarding`.

---

## 16. Global UI/UX Tokens & Consistency

### 16.1 Design Tokens
```dart
AppColors.deepObsidian    // #0B0E14  — dark bg
AppColors.charcoalGlass   // #1A1D2A  — card bg dark
AppColors.cloudGray       // #F4F6F9  — light bg
AppColors.dynamicMint     // #00D4B2  — primary green
AppColors.softIndigo      // #6B7AFF  — primary purple
AppColors.warning         // #FF9F43  — orange
AppColors.danger          // #FF5757  — red
```

### 16.2 Animation Standards
| Element | Duration | Curve |
|---|---|---|
| Page entry | 350ms | easeOutCubic |
| Card stagger | 80ms interval | easeOutCubic |
| Progress bars (on mount) | 1200–1400ms | easeOutCubic |
| Button press scale | 100–120ms | easeInOut |
| Modal sheet slide | 400ms | easeOutCubic |
| Check mark (done) | 150–200ms | easeOutBack |
| Snackbar slide-in | 300ms | easeOutCubic |
| Number counter roll | 300ms | easeOut |
| Chart line draw | 600ms | easeOutCubic |

### 16.3 Haptic Feedback Standard
| Action | Feedback |
|---|---|
| Tap navigation / open modal | `lightImpact()` |
| Toggle / chip select | `selectionClick()` |
| Save / complete / confirm | `mediumImpact()` |
| Achievement unlock / delete | `heavyImpact()` |
| Mark habit / supplement done | `mediumImpact()` |
| Long-press trigger | `selectionClick()` |
| Error | `heavyImpact()` |

### 16.4 Snackbar Standard
```dart
ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  content: Text('[Action confirmed] ✓'),
  duration: const Duration(seconds: 2),
  behavior: SnackBarBehavior.floating,
  backgroundColor: accentColor.withOpacity(0.9),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
));
```

### 16.5 Empty State Standard
```
┌──────────────────────────────────────┐
│                                      │
│     [icon — 48px, accent @ 20%]     │
│                                      │
│     No [items] yet                   │
│     [Descriptive one-liner]          │
│                                      │
│     [+ Add First Item]               │
│                                      │
└──────────────────────────────────────┘
```

### 16.6 Loading Shimmer Standard
```dart
Container(height: X, decoration: BoxDecoration(
  color: accent.withOpacity(0.1),
  borderRadius: BorderRadius.circular(radius),
))
.animate(onPlay: (c) => c.repeat(reverse: true))
.shimmer(duration: 1200.ms, color: accent.withOpacity(0.05))
```

---

## 17. Implementation Order (Priority Queue)

### Phase 1 — Fix Hardcoded/Fake Data (CRITICAL)
1. Fix onboarding trigger (`app_router.dart` hardcoded `false`)
2. Profile 7-day bar chart → real `DailyLogDoc` data
3. Profile heatmap → real `DailyLogDoc` data
4. Profile streak → real calculation
5. Remove fake achievement unlocks (`'early_bird', 'scan_master'`)
6. Wire real achievement unlock conditions
7. Profile `_GoalsCard` rings → real `dailyActivityProvider` data

### Phase 2 — Wire All Empty Button Handlers
8. Sleep bento card → sleep log bottom sheet
9. Steps bento card → steps detail bottom sheet
10. Water tracker → long-press custom amount picker
11. AI Insight card → "Chat about this" CTA
12. Chat paperclip attach button (`onTap: () {}`) → action sheet
13. Settings: Unit System selector → `updateUnitSystem()`
14. Settings: Sign Out → re-do setup flow with confirmation
15. Settings: Delete Account `onConfirm` → actually clear all Isar + SharedPreferences

### Phase 3 — Settings: Persist All Toggles
16. Haptic Feedback toggle → `SharedPreferences` + `HapticsService`
17. Context Memory toggle → `SharedPreferences` + wire to chat
18. Streaming Responses toggle → `SharedPreferences` + wire to chat
19. Morning Motivation toggle → `NotificationService` schedule/cancel
20. Biometric Lock → `local_auth` package
21. Analytics toggle → `SharedPreferences` (state persistence)
22. Privacy Policy → `url_launcher` or inline modal
23. Terms of Service → `url_launcher` or inline modal
24. Rate the App → `in_app_review`
25. Send Feedback → `url_launcher` mailto

### Phase 4 — Nutrition Complete
26. Scanner flash toggle guard (`_isCameraInitialized` check)
27. Nutrition daily macro summary bar at screen top
28. Per-meal totals row in each meal section

### Phase 5 — Workout & Progress
29. `WorkoutSummaryScreen` → "View My Progress" button
30. Chat workout plan card → "Save to My Plans" → Isar + snackbar

### Phase 6 — AI Improvements
31. Build `buildAiContext()` utility — inject user data into every prompt
32. Dynamic/data-driven suggested prompts
33. Chat image attachment → Gemini Vision → nutrition confirmation card → MealDoc save
34. Proactive daily 8 PM notifications

### Phase 7 — Supplements & Body Composition
35. Supplements mark-as-taken snackbar
36. Supplements time-of-day grouping
37. Supplements preset packs sheet
38. Body composition metric chip selector (Weight / Body Fat % / BMI)
39. Body composition BMI banner + tap interaction
40. Body composition goal weight progress bar

### Phase 8 — Profile, Habits & Dashboard Polish
41. Habits date strip real history (tap past days)
42. Habits reminder time picker in add sheet
43. Habits AI insight wire (`habitInsightProvider`)
44. Dashboard first-launch empty states
45. Dashboard welcome banner (first-time only)
46. Achievement unlock trophy modal

### Phase 9 — Weekly, Fasting, & Charts
47. Weekly Overview macro averages section
48. Fasting horizontal phase timeline
49. Fasting 7-day history mini bar chart
50. Body composition goal weight estimated time label
51. Strength Charts tab switching (Volume / 1RM / Reps)
a 
### Phase 10 — Future (Voice, Barcode, Advanced)
52. Mic button — verify works on device (already implemented)
53. Barcode scanner + Open Food Facts API
54. Steps hourly breakdown from HealthKit
55. Sleep quality tracking integration

---

## 18. Complete Fake/Non-Functional UI Audit

This is the complete catalogue of every UI element that shows content but either does nothing on interaction OR shows hardcoded/simulated data.

### Dashboard (`dashboard_screen.dart`)
| Element | Location | Issue | Phase |
|---|---|---|---|
| Sleep bento card | line ~718 | ✅ FIXED — `onTap` wired → `_SleepLogSheet` | 2 |
| Steps bento card | line ~727 | No `onTap` — not tappable | 2 |
| Water add button | line ~527 | Fixed +250ml only, no custom | 2 |
| AI Insight card | line ~1228 | No "Chat about this" CTA | 2 |
| Empty state (new user) | N/A | No empty state — shows zeros | 8 |
| Welcome banner | N/A | Missing after onboarding | 8 |

### Profile (`profile_screen.dart`)
| Element | Location | Issue | Phase |
|---|---|---|---|
| 7-day bar chart | line 772 | ✅ FIXED — real `weeklyStatsProvider` data | 1 |
| Monthly heatmap | line 1202 | ✅ FIXED — real `DailyLogDoc` current month | 1 |
| Current streak | line 1134 | ✅ FIXED — calculated from `DailyLogDoc` history | 1 |
| Longest streak | line 1135 | ✅ FIXED — calculated from `DailyLogDoc` history | 1 |
| Achievement unlocked list | line 975 | ✅ FIXED — removed forced `early_bird`/`scan_master` | 1 |
| Goals card rings | line ~338 | Hardcoded `1800 / calorieGoal`, `85 / proteinGoalG` | 1 |

### Settings (`settings_screen.dart`)
| Element | Location | Issue | Phase |
|---|---|---|---|
| Haptic Feedback toggle | line 176–182 | Hardcoded `value: true`, no persistence | 3 |
| Context Memory toggle | line 252–258 | Hardcoded `value: true`, no effect | 3 |
| Streaming Responses toggle | line 261–267 | Hardcoded `value: true`, no effect | 3 |
| Unit System selector | line 453–461 | ✅ FIXED — `updateUnitSystem()` added and wired | 2 |
| Morning Motivation toggle | line 301–308 | Toggle fires no action | 3 |
| Biometric Lock toggle | line 480–486 | `value: false`, no real auth | 3 |
| Analytics toggle | line 489–495 | Hardcoded `value: true`, no persistence | 3 |
| Privacy Policy tap | line 498–503 | Opens nothing | 3 |
| Terms of Service tap | line 506–511 | Opens nothing | 3 |
| Rate the App tap | line 536–540 | Opens nothing | 3 |
| Send Feedback tap | line 543–548 | Opens nothing | 3 |
| Sign Out tap | line 576–581 | Does nothing | 2 |
| Delete Account confirm | line 594–606 | `onConfirm` only pops dialog, deletes nothing | 2 |

### Chat (`chat_screen.dart`)
| Element | Location | Issue | Phase |
|---|---|---|---|
| Paperclip attach button | line 744–767 | `onTap: () {}` — completely empty | 2, 6 |
| Suggested prompts | line ~712 | Static strings, not personalized | 6 |
| AI system context | chat_controller | No user health data injected | 6 |

### Supplements (`supplement_screen.dart`)
| Element | Location | Issue | Phase |
|---|---|---|---|
| Mark as taken | line ~371–388 | No haptic or snackbar feedback | 7 |
| Time-of-day grouping | N/A | All supplements listed flat | 7 |
| Preset packs | N/A | Missing entirely | 7 |

### Body Composition (`body_composition_screen.dart`)
| Element | Location | Issue | Phase |
|---|---|---|---|
| Metric chip selector | N/A | Missing — always shows weight | 7 |
| BMI category banner | N/A | Missing | 7 |
| Goal weight progress | N/A | Missing | 7 |

### Workout Summary (`workout_summary_screen.dart`)
| Element | Location | Issue | Phase |
|---|---|---|---|
| "View Progress" button | N/A | ✅ FIXED — Added button → `/workout/progress` | 5 |

### Habits (`habits_screen.dart`)
| Element | Location | Issue | Phase |
|---|---|---|---|
| Date strip past days | N/A | Shows today only, no history | 8 |
| Habit add reminder | N/A | No reminder time picker | 8 |
| AI insight wiring | N/A | Check if static | 8 |

### Fasting (`fasting_screen.dart`)
| Element | Location | Issue | Phase |
|---|---|---|---|
| Phase timeline | N/A | Missing horizontal scrollable timeline | 9 |
| 7-day history chart | N/A | History modal exists, no visual bar chart | 9 |

### Weekly Overview (`weekly_overview_screen.dart`)
| Element | Location | Issue | Phase |
|---|---|---|---|
| Macro averages section | N/A | Missing | 9 |

---

## Appendix: File Reference Map

| Feature | Screen File | Provider/Controller |
|---|---|---|
| Onboarding | `features/onboarding/presentation/onboarding_screen.dart` | `features/profile/application/user_provider.dart` |
| Dashboard | `features/dashboard/presentation/dashboard_screen.dart` | `features/dashboard/application/daily_activity_provider.dart` |
| Habits | `features/habits/presentation/habits_screen.dart` | `features/habits/application/habit_provider.dart` |
| Nutrition | `features/nutrition/presentation/nutrition_screen.dart` | (MealDoc Isar direct) |
| Scanner | `features/diet_scanner/presentation/scanner_screen.dart` | (Gemini Vision) |
| AI Chat | `features/chat/presentation/chat_screen.dart` | `features/chat/application/chat_controller.dart` |
| Profile | `features/profile/presentation/profile_screen.dart` | `features/profile/application/user_provider.dart` |
| Workout Library | `features/workout/presentation/workout_library_screen.dart` | `features/workout/application/workout_controller.dart` |
| Fasting | `features/fasting/presentation/fasting_screen.dart` | `features/fasting/application/fasting_provider.dart` |
| Body Composition | `features/body_composition/presentation/body_composition_screen.dart` | `features/body_composition/application/body_provider.dart` |
| Supplements | `features/supplements/presentation/supplement_screen.dart` | `features/supplements/application/supplement_provider.dart` |
| Strength Charts | `features/workout/presentation/strength_charts_screen.dart` | (ExercisePRDoc Isar direct) |
| Weekly Overview | `features/dashboard/presentation/weekly_overview_screen.dart` | `features/dashboard/application/weekly_stats_provider.dart` |
| Settings | `features/settings/presentation/settings_screen.dart` | `theme/theme_provider.dart` |
| Router | `routing/app_router.dart` | — |
| Database | `database/models/` | `services/local_db_service.dart` |
