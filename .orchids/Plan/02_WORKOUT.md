# Workout System — Detailed Plan
> Features: `/workout/preview`, `/workout`, Chat workout cards  
> Models: `WorkoutPlanDoc`, `WorkoutDoc`, `WorkoutExercise`, `WorkoutSetDoc`  
> Services: `WgerService`, `WorkoutController`, `WorkoutPlanController`

---

## Vision

The workout feature is the deepest, most complex part of the app. The current implementation (AI-generated plans → preview → player → log) is just the surface. The full vision is:

> A complete personal training system: AI-generated programs, manual workout builder, exercise library, rep/set logging, progressive overload tracking, strength charts, body analytics, and adaptive program adjustments.

---

## Current State

### What works
- AI chat generates a workout plan → JSON parsed → `WorkoutPlanData`
- Plan preview screen shows days, exercises, wger illustrations with animation
- Workout player: set logging, rest timer, exercise navigation, workout timer
- Plans can be saved to Isar as `WorkoutPlanDoc`
- `WorkoutDoc` written to Isar on `endWorkout()`

### Critical bugs / gaps right now
- **Dashboard "Workout" button** pushes `/workout` with `null planDoc` — undefined behavior
- **Workout end** adds hardcoded `+45 minutes` to exercise time regardless of actual session duration
- **No workout history screen** — `WorkoutDoc`s accumulate in Isar but are never displayed
- **No workout library** — saved `WorkoutPlanDoc`s have no browse screen
- **No exercise library** — user can't search or browse exercises manually
- **wger illustrations sometimes blank** — no loading skeleton shown during fetch

---

## Phase 1 — Fix Bugs + Core Missing Screens

### 1.1 Fix workout end bug
In `WorkoutController.endWorkout()`:
```dart
// Replace hardcoded:
dailyState.exerciseCompletedMinutes += 45;

// With actual elapsed time:
final elapsedMinutes = state!.durationSeconds ~/ 60;
dailyState.exerciseCompletedMinutes += elapsedMinutes;
```
Also calculate `caloriesBurned` estimate: `elapsedMinutes * 7` (approx 7 kcal/min moderate workout) and call `addCaloriesBurned()`.

### 1.2 Fix Dashboard "Workout" button
Change dashboard quick action to push a new **Workout Home** screen (see 1.3), not directly to the player.

### 1.3 Build Workout Home / Library screen (`/workout/library`)
A new screen that is the entry point to all workout functionality:

**Sections:**
- **Resume** — if `activeWorkoutProvider != null`, show "Resume [Plan Name]" card at top
- **My Plans** — horizontal scrollable list of saved `WorkoutPlanDoc`s
  - Each card: plan name, days per week, last completed, "Start" button
  - "+" button → opens AI chat with pre-filled "Create a workout plan"
- **Recent Workouts** — vertical list of past `WorkoutDoc`s from Isar
  - Date, duration, exercise count, total volume (sum of weight × reps)
- **Browse Templates** — pre-built static plans (PPL, Full Body, HIIT, etc.)

Add `/workout/library` to `app_router.dart` as a shell branch tab or a dedicated route.

### 1.4 Workout History screen (`/workout/history`)
A scrollable history of completed `WorkoutDoc`s:
- Grouped by week
- Each entry: date, plan name, duration, exercises list, total volume
- Tap → expand full exercise breakdown with sets/reps/weight
- Pull-to-refresh

### 1.5 wger image loading state
In `WgerExerciseWidget`, add a `shimmer` or skeleton placeholder while the `FutureProvider` is loading. Currently shows nothing for 1-2 seconds on first load.

---

## Phase 2 — Exercise Library

### 2.1 Exercise library screen (`/exercise/library`)
Full-screen searchable exercise database:
- Source: `assets/data/exercises.json` (already has 800+ exercises) + wger API
- Search bar at top
- Filter by: muscle group, equipment, difficulty, bodyweight/gym
- Each result card: exercise name, muscle group badge, wger illustration thumbnail
- Tap → Exercise Detail screen

### 2.2 Exercise detail screen
- Full wger illustration (animated if multiple images)
- Muscle map showing primary + secondary muscles
- Exercise description / form cues
- Set/rep recommendations by experience level
- "Add to current workout" button
- "Log a set" button

### 2.3 Add exercise to active workout
From the player screen: "Add Exercise" button at bottom → opens exercise library in picker mode → tap to add to current session.

---

## Phase 3 — Progressive Overload & Strength Tracking

### 3.1 Rep/weight history per exercise
When user logs a set in the player, also look up their **last session** for that same exercise:
- Show previous weight/reps as ghost text in the input field
- Show "↑ 2.5kg from last time" badge when they beat their record

### 3.2 Personal Records (PRs)
Track `1RM estimate` per exercise using Epley formula: `weight × (1 + reps/30)`
- Store PRs in Isar as a new `ExercisePRDoc` collection
- Show PR badge in the player when a new record is set
- Profile screen: "PRs" section listing top 5 lifts

### 3.3 Volume tracking
Per workout: `totalVolume = sum(weight × reps)` across all sets
Store on `WorkoutDoc.totalVolume`
Chart: weekly volume per muscle group

### 3.4 Strength charts (`/workout/progress`)
A charts screen showing:
- Weight over time for any tracked exercise (line chart)
- Weekly volume bar chart (by muscle group)
- Estimated 1RM trend
- Built with `fl_chart` package

---

## Phase 4 — Program Design & Adaptation

### 4.1 Workout programs (multi-week plans)
A new `WorkoutProgramDoc` model:
```
Program {
  name, goal, weeksTotal,
  weeks: [{ weekNumber, days: [WorkoutPlanDoc] }]
}
```
AI generates an 8-week periodized program instead of a single week plan.

### 4.2 AI adaptive adjustments
After week 2: AI analyzes `WorkoutDoc` history and suggests:
- "You're progressing well on bench — increase by 5kg next week"
- "You've skipped leg day 3 times — want to reschedule?"

### 4.3 Pre-built template programs
Ship with 5 static programs baked into the app:
1. **PPL (Push Pull Legs)** — 6 days, gym
2. **5×5 Strength** — 3 days, gym
3. **Home HIIT** — 4 days, bodyweight
4. **Full Body Beginner** — 3 days, minimal equipment
5. **Marathon Prep Running** — 5 days

### 4.4 Body metrics integration
Log body weight weekly → show on strength chart → calculate estimated body fat % (Navy method or simple BMI-adjusted).

---

## Phase 5 — Advanced (Post-Beta)

- Wearable sync (Apple Watch / Garmin) for heart rate zones during workout
- Video form check: upload video → AI analyzes form using vision
- Social: share workout achievements
- Coach marketplace: human coaches reviewing AI plans
- Workout music integration (Spotify SDK)

---

## Implementation Priority

| Task | Priority | Effort |
|---|---|---|
| Fix workout end calories/minutes bug | Critical | Tiny |
| Fix dashboard workout button | Critical | Tiny |
| wger image loading skeleton | High | Small |
| Workout library/home screen | High | Medium |
| Workout history screen | High | Medium |
| Exercise library (search + filter) | High | Large |
| Last-session ghost text in player | Medium | Small |
| Personal records tracking | Medium | Medium |
| Strength charts | Medium | Large |
| Multi-week programs | Low | Large |
| AI adaptive adjustments | Low | Large |

---

## Data Model Changes Needed

### New: `ExercisePRDoc`
```dart
@collection
class ExercisePRDoc {
  Id id = Isar.autoIncrement;
  late String exerciseName;
  double maxWeightKg = 0;
  int maxReps = 0;
  double estimated1RMKg = 0;
  late DateTime achievedAt;
}
```

### Update: `WorkoutDoc`
```dart
// Add:
int totalVolumeKg = 0;
String? planTitle;
```

### New: `WorkoutProgramDoc`
```dart
@collection
class WorkoutProgramDoc {
  Id id = Isar.autoIncrement;
  late String name;
  late String goal;
  int weeksTotal = 8;
  int currentWeek = 1;
  late DateTime startedAt;
  List<String> planIds = []; // references to WorkoutPlanDoc ids
}
```
