# Habits — Detailed Plan
> Feature: `/habits` | `HabitsScreen`  
> Model: `HabitDoc` (exists but NEVER used)

---

## Vision

> A smart daily habit system that remembers what you've done, calculates real streaks, adapts to your schedule, and uses AI to suggest new habits based on your health goals.

---

## Current State

### What works
- Beautiful habit cards with progress rings, icons, colors
- Toggle complete (in-memory)
- Swipe-to-delete (in-memory)
- Add new habit by name (in-memory)
- Date strip navigation (UI only)
- Progress summary card
- Animated check states

### What's broken / dummy
- **NOT PERSISTED** — `_habitsProvider` is a file-local `StateNotifierProvider` — all habits reset on every app cold start
- **`HabitDoc` Isar model exists but is never used**
- **Date strip has no effect** — same habits on every day
- **Streak is hardcoded** as "12 Days" — no calculation
- **Gemini Insight** is hardcoded static string
- **No habit editing** after creation (icon, color, target, schedule)

---

## Phase 1 — Make Habits Real (Persistence)

This is the most critical fix for Habits. Currently the entire feature is cosmetically working but loses all data on restart.

### 1.1 Wire `HabitDoc` Isar model

Create a real `habitProvider`:
```dart
// lib/src/features/habits/application/habit_provider.dart
final habitsProvider = NotifierProvider<HabitsNotifier, List<HabitDoc>>(HabitsNotifier.new);

class HabitsNotifier extends Notifier<List<HabitDoc>> {
  @override
  List<HabitDoc> build() {
    _load();
    return [];
  }
  void _load() async {
    final habits = await ref.read(isarProvider).habitDocs.where().findAll();
    state = habits;
  }
  // add / toggle / delete with isar writeTxn
}
```

### 1.2 Update `HabitDoc` schema for completions
The existing `HabitDoc` needs a completion history field:
```dart
// Update HabitDoc:
List<DateTime> completedDates = []; // track each day completed
int targetPerWeek = 7; // daily by default
String iconName = 'target'; // icon identifier
int colorValue = 0xFF6366F1; // stored as int
```

### 1.3 Per-day habit completion
The date strip must actually filter completions:
- When user taps a day, show which habits were completed/pending on THAT day
- Toggle on a past day → adds/removes from `completedDates`
- Persists to Isar

### 1.4 Real streak calculation
```dart
int calculateStreak(HabitDoc habit) {
  int streak = 0;
  DateTime day = DateTime.now();
  while (habit.completedDates.any((d) => isSameDay(d, day))) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}
```
Show this in the streak card — real number from real data.

---

## Phase 2 — Habit Creation & Editing

### 2.1 Enhanced add habit sheet
Current: only name text field.  
Enhanced:
- Name (text field)
- Icon selector (grid of ~20 icons with categories: Health, Fitness, Mind, Lifestyle)
- Color picker (8 preset colors)
- Target frequency: Daily / X times per week / X times per month
- Reminder time (optional) — shows time picker
- Category tag: Fitness / Nutrition / Mental / Sleep / Productivity

### 2.2 Habit edit screen
Long-press on habit card → show edit option (alongside existing delete):
- Opens same sheet pre-filled with current values
- Save updates the `HabitDoc` in Isar

### 2.3 Habit categories
Group habits on the screen by category with sticky section headers:
```
FITNESS
  [Workout 3x/week] [10k Steps]
MENTAL  
  [Meditation] [Journaling]
```
Can be collapsed/expanded.

---

## Phase 3 — Smart Habits

### 3.1 Real Gemini Insight (not hardcoded)
Call AI once per day to generate a habit insight:
```
Context: user completed 12/21 habits this week (57%)
Best category: Fitness (80% completion)
Worst: Sleep (33% completion)
→ AI: "Your sleep habits need attention — missing consistent bedtime could affect your gym performance. Set a 10pm reminder for tomorrow?"
```
Cached in Isar for 24 hours.

### 3.2 Habit streak visualization
Replace the simple week dots in the streak card with a full 12-week heatmap:
- GitHub contribution graph style
- Each cell = a day, colored by completion rate (0% / 25% / 50% / 75% / 100%)
- Tap a cell → shows which habits were completed that day

### 3.3 Streak milestones and badges
Define milestones: 3-day, 7-day, 14-day, 30-day, 100-day streaks.
On milestone: full-screen celebration animation (Lottie `workout_complete.json` adapted).
Award achievement badge (link to Profile achievements).

### 3.4 Habit templates
Pre-built habit packs:
- "Morning Routine Starter Pack" (Hydration, Meditation, Stretch)
- "Athlete Pack" (Workout, Protein, Sleep 8h)
- "Mental Wellness Pack" (Journaling, Gratitude, Screen-free hour)
One-tap add all habits in a pack.

---

## Phase 4 — Advanced (Post-Beta)

- Habit stacking: link habits in a chain (do B immediately after A)
- Accountability partner: share streak with a friend (needs auth + backend)
- AI habit coach: weekly check-in where AI reviews your patterns and suggests dropping low-completion habits and adding complementary ones
- Widget on home screen (iOS/Android) showing today's habit completion
- Habit challenges: 30-day challenges with community (needs backend)

---

## Implementation Priority

| Task | Priority | Effort |
|---|---|---|
| Wire HabitDoc persistence | Critical | Medium |
| Per-day habit completion | High | Medium |
| Real streak calculation | High | Small |
| Enhanced add habit sheet (icon/color/frequency) | High | Medium |
| Habit editing | Medium | Small |
| Real AI insight (cached daily) | Medium | Medium |
| Streak heatmap | Medium | Medium |
| Habit categories grouping | Low | Small |
| Habit templates/packs | Low | Small |

---

## Data Model Changes Needed

### Update `HabitDoc`
```dart
@collection
class HabitDoc {
  Id id = Isar.autoIncrement;
  late String title;
  String subtitle = '';
  String iconName = 'target';
  int colorValue = 0xFF6366F1;
  double progress = 0.0;
  
  // NEW:
  List<DateTime> completedDates = [];
  String category = 'general'; // fitness/mental/nutrition/sleep/productivity
  String frequency = 'daily'; // daily/weekly/custom
  int targetPerWeek = 7;
  DateTime? reminderTime;
  late DateTime createdAt;
  bool isArchived = false;
}
```

### New: `HabitInsightDoc`
```dart
@collection
class HabitInsightDoc {
  Id id = Isar.autoIncrement;
  late String insight;
  late DateTime generatedAt;
}
```
