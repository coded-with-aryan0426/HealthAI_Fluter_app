# Profile & Authentication — Detailed Plan
> Feature: `/profile`  
> Model: `UserDoc`  
> Related: All features that use user name, goals, photo

---

## Vision

> A real user identity system — not just a settings screen. Profile drives personalization across the entire app: AI context, goal tracking, achievement system, and eventually social features.

---

## Current State

### What works (UI only)
- Beautiful collapsible sliver hero (avatar, name, PRO badge)
- Weekly stats tiles (points, streak, rank)
- Activity bar chart (7-day view)
- Achievement badges (4 static badges)
- AI Summary card
- Settings toggles (notifications, reminders, sync)
- Edit profile bottom sheet
- Delete account confirmation dialog

### What's completely fake / dummy
- **Name**: Hardcoded "Aryan Suthar" — never reads from `UserDoc`
- **Avatar**: `i.pravatar.cc/150?img=47` — static placeholder
- **Points/Streak/Rank**: Hardcoded `4500 / 12 days / #12`
- **Activity bars**: Hardcoded `[0.7, 0.5, 0.9, 0.6, 0.8, 0.3, 0.1]`
- **AI Summary**: Static hardcoded text "Sleep Consistency Up! 15%"
- **Edit profile Save button**: `Navigator.pop()` — saves nothing
- **Settings toggles**: State changes in memory only, no actual behavior
- **Sign Out / Delete Account**: No auth system exists

### Critical gap
`UserDoc` Isar model is fully designed but **never instantiated, never read, never written** anywhere in the app.

---

## Phase 1 — Connect `UserDoc` (No Auth Yet)

### 1.1 Create `userProvider`
```dart
// lib/src/features/profile/application/user_provider.dart
final userProvider = NotifierProvider<UserNotifier, UserDoc>(UserNotifier.new);

class UserNotifier extends Notifier<UserDoc> {
  @override
  UserDoc build() {
    final existing = ref.read(isarProvider).userDocs.where().findFirstSync();
    return existing ?? _createDefault();
  }
  UserDoc _createDefault() {
    final user = UserDoc()
      ..uid = 'local_user'
      ..email = ''
      ..displayName = 'You'
      ..createdAt = DateTime.now()
      ..lastActive = DateTime.now();
    ref.read(isarProvider).writeTxnSync(() => ref.read(isarProvider).userDocs.putSync(user));
    return user;
  }
  Future<void> updateProfile({String? name, double? weight, double? height}) async {
    final updated = state
      ..displayName = name ?? state.displayName
      ..weightKg = weight ?? state.weightKg
      ..heightCm = height ?? state.heightCm;
    await ref.read(isarProvider).writeTxn(() => ref.read(isarProvider).userDocs.put(updated));
    state = updated;
  }
}
```

### 1.2 Update profile screen to read `UserDoc`
- Replace `'Aryan Suthar'` with `ref.watch(userProvider).displayName`
- Replace `i.pravatar.cc` with `UserDoc.photoUrl` (new field, null = placeholder)

### 1.3 Fix Edit Profile sheet to actually save
Wire the Save button to `ref.read(userProvider.notifier).updateProfile(name: nameCtrl.text, ...)`.  
Add fields:
- Display Name (already exists)
- Age / DOB (date picker)
- Height (cm or ft/in based on unit preference)
- Weight (kg or lbs)
- Primary Goal (dropdown: muscle gain / weight loss / endurance / wellness)
- Fitness Level (Beginner / Intermediate / Advanced)

### 1.4 Update dashboard header to use `UserDoc`
Replace `'Aryan Suthar'` on dashboard with `ref.watch(userProvider).displayName`.  
Replace avatar with the same real photo or initials fallback.

---

## Phase 2 — Onboarding Flow

The app currently has **no onboarding**. User opens the app cold and lands on the dashboard with fake seed data. There is no way to set goals, enter personal info, or understand what the app does.

### 2.1 First-launch detection
In `main.dart`, check `isarProvider.userDocs.countSync() == 0`.  
If zero users → push onboarding route instead of `/home`.

### 2.2 Onboarding screens
A beautiful 4-step onboarding flow:

**Step 1 — Welcome**
- App logo, tagline: "Your AI Health Coach"
- "Get Started" button

**Step 2 — About You**
- Name (required)
- Age / DOB
- Gender (optional)

**Step 3 — Body & Goals**
- Height + Weight (with unit toggle metric/imperial)
- Primary goal: chips (Lose Weight / Build Muscle / Stay Fit / Improve Endurance / Better Sleep)
- Fitness experience level

**Step 4 — Dietary Preferences** (optional)
- Multi-select: Vegan / Vegetarian / Gluten-Free / Dairy-Free / Keto / Paleo / No restrictions
- Daily calorie goal (auto-calculated or manual)

**Step 5 — Notifications** (optional)
- Enable daily reminders
- Choose reminder time

On completion: save to `UserDoc`, navigate to `/home`.

---

## Phase 3 — Real Stats & Achievements

### 3.1 Calculate real weekly stats
Replace hardcoded weekly stats with calculated values from Isar:

**Points system:**
- +10 per habit completed
- +50 per workout completed
- +5 per meal logged
- +2 per water goal hit
- Streak bonus: `streak * 2` per day
- Calculate from last 7 days of `WorkoutDoc`, `HabitDoc.completedDates`, `MealDoc`

**Streak:**
- Calculate from `HabitDoc.completedDates` — longest streak of days with ≥1 habit completed

**Activity bars:**
- 7 x `WorkoutDoc.durationSeconds / 3600` (hours) for the last 7 days
- Or `DailyLogDoc.exerciseCompletedMinutes / 60`

### 3.2 Real achievements system
Define 20 achievements with unlock conditions:

| Achievement | Condition |
|---|---|
| First Step | Complete first habit |
| Early Bird | Complete a habit before 8am |
| Scan Master | Scan 10 meals |
| Strength Week | 3+ workouts in one week |
| Marathon | 100 total workouts |
| Hydrated | Hit water goal 7 days in a row |
| AI Explorer | Send 10 messages to AI coach |
| Plan Builder | Generate 5 AI workout plans |
| Consistency King | 30-day habit streak |
| Century Club | Log 100 meals |

Store unlocked achievements in `UserDoc.unlockedAchievements: List<String>`.  
Check unlock conditions at key points (habit toggle, workout end, scan save).  
Show celebration animation + notification on first unlock.

### 3.3 Real AI weekly summary
Collect last 7 days of `DailyLogDoc` data → call AI to generate a personalized 2-sentence summary.  
Cache with a `generatedAt` timestamp (regenerate once per week on Sunday).  
Replace the static "Sleep Consistency Up! 15%" card.

---

## Phase 4 — Authentication (Pre-Public)

Authentication is needed before any public release for:
- Multi-device sync
- Account recovery
- Social features

### 4.1 Auth provider selection
**Recommended: Firebase Auth** (free tier, Flutter SDK `firebase_auth`)
- Anonymous auth first (no friction) → can upgrade to email/Google later
- `UserDoc.uid` maps to Firebase UID

**Alternative: Supabase** (if wanting a single backend for auth + DB sync)

### 4.2 Auth flow
1. App launch → check Firebase auth state
2. Not signed in → show "Sign In" screen with:
   - Continue with Google
   - Continue with Apple (iOS required)
   - Email + Password (optional)
   - Guest mode (anonymous, can upgrade later)
3. Signed in → load/sync `UserDoc` from Firestore
4. Merge local Isar data with cloud on first sign-in

### 4.3 Sign Out / Delete Account (currently dummy)
- Sign Out: `FirebaseAuth.instance.signOut()` → navigate to auth screen, clear local Isar session
- Delete Account: `user.delete()` → wipe Firestore data → clear Isar → navigate to welcome

### 4.4 Profile photo upload
- On avatar tap in profile → image picker → compress → upload to Firebase Storage
- Store URL in `UserDoc.photoUrl` (new field)

---

## Phase 5 — Settings (make toggles functional)

### 5.1 Push notifications
Add `flutter_local_notifications` to pubspec.  
Wire notification toggle: when enabled, schedule:
- Daily habit reminder (configurable time)
- Daily workout reminder (if user has an active plan)
- Water reminder every 2 hours (optional)

### 5.2 Unit system
`UserDoc.preferences.unitSystem = 'metric' | 'imperial'`  
Toggle in settings → rebuilds all displays that show weight/height/distance.  
Create a `UnitConverter` utility.

### 5.3 Export health data
Generate a CSV file from last 30 days of:
- `DailyLogDoc` history (daily macros, calories, water, steps, sleep)
- `WorkoutDoc` history (date, title, duration, exercises)
- `MealDoc` history (name, macros, time)
Use `share_plus` package to share the CSV.

---

## Implementation Priority

| Task | Priority | Effort |
|---|---|---|
| Create `userProvider` + wire to screens | Critical | Medium |
| Fix Edit Profile to actually save | Critical | Small |
| Onboarding flow (5 screens) | High | Large |
| Real points/streak calculation | High | Medium |
| Real achievements system | Medium | Large |
| Real AI weekly summary | Medium | Medium |
| Push notifications wiring | Medium | Medium |
| Data export (CSV) | Low | Medium |
| Firebase Auth | Low (pre-public) | Large |

---

## Data Model Changes Needed

### Update `UserDoc`
```dart
@collection
class UserDoc {
  Id id = Isar.autoIncrement;
  late String uid;
  String email = '';
  String? displayName;
  String? photoUrl; // NEW
  DateTime? dob;
  String? gender;
  double? heightCm;
  double? weightKg;
  late DateTime createdAt;
  late DateTime lastActive;
  
  // NEW - Goals
  String primaryGoal = 'general_fitness'; // muscle_gain/weight_loss/endurance/wellness
  String fitnessLevel = 'intermediate'; // beginner/intermediate/advanced
  int calorieGoal = 2000;
  int proteinGoal = 150;
  int waterGoalMl = 2500;
  
  // NEW - Gamification
  List<String> unlockedAchievements = [];
  int totalPoints = 0;
  
  // NEW - AI
  String? weeklyAiSummary;
  DateTime? weeklyAiSummaryGeneratedAt;
  
  UserPreferences preferences = UserPreferences();
}

@embedded
class UserPreferences {
  List<String> dietary = [];
  String unitSystem = 'metric';
  String theme = 'system';
  bool notificationsEnabled = true; // NEW
  String? habitReminderTime; // NEW - "08:00"
  bool waterRemindersEnabled = false; // NEW
}
```
