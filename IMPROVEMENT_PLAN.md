# HealthAI — Comprehensive Improvement Plan
> Full audit of the current app as of March 2026. Every feature, every screen, every micro-detail.

---

## 0. Current App State (Audit Summary)

### What exists and works
| Screen / Feature | Status | Notes |
|---|---|---|
| Dashboard | ✅ Full | Activity rings, bento grid, water, sleep, AI daily insight, achievements, health-connect sync |
| Nutrition | ✅ Full | Date nav, macro rings, progress bars, meal sections, quick-add, barcode scanner trigger, weekly AI insight |
| Workout Library | ✅ Full | Browse, search, muscle-group filter, wger API images, start workout |
| Workout Player | ✅ Full | Timer, sets/reps, rest countdown, exercise queue, finish → summary |
| Workout Summary | ✅ Full | Stats, personal bests, confetti, save to Isar |
| Workout Programs | ✅ Full | AI-generated multi-week plans, program overview, start |
| Strength Charts | ✅ Full | Volume / 1RM / frequency line charts, per-exercise history |
| Habits | ✅ Full | Create custom habits, daily check-off, streak display, AI insight card |
| Fasting | ✅ Full | 5 protocol presets, live ring timer, phase display, history list |
| Body Composition | ✅ Full | Weight / Body Fat / BMI log, chart, BMI gauge, goal weight |
| Supplements | ✅ Full | Time-of-day groups, preset packs, dosage tracking |
| Chat (AI) | ✅ Full | HuggingFace Llama-3.3, voice STT, photo input, health context injection, session history |
| Weekly Overview | ✅ Full | Bar chart steps/calories, AI weekly insight |
| Profile / Settings | ✅ Full | Edit goals, dark/light mode, notification toggles |
| Onboarding | ✅ Full | Multi-step, goal selection, unit selection, persists to Isar |
| Barcode Scanner | ⚠️ Partial | Camera opens, but scanned barcode does NOT auto-fill nutrition data (dead-end UX) |
| Food Search | ❌ Missing | No database search; user must know every calorie manually |
| Sleep Detail Screen | ❌ Missing | Only a bottom-sheet log on dashboard; no trends, no insights |
| Progress / Analytics | ❌ Missing | `/progress` route is a placeholder stub |
| Social / Sharing | ❌ Missing | No share-a-card, no export |
| Water reminder push | ⚠️ Partial | Evening nudge exists; intra-day water reminders missing |

---

## 1. Feature: Food Search + Barcode Auto-Fill (HIGHEST PRIORITY)

### Problem
Every time a user taps "+" on Nutrition they must type a food name AND manually enter every macro. Nobody sustains this. The barcode scanner opens the camera but the scanned code is discarded — it doesn't look up nutrition data.

### Solution: Open Food Facts Integration

**Files to create/modify:**
- `lib/src/services/food_search_service.dart` — new HTTP service
- `lib/src/features/nutrition/presentation/nutrition_screen.dart` — replace `_AddMealSheet` with upgraded version
- `lib/src/features/diet_scanner/presentation/diet_scanner_screen.dart` — close the loop: barcode → lookup → pre-fill

#### `food_search_service.dart` — Implementation Detail
```dart
// Base URL: https://world.openfoodfacts.org
// Search endpoint: /cgi/search.pl?search_terms={query}&json=1&page_size=20&fields=product_name,nutriments,image_url
// Barcode endpoint: /api/v0/product/{barcode}.json
//
// Response parsing:
//   product.nutriments["energy-kcal_100g"]
//   product.nutriments["proteins_100g"]
//   product.nutriments["carbohydrates_100g"]
//   product.nutriments["fat_100g"]
//
// Model: FoodSearchResult { name, kcalPer100g, proteinPer100g, carbsPer100g, fatPer100g, imageUrl, barcode }
// Provider: foodSearchProvider(String query) → AsyncValue<List<FoodSearchResult>>
//   - debounce 400ms using ref.debounce or manual Timer
//   - cache last 50 results in memory (LRU simple Map)
// Barcode provider: foodByBarcodeProvider(String code) → AsyncValue<FoodSearchResult?>
```

#### `_AddMealSheet` Upgrade — Exact UX Flow
1. Sheet opens → shows a **Search bar** at top with a magnifying glass icon (color: `AppColors.dynamicMint`)
2. User types → debounced 400ms → results list appears below search bar
3. Each result row: food image thumbnail (50×50, `ClipRRect` radius 10) + name + kcal/100g badge
4. Tap result → **Quantity sheet** slides up:
   - Slider from 10g to 500g (default 100g) with live macro preview updating in real time
   - Servings selector: "1 serving / 100g / custom"
   - Confirm → populates all 5 fields automatically → user just taps "Log Meal"
5. Manual entry mode still accessible via "Enter manually" text button below search results

#### Barcode Auto-Fill Close-the-Loop
- After scan in `DietScannerScreen`, instead of `context.pop()`, call `foodByBarcodeProvider`
- If found: push `_AddMealSheet` with pre-filled data + quantity selector
- If not found: show a snackbar "Product not in database — enter manually" → open blank sheet

#### Quantity Picker Widget — exact spec
```dart
// Widget: _QuantityPickerSheet
// Layout:
//   - Food name (bold 18px)
//   - Image (120×120, rounded 16, cached_network_image)
//   - Segment toggle: [Per 100g] [Per Serving] [Custom g]
//   - Animated number display: "250 g" in 36px bold mint color
//   - Slider: min=10, max=600, divisions=59 (10g steps), activeColor=dynamicMint
//   - Live macro row: 4 chips (Cal / P / C / F) updating on every slider tick
//   - "Add to [MealType]" full-width button
```

---

## 2. Feature: Sleep Detail Screen (HIGH PRIORITY)

### Problem
Sleep is the most under-built module. The dashboard shows a single number (e.g. "7h 23m") with a "Tap to log sleep" sheet. There is no dedicated screen, no trend chart, no stage breakdown, no AI insight.

### Solution: Full `/sleep` screen

**File to create:** `lib/src/features/sleep/presentation/sleep_screen.dart`
**File to create:** `lib/src/features/sleep/application/sleep_provider.dart`
**Router change:** add `/sleep` route in `app_router.dart`
**Dashboard bento:** make the sleep card tappable → `context.push('/sleep')`

#### Sleep Screen Sections (top → bottom)
1. **Hero Sleep Ring** — same ring painter style as Fasting screen
   - Shows "7h 23m" in center, ring fills based on target (8h = 100%)
   - Color: `AppColors.softIndigo` → `AppColors.purple` gradient arc
   - Subtitle: "Sleep Quality" badge (Good / Fair / Poor based on duration thresholds: 7h+ = Good, 5-7h = Fair, <5h = Poor)

2. **Date Navigator** — same `_DateNavigator` pattern from Nutrition screen, navigate past days

3. **Sleep Stage Breakdown** (if Health Connect provides stages; else show estimated)
   - 4 horizontal bars: Awake / Light / Deep / REM
   - Color coding: Awake=`AppColors.warning`, Light=`AppColors.softIndigo.withOpacity(0.5)`, Deep=`AppColors.softIndigo`, REM=`AppColors.purple`
   - Each bar: label left, animated fill bar center, duration right

4. **30-Day Sleep Trend Chart**
   - Bar chart: x=date, y=hours slept
   - Two reference lines: dashed at 7h (recommended) and 9h (max)
   - Tap a bar → tooltip shows exact hours + quality badge
   - Use `fl_chart` package (already in pubspec.yaml)

5. **Sleep Stats Row** — 3 chips in a row:
   - "Avg 7h 12m" (last 7 days)
   - "Best 9h 04m" (last 30 days)
   - "Streak 4 days" (consecutive nights ≥7h)

6. **Log Sleep Button** — same sheet as existing dashboard sleep log, but inline at the bottom of the screen (not just on dashboard)

7. **AI Sleep Insight Card** — same card style as `_WeeklyNutritionInsightCard`
   - Prompt: "User slept an average of X hours this week. Bedtime was around Xpm, wake time Xam. Provide 2-3 concrete, actionable sleep improvement tips personalized to these patterns."
   - Provider: `sleepInsightProvider` → `AsyncNotifier<String?>`

---

## 3. Feature: Progress / Analytics Screen (HIGH PRIORITY)

### Problem
`/progress` is a named route that resolves to `PlaceholderScreen`. The Weekly Overview (`/weekly`) is the only analytics surface but it's thin.

### Solution: Real Progress Screen

**File to modify:** Replace `PlaceholderScreen` binding for `/progress` in `app_router.dart`
**File to create:** `lib/src/features/progress/presentation/progress_screen.dart`

#### Screen Layout
```
AppBar: "Progress"  [time range toggle: Week | Month | 3M | All]

Section 1: "Body" tab
  - Weight trend line chart (fl_chart LineChart)
  - Body fat % line (secondary Y axis, dashed, color=purple)
  - Goal weight line (horizontal dashed, color=mint)
  - Tap point → popover tooltip with exact value + date

Section 2: "Activity" tab
  - Steps bar chart (7 bars, colors gradient mint→indigo based on goal attainment)
  - Active calories line overlay
  - Personal best highlight (star icon on tallest bar)

Section 3: "Nutrition" tab
  - Stacked bar per day: protein (red) + carbs (orange) + fat (indigo)
  - Goal line for calories
  - Tap day → macro breakdown card slides in from bottom

Section 4: "Workouts" tab
  - Frequency calendar heatmap (contribution graph style, GitHub style)
  - Green intensity = more sets/volume logged
  - Monthly workout count chip at top
  - Scroll horizontal for months

Section 5: "Habits" tab
  - Per-habit completion rate bar (horizontal)
  - Streak badge next to each
  - "Perfect day" counter (days where all habits completed)

Section 6: AI Progress Summary card (same card style)
  - Triggered on tab open, cached 24h
  - Summarizes trends across all domains
```

#### Time Range Toggle — exact implementation
```dart
// Segment control, 4 options
// enum _Range { week, month, threeMonth, all }
// StateProvider<_Range> _rangeProvider
// All chart providers take _Range as parameter and recompute slice accordingly
// Smooth AnimatedSwitcher wraps chart area, crossFadeState on range change
```

---

## 4. Feature: Water Intraday Reminders (MEDIUM PRIORITY)

### Problem
There is a `NotificationService` with `scheduleEveningNudge`. Water intake is tracked but there are no push reminders during the day to drink water.

### Solution: Smart Hydration Reminder Scheduling

**File to modify:** `lib/src/services/notification_service.dart`
**File to modify:** `lib/src/features/settings/presentation/settings_screen.dart`

#### Implementation Detail
```dart
// New method: scheduleHydrationReminders(int targetGlasses, TimeOfDay start, TimeOfDay end)
// Logic:
//   - Divide waking hours (start..end) into (targetGlasses) equal intervals
//   - Use flutter_local_notifications exactAlarmAndroidSchedule
//   - Notification title: "Time to hydrate 💧"
//   - Body: contextual — rotate through 5 messages:
//       "You're at {current}/{goal} glasses. Keep it up!"
//       "Dehydration causes fatigue. Have a glass now."
//       "Your body is ~60% water. Refuel it."
//       "A glass of water helps your metabolism."
//       "Mid-day hydration check — how are you doing?"
//   - Cancel all hydration notifications: cancelAllHydrationReminders()
//   - Notification channel ID: "hydration_reminders"
//
// Settings screen addition:
//   - Toggle: "Hydration Reminders" (bool, SharedPreferences key: "hydration_reminders_enabled")
//   - When toggled ON: show time pickers for "Wake time" and "Sleep time"
//   - Glasses selector: 6 / 8 / 10 / 12 glasses (maps to notification count)
```

---

## 5. Feature: Share / Export Workout & Progress Cards (MEDIUM PRIORITY)

### Problem
After a great workout or hitting a weight goal there's no way to share it. Fitness apps live or die by virality through share cards.

### Solution: Shareable Cards using `screenshot` + `share_plus`

**Dependencies to add to pubspec.yaml:**
```yaml
screenshot: ^3.0.0
share_plus: ^10.0.0
```

**Where to add share buttons:**
1. `WorkoutSummaryScreen` — share button in AppBar actions → generates a workout card
2. `BodyCompositionScreen` — share button when a new personal best weight is logged
3. `ProgressScreen` (new) — share button per chart tab

#### Share Card Design Spec (WorkoutSummaryScreen)
```
Card size: 1080×1920 @3x (Instagram story aspect)
Background: dark gradient (deepObsidian → charcoalCard), or brand gradient
Top: App logo mark (small, top-left) + "HealthAI" wordmark
Center: Large workout title (e.g. "Push Day A") in 48px bold white
Stats grid (2×2):
  - Duration     |  Sets Completed
  - Volume (kg)  |  Personal Bests (#)
Bottom: Date + time in small caption
Mint accent stripe at very bottom (8px)
```

#### Implementation Pattern
```dart
// Use ScreenshotController() on a RepaintBoundary widget
// _shareCard() {
//   final bytes = await screenshotController.capture(pixelRatio: 3.0);
//   final tempFile = await _saveTempFile(bytes!);
//   await Share.shareXFiles([XFile(tempFile.path)], text: 'My workout on HealthAI');
// }
```

---

## 6. Feature: Meal Plan Screen (MEDIUM PRIORITY)

### Problem
`lib/src/features/nutrition/presentation/widgets/meal_plan_card.dart` and `meal_plan_model.dart` already exist — the AI can generate 7-day meal plans — but there is no dedicated screen, just a card widget that was never wired up.

### Solution: Full `/meal-plan` Screen

**File to create:** `lib/src/features/nutrition/presentation/meal_plan_screen.dart`
**Router change:** add `/meal-plan` route

#### Screen Layout
```
AppBar: "Meal Plan" + "Generate New" button (calls AI)

Loading state: shimmer cards (3 placeholder cards), text "AI is crafting your plan..."

Content:
  - 7 horizontal day tabs: Mon Tue Wed Thu Fri Sat Sun
  - Per day: 4 meal cards (Breakfast / Lunch / Dinner / Snack)
  - Each card: meal name, macros row, prep time badge, difficulty badge
  - Card action: "Log This Meal" button → calls mealsNotifier.add() for that day

Generate flow:
  - Tap "Generate New" → bottom sheet asking:
    - Goal: [Lose Weight] [Maintain] [Gain Muscle]
    - Dietary preference: [None] [Vegetarian] [Vegan] [Keto] [Paleo]
    - Calorie target: auto-filled from user profile, editable
  - POST to HuggingFace with structured prompt requesting JSON meal plan
  - Parse with existing meal_plan_parser.dart
  - Persist plan to Isar (new MealPlanDoc collection)
```

---

## 7. Feature: Workout History / Log Screen (MEDIUM PRIORITY)

### Problem
After completing workouts the data is saved in Isar (`WorkoutDoc`) but there is no screen to browse past workout history. The Strength Charts screen shows trends but not individual session logs.

### Solution: `/workout/history` Screen

**File to create:** `lib/src/features/workout/presentation/workout_history_screen.dart`
**Router change:** add to `app_router.dart`, link from Workout Library AppBar

#### Screen Layout
```
AppBar: "Workout History"

Search bar: filter by workout name

Filter chips row: [All] [This Week] [This Month] + [muscle group chips]

List of WorkoutDoc entries, sorted newest first:
  Each row (card style, same as WorkoutPlanCard):
    - Left: colored icon based on muscle group
    - Center: Workout name, date, duration
    - Right: Sets × Reps total, volume badge
    - Tap → WorkoutSummaryScreen in view-only mode

Empty state:
  - Large barbell icon, "No workouts yet"
  - "Start your first workout" button → WorkoutLibraryScreen
```

---

## 8. UI/UX Micro-Detail Improvements

### 8.1 Dashboard Screen

**Hero Activity Rings**
- Currently: static render on load, no entrance animation for the rings themselves
- Fix: Add `AnimationController` that drives the ring arcs from 0 → value on first load, staggered by 150ms per ring
- The rings should use a shimmer glow effect (`BoxShadow` with blur=20, spread=0, color=ringColor.withOpacity(0.4)) that pulses every 3 seconds using `AnimationController.repeat(reverse: true)`

**Bento Grid cards**
- The "water" bento card — add micro wave animation inside using `CustomPainter` drawing a sine wave that scrolls horizontally. Speed proportional to current hydration level (fuller = slower, calmer wave)
- The "sleep" bento card — show moon phase icon that corresponds to sleep quality (full moon = great sleep, crescent = poor sleep)
- The "streak" bento card — add a flame particle effect using `flutter_animate` `.shimmer()` on the fire icon

**Daily Insight AI Card**
- When the insight loads, animate each word/phrase in with a 15ms stagger (typewriter feel) using `flutter_animate` `.fadeIn()` with cascading delays
- Add a subtle shimmer sweep across the card background while loading

**Bottom Navigation Bar**
- Currently uses standard icons + labels. Upgrade:
  - Selected tab icon should scale to 1.15× with a spring curve (`Curves.elasticOut`, duration 300ms)
  - Add an active indicator pill (width=32, height=4, color=dynamicMint, borderRadius=2) that slides horizontally between tabs using `AnimatedPositioned`
  - Long-press on any nav tab → haptic + show tooltip label (for accessibility)

**Pull-to-Refresh**
- Dashboard currently has no pull-to-refresh gesture. Add `RefreshIndicator` wrapping the `NestedScrollView`
- Custom refresh indicator: use `RefreshIndicator.adaptive()` with color=`AppColors.dynamicMint`
- On refresh: re-trigger `_syncHealth()` + invalidate `dailyActivityProvider` + `dailyInsightProvider`

### 8.2 Nutrition Screen

**Add Meal Sheet**
- The sheet currently opens fully — change to `DraggableScrollableSheet` with `initialChildSize: 0.6`, `maxChildSize: 0.95`, `minChildSize: 0.4`
- This allows user to peek at the sheet, see the search bar, expand to full if they want to scroll results

**Macro Progress Bars**
- Add a subtle over-budget animation: when `current > goal`, the bar should flash orange → red with a 500ms pulse (use `AnimationController.repeat(reverse: true)` for 3 pulses then stop)
- Add micro label: "Over by Xg" in red when exceeded, replacing "X / Xg"

**Meal Cards**
- Currently "No meals logged yet" is plain text. Replace with a small icon (a fork with a dashed circle) + the text, centered, with subtle dotted border around the empty state area
- Swipe-to-delete works, but add a undo snackbar: "Meal removed. Undo?" with a 3-second countdown

**Quick Add horizontal list**
- Cards are 120px wide. Add a subtle parallax effect when scrolling: cards further from center slightly scale down (0.95×) using `Transform.scale` based on scroll offset

### 8.3 Workout Player Screen

**Exercise Transition**
- Currently when moving to next exercise, the widget just rebuilds. Add a `PageView` with `PageController`, so exercises swipe in/out horizontally with a physics feel
- The transition should show the next exercise name for 0.5s before timer starts (preparation window), with a countdown "3 - 2 - 1 - GO" shown in large animated text

**Rest Timer**
- The rest countdown ring is static in appearance. Add:
  - A subtle radial gradient background pulse (ring glow expands/contracts with every second)
  - Haptic feedback at T-5s, T-3s, T-1s: `HapticFeedback.heavyImpact()` at T-3s, `HapticFeedback.mediumImpact()` at T-1s
  - Sound option (use `just_audio` or `audioplayers`): a short "ding" at T-0 when rest ends

**Set Logging**
- Tapping "Log Set" currently logs immediately. Add a spring-scale animation on the button (scale 0.92 → 1.0 → 1.05 → 1.0 over 300ms) on tap
- After logging, show a brief "+1 set" floating text that rises and fades above the button (like a damage number in games)

**Progress Header**
- "Exercise 2/6" label — add a thin horizontal progress bar below it showing overall workout progress (fill = current/total). Animate fill on each exercise advance.

### 8.4 Habits Screen

**Check-off Animation**
- Currently: checkbox toggles. Add:
  - When checking OFF: circular ripple expands outward from tap point (color = habit accent color, opacity fades 1.0 → 0 in 400ms)
  - The habit row slides 4px to the right and back (spring) when checked
  - A "confetti burst" micro-animation at the checkbox position using `flutter_animate` `.shimmer()` + scale bounce

**Streak Counter**
- Show an animated flame icon that grows taller with higher streaks (scale proportional to `min(streak/30, 1.0)`)
- At streak milestones (7, 14, 21, 30, 60, 90, 100): show a brief achievement toast modal (same pattern as existing `_showAchievementModal` on dashboard)
- Habit streak of 7+ days: add a subtle golden border to the habit card

**Empty State**
- When no habits are created: show a full illustrated empty state
  - A large custom-drawn plant/seedling icon (using `CustomPaint` or an SVG asset)
  - Text: "Plant your habits. Watch them grow."
  - CTA button: "Create your first habit" → opens AddHabit sheet

### 8.5 Fasting Screen

**Protocol Selector**
- Currently a horizontal scroll list. Add a "Recommended" badge (small mint chip) on the 16:8 card
- Show a "streak" counter per protocol: "You've completed 16:8 × 5 times" below the protocol name

**Active Fast Display**
- The live ring with elapsed time — add a breathing animation to the center text (scale 1.0 → 1.03 → 1.0 every 4 seconds using `AnimationController.repeat`)
- Add a "metabolic phase" label that changes based on fasting duration:
  - 0–4h: "Digesting"
  - 4–8h: "Post-absorptive"
  - 8–12h: "Gluconeogenesis"
  - 12–18h: "Ketosis Building"
  - 18h+: "Deep Ketosis"
- Show the current phase with an animated icon transition

**Break Fast Button**
- Currently a plain `ElevatedButton`. Upgrade:
  - Use a long-press-to-confirm pattern: user must hold for 1.5 seconds to prevent accidental stops
  - Show a radial fill animation while holding (circular progress fills around the button border)
  - Release before complete → spring back animation, button resets

### 8.6 Body Composition Screen

**Weight Entry**
- The "Log Entry" bottom sheet has manual number input. Add a drum-roll style number picker (`ListWheelScrollView`) for weight entry — much faster than typing
  - Whole numbers scroll independently from decimal (.0 / .1 / .2 ... .9)
  - Unit aware: kg (40.0–200.0) vs lbs (88–440)

**BMI Gauge**
- Currently a `CustomPainter` arc gauge. Add:
  - An animated needle that swings from the left edge to the correct position on first load
  - Color zone labels: "Underweight" / "Normal" / "Overweight" / "Obese" printed inside the colored arc zones
  - Glow effect on the needle tip (small circle, same color as BMI category, blurRadius=8)

**Trend Chart**
- Add a long-press gesture on the chart: shows a draggable vertical line cursor
- As user drags the cursor, a floating tooltip shows exact value + date
- This is the standard `fl_chart` `LineTouchData` pattern — wire it up

### 8.7 Chat Screen

**Message Bubbles**
- User bubble: currently uses a simple container. Add a gradient background (two-tone: `softIndigo` → `indigoDark`) with `ShaderMask`
- AI bubble: add a subtle animated shimmer while streaming (before the message is complete), then settle to static once done

**Suggestions**
- The suggestion chips at the bottom — add horizontal scroll momentum: after scrolling to the edge, a gradient fade appears on the trailing edge hinting more items exist

**Voice Input**
- The mic button pulses while listening. Add:
  - Real-time amplitude visualization: a row of 5 vertical bars (like an equalizer) that animate based on `_speech.onSoundLevelChange` callback
  - The bars should be mint-colored, heights driven by the `soundLevel` value from the STT package

**Empty state**
- When no messages: show the AI avatar (the circular gradient face icon) centered with a subtle floating animation (translate Y ±6px, 3-second period), and 3 suggested starter prompts as large cards (not small chips)

### 8.8 Supplement Screen

**Check-off**
- Same animation upgrade as Habits: ripple + spring bounce on check
- At end of day (11pm): push notification listing unchecked supplements: "You haven't logged Vitamin D and Omega-3 yet"

**Streak per supplement**
- Track consecutive days each supplement was taken
- Show streak badge on each supplement card (small flame icon + count)

### 8.9 Global / Cross-Screen

**Navigation transitions**
- All `context.push()` routes currently use the default `go_router` push (fade). Implement custom transitions:
  - Feature screens (Nutrition, Workout, etc.) from bottom nav: none (they're root routes, correct)
  - Detail screens (WorkoutPlayer, WorkoutSummary, etc.) pushing from a list: slide up from bottom, `SlideTransition` with `Offset(0, 1)` → `Offset(0, 0)`, curve `Curves.easeOutCubic`, duration 350ms
  - Settings, Profile: slide in from right
  - The monthly history, weekly overview: fade + scale (scale 0.94 → 1.0)

**Loading Skeleton / Shimmer**
- Any place showing `CircularProgressIndicator` should use shimmer skeleton cards instead
- Implement a `ShimmerBox` widget: `AnimatedContainer` with a gradient that sweeps left-to-right every 1.2 seconds
- Apply to: nutrition weekly insight card, chat loading, workout program generation, sleep insight card, weekly overview loading

**Error States**
- Currently many `error: (_, __) =>` handlers just show a text message
- Upgrade all error states to:
  - Icon (phosphor `warning` or `wifiSlash` depending on context)
  - Short human-readable message ("Couldn't load your insights")
  - "Try again" button that calls `ref.invalidate(provider)`

**Haptic Language** — standardize across all taps:
- Navigation push: `HapticFeedback.lightImpact()` ← already mostly done
- Destructive action (delete, break fast): `HapticFeedback.heavyImpact()`
- Toggle / checkbox: `HapticFeedback.selectionClick()` ← already done
- Achievement unlock: `HapticFeedback.vibrate()` (full vibration, 1×)
- Goal reached (calorie, water): `HapticFeedback.mediumImpact()` × 2 with 80ms gap
- Long-press confirms: `HapticFeedback.heavyImpact()` at start + end

**Dark/Light Mode Consistency**
- Several widgets hard-code `Colors.white.withOpacity(0.07)` for borders in dark mode. Consolidate to `AppColors.charcoalBorder` token everywhere
- Light mode card backgrounds should be `AppColors.lightCard` (pure white), not mixed with `Colors.white` literals
- Create a helper: `AppColors.cardColor(bool isDark)` → `isDark ? AppColors.charcoalGlass : AppColors.lightCard`
- Create: `AppColors.borderColor(bool isDark)` → `isDark ? AppColors.charcoalBorder : AppColors.lightBorder`

---

## 9. Performance Improvements

### 9.1 Isar Query Optimization
- `mealsForDateProvider` currently loads ALL meals for a date and filters in Dart. Switch to Isar `.filter().dateEqualTo(date).findAll()` using an indexed field
- `workoutHistoryProvider` (to be built) should use `.sortByDateDesc().limit(50)` — never load the full collection

### 9.2 Image Caching
- Wger exercise images use `Image.network` with no caching. Replace with `cached_network_image` package (already a transitive dep or add it)
- Open Food Facts product images: same treatment, `CachedNetworkImage` with a food-emoji placeholder

### 9.3 Provider Auto-Dispose
- Most `StateNotifierProvider` instances are global (never disposed). For screens that hold large data (chat history, workout programs), use `.autoDispose` to free memory when screen is not in the widget tree

### 9.4 Build Overhead
- `DashboardScreen` is 3228 lines — split into sub-files:
  - `dashboard_bento_grid.dart` — all bento card widgets
  - `dashboard_header.dart` — greeting, avatar, notification bell
  - `dashboard_activity_section.dart` — rings + step bar charts
  - Keep `dashboard_screen.dart` as the orchestrator only (~200 lines)

### 9.5 Font Loading
- Ensure `Poppins` (or whatever font is declared in pubspec) is loaded at splash, not deferred. Use `FontLoader` pre-cache in `main.dart` before `runApp()`

---

## 10. Accessibility Improvements

- All icon-only buttons (the "+" in Nutrition, the mic button in Chat) need `Semantics(label: 'Add meal')` wrappers
- Macro progress bars need `Semantics(value: '$current of $goal $unit', label: '$label progress')`
- Minimum tap target 48×48px — audit all small icon buttons (the 32×32 ones in meal sections are below threshold — increase to 44×44 with padding)
- High contrast mode: check that `AppColors.dynamicMint` on `AppColors.charcoalGlass` meets WCAG AA (4.5:1). Current ratio: ~5.2:1 ✅. Check mint on white (light mode): ratio ~3.1:1 ⚠️ — slightly below. Darken mint in light mode: use `AppColors.mintDark` (`0xFF00A88D`) for text on white backgrounds
- All charts need `ExcludeSemantics` wrappers with a sibling `Semantics(label: 'Chart: [human readable description]')` for screen reader users

---

## 11. Tech Debt to Clean Up

| Item | Location | Fix |
|---|---|---|
| `DISTANCE_WALKING_RUNNING` crash on Health Connect | `health_service.dart` | Filter out unsupported types per platform (already fixed this session) |
| `_showAddMealSheet` defined on `_NutritionScreenState` but passed as a callback deep into child widgets | `nutrition_screen.dart` | Move to a standalone function or use `ref.read` inside the sheet |
| `DashboardScreen` has unused `_buildWeeklySummaryBento` method (line 2782, flagged by analyzer) | `dashboard_screen.dart` | Remove dead code |
| 200 analyzer warnings (`prefer_const_constructors`) | All files | Run `dart fix --apply` to auto-fix all |
| Hard-coded HuggingFace token | Likely in `chat_controller.dart` or env | Move to `--dart-define` or `.env` file, never commit keys |
| `getByIndex` experimental API warning in Isar | `local_db_service.dart` or similar | Switch to stable `.get(id)` or `.where().idEqualTo(id).findFirst()` |

---

## 12. Implementation Priority Order

```
Phase 1 (Core Value — Do First):
  [1] Food Search + Barcode Auto-Fill    → Nutrition daily friction removed
  [2] Sleep Detail Screen                → Major missing module filled
  [3] Progress / Analytics Screen        → /progress placeholder removed

Phase 2 (Engagement + Polish):
  [4] Dashboard UI micro-animations      → First impression upgrade
  [5] Workout Player UX polish           → Timer haptics, transitions, floating "+1"
  [6] Habits check-off animation         → Delight on daily use
  [7] Share / Export Cards               → Virality surface

Phase 3 (Completeness):
  [8] Meal Plan Screen wiring            → Existing code already 80% done
  [9] Workout History Screen             → Data exists, needs a view
  [10] Water intraday notifications      → Background engagement
  [11] Supplement streak tracking        → Small but satisfying
  [12] Tech debt / accessibility pass    → Stability
```

---

## 13. New Dependencies Needed

| Package | Version | Purpose |
|---|---|---|
| `cached_network_image` | ^3.4.0 | Cache food/exercise images |
| `screenshot` | ^3.0.0 | Capture share cards |
| `share_plus` | ^10.0.0 | Native share sheet |
| `http` | already present | Open Food Facts API (reuse) |

All other features (charts, animations, notifications, speech-to-text) use packages already in `pubspec.yaml`.

---

*End of plan. Total estimated new screens: 3. Total files modified: ~15. Total new files: ~8.*
