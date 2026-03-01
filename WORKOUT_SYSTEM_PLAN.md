# HealthAI — Full Workout Feature System Plan

> Complete blueprint: architecture, libraries, data flow, UI/UX, animations, AI integration, and execution order.

---

## 1. Vision & Scope

Build a **premium, fully functional workout system** with two modes:

| Mode | Equipment | Animation Style |
|------|-----------|-----------------|
| **Home Workout** | Bodyweight / minimal gear | Lottie GIF loops (LottieFiles) |
| **Gym Workout** | Full equipment | Cached GIF from ExerciseDB + form cues |

### Core User Flows

```
Chat AI → Generates Plan → Plan Preview Screen
                               │
                    ┌──────────┴──────────┐
                    ▼                     ▼
              Save Workout          Start Workout
             (Isar / Favourites)         │
                                   Active Workout Screen
                                    ├─ Exercise card with GIF/animation
                                    ├─ Set logger (weight × reps)
                                    ├─ Rest timer (customisable)
                                    ├─ Next exercise preview
                                    └─ Finish → Summary screen
```

---

## 2. Package Dependencies

Add these to `pubspec.yaml`:

```yaml
dependencies:
  # Animation
  lottie: ^3.1.2                    # Exercise loop animations (home workout)
  rive: ^0.13.17                    # Interactive avatar (optional premium layer)
  cached_network_image: ^3.4.1      # Cache ExerciseDB GIFs (gym workout)

  # HTTP already present (for ExerciseDB API)
  http: ^1.2.0                      # already in project

  # UI helpers
  flutter_staggered_animations: ^1.1.1   # Staggered list entry animations
  percent_indicator: ^4.2.3              # Circular + linear set progress
  
  # Already present — no new install needed:
  # flutter_riverpod, isar, isar_flutter_libs, flutter_animate,
  # phosphor_flutter, go_router, flutter_dotenv
```

**Install command:**
```bash
flutter pub add lottie rive cached_network_image flutter_staggered_animations percent_indicator
flutter pub get
```

---

## 3. Exercise Data Strategy

### 3a. ExerciseDB V1 (Gym Mode — GIFs)

- **Source**: https://github.com/yuhonas/free-exercise-db (Public Domain / Unlicense)
- **Media proxy**: `https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/[Name]/0.jpg`
- **Why**: 800+ exercises, free, no API key, GIF animations, JSON metadata, offline-bundleable
- **Fallback**: RapidAPI ExerciseDB V2 free tier (500 req/month — for demo only)

Sample exercise JSON structure (embed in app as asset):
```json
{
  "id": "0001",
  "name": "Barbell Bench Press",
  "force": "push",
  "level": "intermediate",
  "mechanic": "compound",
  "equipment": "barbell",
  "primaryMuscles": ["chest"],
  "secondaryMuscles": ["shoulders", "triceps"],
  "instructions": [
    "Lie flat on a bench.",
    "Grip the barbell slightly wider than shoulder-width.",
    "Lower to chest, then press explosively."
  ],
  "category": "strength",
  "gifUrl": "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/BarbellBenchPress/0.jpg"
}
```

**Implementation**: Download the JSON file from the repo and bundle it as `assets/data/exercises.json`. Parse once at app start into a Riverpod provider.

### 3b. Lottie Animations (Home Mode)

- **Source**: https://lottiefiles.com/free-animations/exercise (free with LottieFiles account)
- Download and bundle as `assets/animations/`:
  - `pushup.json`
  - `squat.json`
  - `jumping_jacks.json`
  - `plank.json`
  - `lunge.json`
  - `burpee.json`
  - `mountain_climber.json`
  - `rest.json` (breathing animation for rest timer)
- Map exercise name → Lottie asset key in a Dart constant map.

### 3c. Fallback

If no GIF / Lottie available → show a muscle diagram SVG with highlighted target muscles (static, bundled).

---

## 4. Data Models (Isar)

### Extend `workout_doc.dart`

```dart
@collection
class WorkoutPlanDoc {
  Id id = Isar.autoIncrement;
  
  late String title;           // "AI Push Day", "Home HIIT"
  late DateTime createdAt;
  String source = 'ai';        // 'ai' | 'preset' | 'custom'
  String mode = 'gym';         // 'gym' | 'home'
  bool isFavourite = false;
  String? aiSummary;           // AI-generated description
  
  List<PlannedExercise> exercises = [];
}

@embedded
class PlannedExercise {
  String exerciseId = '';      // maps to ExerciseDB id
  String name = '';
  int sets = 3;
  int reps = 12;
  int restSeconds = 60;
  String notes = '';
}

// Existing WorkoutDoc stays for completed session logs
// Add field to link back:
// String? planId  — links which plan this session used
```

Run `flutter pub run build_runner build --delete-conflicting-outputs` after modifying.

---

## 5. Riverpod Providers Architecture

```
lib/src/features/workout/
├── application/
│   ├── workout_controller.dart          # EXISTING — active session
│   ├── workout_plan_controller.dart     # NEW — saved plans CRUD
│   ├── exercise_db_provider.dart        # NEW — loads exercises.json asset
│   └── workout_favourites_provider.dart # NEW — favourite plans
├── domain/
│   ├── exercise_model.dart              # NEW — Dart model for ExerciseDB JSON
│   └── workout_plan_model.dart          # NEW — Dart model for AI-generated plans
└── presentation/
    ├── workout_home_screen.dart         # NEW — tab: My Plans + Start options
    ├── workout_plan_preview_screen.dart # NEW — AI plan review, save, start
    ├── workout_player_screen.dart       # EXISTING — extend significantly
    ├── workout_summary_screen.dart      # NEW — post-workout stats
    └── widgets/
        ├── exercise_card.dart           # NEW — GIF + info card
        ├── set_logger_row.dart          # NEW — weight/reps input row
        ├── rest_timer_widget.dart       # NEW — animated rest countdown
        ├── exercise_animation_widget.dart # NEW — Lottie / CachedNetworkImage
        └── plan_card.dart               # NEW — saved plan tile
```

### Key Providers

```dart
// exercise_db_provider.dart
final exerciseDbProvider = FutureProvider<List<ExerciseModel>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/exercises.json');
  final list = jsonDecode(jsonStr) as List;
  return list.map(ExerciseModel.fromJson).toList();
});

final exerciseByIdProvider = Provider.family<ExerciseModel?, String>((ref, id) {
  final db = ref.watch(exerciseDbProvider).valueOrNull ?? [];
  return db.firstWhereOrNull((e) => e.id == id);
});

// workout_plan_controller.dart
final savedPlansProvider = StreamProvider<List<WorkoutPlanDoc>>((ref) {
  return ref.watch(isarProvider).workoutPlanDocs
    .where().sortByCreatedAtDesc().watch(fireImmediately: true);
});

final favouritePlansProvider = StreamProvider<List<WorkoutPlanDoc>>((ref) {
  return ref.watch(isarProvider).workoutPlanDocs
    .filter().isFavouriteEqualTo(true).watch(fireImmediately: true);
});
```

---

## 6. AI Chat → Workout Plan Integration

### How It Works

1. User chats with AI coach → asks for workout plan
2. AI generates a structured response (Markdown + JSON block)
3. Chat controller detects a workout plan response (looks for ````workout_plan` code fence)
4. A **"Start Workout"** and **"Save Plan"** action bar appears inline in the chat bubble
5. Tapping "Start Workout" → parses the JSON → pushes to `WorkoutPlayerScreen` with the plan
6. Tapping "Save Plan" → saves to Isar `WorkoutPlanDoc` → shows confirmation snackbar

### AI Prompt Enhancement (add to system prompt)

When the user has provided enough profiling data and asks for a workout plan, append this instruction:

```
When generating a workout plan, you MUST output:
1. A brief human-readable summary paragraph.
2. THEN a JSON code block formatted EXACTLY like this:

\`\`\`workout_plan
{
  "title": "3-Day Push/Pull/Legs",
  "mode": "gym",
  "days": [
    {
      "day": "Day 1 - Push",
      "exercises": [
        { "name": "Barbell Bench Press", "sets": 4, "reps": 8, "rest_seconds": 90 },
        { "name": "Overhead Press", "sets": 3, "reps": 10, "rest_seconds": 75 },
        { "name": "Tricep Pushdown", "sets": 3, "reps": 12, "rest_seconds": 60 }
      ]
    }
  ]
}
\`\`\`
```

### Parsing Logic (in `chat_controller.dart`)

```dart
WorkoutPlanData? _extractWorkoutPlan(String responseText) {
  final regex = RegExp(r'```workout_plan\s*([\s\S]*?)```');
  final match = regex.firstMatch(responseText);
  if (match == null) return null;
  try {
    final json = jsonDecode(match.group(1)!);
    return WorkoutPlanData.fromJson(json);
  } catch (_) {
    return null;
  }
}
```

---

## 7. Screen-by-Screen Design

### 7a. Workout Home Screen (replaces placeholder)

**Layout:**
```
┌─────────────────────────────────────┐
│  [Back]    Workouts         [Filter] │  ← AppBar
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐ │
│  │  🏠 Home    🏋️ Gym             │ │  ← Mode toggle (segmented)
│  └─────────────────────────────────┘ │
│                                     │
│  ⭐ Favourites                       │
│  ┌──────┐ ┌──────┐ ┌──────┐        │  ← Horizontal scroll cards
│  │Push  │ │HIIT  │ │Arms  │ ...     │
│  └──────┘ └──────┘ └──────┘        │
│                                     │
│  📋 My Plans (x)                    │
│  ┌─────────────────────────────────┐ │
│  │ 💬 AI Generated · Push Day      │ │
│  │ 6 exercises · 45 min · Gym      │ │  ← Plan cards
│  │ [Preview]              [Start →]│ │
│  └─────────────────────────────────┘ │
│  ┌─────────────────────────────────┐ │
│  │ 🏠 Preset · Full Body HIIT      │ │
│  │ 8 exercises · 30 min · Home     │ │
│  └─────────────────────────────────┘ │
│                                     │
│  + Create with AI Coach             │  ← Button → opens Chat
└─────────────────────────────────────┘
```

### 7b. Workout Plan Preview Screen

Displayed when user taps a plan card OR when AI generates a plan in chat.

```
┌─────────────────────────────────────┐
│ [←]    Push Day Plan       [♡] [⋯]  │
├─────────────────────────────────────┤
│  AI Summary paragraph...            │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │ 6 exercises  │ ~45 min │ Gym    │ │  ← Info pills
│  └─────────────────────────────────┘ │
│                                     │
│  Exercise 1 ──────────────────────  │
│  ┌────┬──────────────────────────┐  │
│  │[GIF│ Barbell Bench Press      │  │
│  │/   │ Chest · Compound · 4×8   │  │  ← Expandable exercise cards
│  │Lot │ ▼ See instructions       │  │
│  │tie]│                          │  │
│  └────┴──────────────────────────┘  │
│                                     │
│  Exercise 2 ...                     │
│                                     │
│  ┌─────────────────────────────────┐ │
│  │  [♡ Save Plan]  [▶ Start Now]   │ │  ← Action bar (sticky bottom)
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 7c. Active Workout Player Screen (upgraded)

The existing `workout_player_screen.dart` extended with:

**Header section:**
- Workout title + elapsed timer (existing ✓)
- Exercise progress: "Exercise 2 of 6"

**Exercise animation zone (NEW — replaces static ring during active exercise):**
```
┌──────────────────────────────────┐
│  GYM MODE:                       │
│  [Cached GIF from ExerciseDB]    │  280×280 rounded card
│  "Barbell Bench Press"           │
│  "Keep elbows at 45°" (form tip) │
│                                  │
│  HOME MODE:                      │
│  [Lottie animation loop]         │  280×280
│  "Push-up" · 45 sec remaining    │
└──────────────────────────────────┘
```

**Sets section (existing, enhanced):**
- Interactive weight/reps text fields (not just display)
- Previous set reference (last session)
- Haptic on completion

**Next exercise preview strip:**
```
┌──────────────────────────────────┐
│  Up next: Overhead Press →       │
│  [thumbnail] 3 sets × 10 reps   │
└──────────────────────────────────┘
```

**Rest timer (existing, enhanced):**
- Custom Lottie breathing animation during rest
- Audio/haptic cue when rest ends
- Skip / +15s / -15s controls

**Bottom bar (existing, extended):**
- Add Exercise button
- Rest Timer
- Finish Workout

### 7d. Workout Summary Screen (NEW)

Post-workout screen shown after "Finish Workout":

```
┌─────────────────────────────────────┐
│       🎉 Workout Complete!           │
│                                     │
│   Duration: 47:23                   │
│   Volume: 4,200 kg                  │  ← Total weight moved
│   Sets: 18 completed                │
│   Personal Records: 2 🏆            │
│                                     │
│   [Exercise breakdown list]         │
│   Bench Press: 4×8 @ 80kg          │
│   OHP:         3×10 @ 50kg          │
│   ...                               │
│                                     │
│  [ Share ]   [ Save & Exit ]       │
└─────────────────────────────────────┘
```

---

## 8. Exercise Animation Widget

### `exercise_animation_widget.dart`

```dart
class ExerciseAnimationWidget extends StatelessWidget {
  final String exerciseName;
  final String? gifUrl;          // from ExerciseDB (gym)
  final String? lottieAsset;     // bundled asset path (home)
  final bool isResting;

  const ExerciseAnimationWidget({
    super.key,
    required this.exerciseName,
    this.gifUrl,
    this.lottieAsset,
    this.isResting = false,
  });

  @override
  Widget build(BuildContext context) {
    // Priority: lottie asset > cached gif > placeholder
    if (isResting) {
      return Lottie.asset('assets/animations/rest.json',
          width: 280, height: 280, repeat: true);
    }
    if (lottieAsset != null) {
      return Lottie.asset(lottieAsset!,
          width: 280, height: 280, repeat: true,
          addRepaintBoundary: true);
    }
    if (gifUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: gifUrl!,
          width: 280,
          height: 280,
          fit: BoxFit.cover,
          placeholder: (_, __) => const _AnimationShimmer(),
          errorWidget: (_, __, ___) => const _ExercisePlaceholder(),
        ),
      );
    }
    return const _ExercisePlaceholder();
  }
}
```

### Lottie → Exercise Name Mapping

```dart
const Map<String, String> kExerciseLottieMap = {
  'push-up': 'assets/animations/pushup.json',
  'push up': 'assets/animations/pushup.json',
  'squat': 'assets/animations/squat.json',
  'plank': 'assets/animations/plank.json',
  'burpee': 'assets/animations/burpee.json',
  'jumping jack': 'assets/animations/jumping_jacks.json',
  'lunge': 'assets/animations/lunge.json',
  'mountain climber': 'assets/animations/mountain_climber.json',
};

String? lottieForExercise(String name) {
  final lower = name.toLowerCase();
  for (final entry in kExerciseLottieMap.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return null;
}
```

---

## 9. Rest Timer Widget (Enhanced)

```dart
class RestTimerWidget extends ConsumerStatefulWidget {
  final int initialSeconds;
  final VoidCallback onComplete;
  
  // Features:
  // - Circular countdown arc (CustomPainter)
  // - Breathing Lottie animation behind the ring
  // - +15s / Skip buttons
  // - HapticFeedback.heavyImpact() at 3, 2, 1 seconds
  // - Background color pulse (mint → deep obsidian)
}
```

Rest time presets by exercise type:
```dart
int defaultRestFor(String category) {
  return switch (category) {
    'strength'  => 90,  // compound lifts
    'isolation' => 60,  // single-muscle
    'hiit'      => 30,
    'cardio'    => 20,
    _           => 60,
  };
}
```

---

## 10. Workout Plan Controller (Isar CRUD)

```dart
// lib/src/features/workout/application/workout_plan_controller.dart

@riverpod
class WorkoutPlanController extends _$WorkoutPlanController {
  // Save AI-generated plan
  Future<WorkoutPlanDoc> savePlan(WorkoutPlanData data) async { ... }
  
  // Toggle favourite
  Future<void> toggleFavourite(int planId) async { ... }
  
  // Delete plan
  Future<void> deletePlan(int planId) async { ... }
  
  // Start workout from a plan → populates activeWorkoutProvider
  void startFromPlan(WorkoutPlanDoc plan) {
    ref.read(activeWorkoutProvider.notifier).startFromPlan(plan);
  }
}
```

---

## 11. Execution Order (Step-by-Step Implementation)

### Phase 1 — Foundation (Data & Models)

1. Add packages to `pubspec.yaml` → `flutter pub get`
2. Run `build_runner` to regenerate Isar schemas with `WorkoutPlanDoc`
3. Download `exercises.json` from `free-exercise-db` → place in `assets/data/`
4. Download Lottie files from LottieFiles → place in `assets/animations/`
5. Register new asset paths in `pubspec.yaml` flutter.assets section
6. Create `ExerciseModel` + `WorkoutPlanModel` domain models
7. Create `ExerciseDbProvider` (loads JSON asset)

### Phase 2 — AI Integration

8. Update system prompt in `gemini_service.dart` with workout JSON format
9. Add `_extractWorkoutPlan()` parser in `chat_controller.dart`
10. Add `workoutPlanProvider` notifier state to `ChatSessionDoc` (transient, not saved)
11. Build `WorkoutPlanActionBar` widget (save / start buttons in chat)
12. Wire "Start Workout" → navigate to `WorkoutPlayerScreen` with plan data

### Phase 3 — Player Screen Upgrade

13. Extend `WorkoutDoc` / `WorkoutController.startWorkout()` to accept full plan
14. Build `ExerciseAnimationWidget`
15. Build `RestTimerWidget` (with Lottie + haptics)
16. Upgrade `workout_player_screen.dart`:
    - Replace static ring with `ExerciseAnimationWidget`
    - Add exercise navigation (prev/next)
    - Add interactive `SetLoggerRow` with `TextField`
    - Add "Next Exercise" preview strip
    - Add form cue tooltip

### Phase 4 — Workout Home & Preview

17. Build `WorkoutPlanPreviewScreen`
18. Build `WorkoutHomeScreen` (tabs, favourites, saved plans list)
19. Register new routes in `go_router`
20. Build `WorkoutSummaryScreen`
21. Wire up end workout → show summary → save to Isar log

### Phase 5 — Polish

22. Add `flutter_staggered_animations` to all list entries
23. Add `percent_indicator` for exercise progress bar in player header
24. Add shimmer placeholders for GIF loading
25. Run `flutter analyze` + fix all warnings
26. Test on device: end-to-end flow (chat → plan → player → summary)

---

## 12. Assets to Download / Create

### From LottieFiles (free, requires free account)
Search at https://lottiefiles.com/free-animations/exercise

| File | Search term | Usage |
|------|------------|-------|
| `pushup.json` | "push up exercise" | Home push-up |
| `squat.json` | "squat workout" | Home squat |
| `plank.json` | "plank fitness" | Home plank |
| `burpee.json` | "burpee" | Home burpee |
| `jumping_jacks.json` | "jumping jacks" | Home JJ |
| `lunge.json` | "lunge exercise" | Home lunge |
| `mountain_climber.json` | "mountain climber" | Home MC |
| `rest.json` | "breathing meditation" | Rest timer bg |
| `workout_complete.json` | "trophy celebration" | Summary screen |
| `heartbeat.json` | "heart pulse" | Live stats |

### From free-exercise-db (GitHub)
Download `exercises.json` from:  
`https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json`

Place at: `assets/data/exercises.json`

---

## 13. Router Updates

```dart
// In router config, add:
GoRoute(
  path: '/workout/plans',
  builder: (_, __) => const WorkoutHomeScreen(),
),
GoRoute(
  path: '/workout/preview',
  builder: (_, state) => WorkoutPlanPreviewScreen(
    plan: state.extra as WorkoutPlanDoc,
  ),
),
GoRoute(
  path: '/workout/player',
  builder: (_, __) => const WorkoutPlayerScreen(),
),
GoRoute(
  path: '/workout/summary',
  builder: (_, state) => WorkoutSummaryScreen(
    session: state.extra as WorkoutDoc,
  ),
),
```

---

## 14. UI/UX Design Tokens

Consistent with existing app theme (`app_colors.dart`):

| Element | Color / Style |
|---------|--------------|
| Active exercise card | `AppColors.dynamicMint` border + glow |
| Rest state | `AppColors.softIndigo` background pulse |
| Completed set | `dynamicMint` fill + black checkmark |
| Favourite star | `Color(0xFFFFCC00)` |
| Gym mode badge | Gradient: softIndigo → dynamicMint |
| Home mode badge | Gradient: `0xFF48CAE4` → `0xFF00B4D8` |
| Summary records | `Color(0xFFFFAC33)` (gold) |
| Animation bg | `Color(0xFF0D0F14)` card on `Colors.black` scaffold |

Typography:
- Exercise name: `fontSize: 20, fontWeight: w700, letterSpacing: -0.3`
- Set number: `fontSize: 17, fontWeight: w600, color: dynamicMint`
- Instructions: `fontSize: 13, height: 1.6, color: white70`

---

## 15. Key Technical Notes

1. **Isar schema change**: Adding `WorkoutPlanDoc` requires re-running `build_runner`. Delete the Isar DB file on device for clean schema migration during dev.

2. **GIF caching**: `CachedNetworkImage` stores GIFs in app cache directory. For offline-first, pre-cache the top 20 most common gym exercises on first launch.

3. **Lottie performance**: Always set `addRepaintBoundary: true`. Pause animations when off-screen using `LottieBuilder`'s `controller` param.

4. **Text input in active workout**: `TextEditingController` per set row. Use `FocusNode` with `onFieldSubmitted` to auto-advance to next row.

5. **State persistence across navigation**: `activeWorkoutProvider` is a `NotifierProvider` — it persists in memory across routes. Do NOT use `autoDispose` on it.

6. **AI plan parsing robustness**: The regex parser should handle: leading/trailing whitespace, lowercase/uppercase key names, missing optional fields (default to sensible values).

7. **Build runner after model changes**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
