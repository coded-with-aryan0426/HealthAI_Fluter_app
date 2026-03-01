# Upcoming Features — Not Yet Built
> Features that are not in the current codebase at all — the iceberg below the waterline

---

## Overview

The current app covers the "basic loop": dashboard → workout → scan food → chat → habits.  
But this is only the foundation. The app's vision is a comprehensive AI health OS.  
Below is the full feature roadmap for what should be built next, ordered by strategic importance.

---

## Tier 1 — High Impact, Build Next

### 1.1 Workout Library Screen (`/workout/library`)
**What:** A dedicated home for all workout-related activity.  
**Why:** Currently there is no entry point to see saved plans, history, or templates.  
**Screens needed:**
- Workout Library (tabs: My Plans / History / Templates)
- Plan detail card (with saved exercises + edit option)
- History log (all `WorkoutDoc`s, grouped by week)
**Data:** Reads `WorkoutPlanDoc` + `WorkoutDoc` from Isar.  
**Route:** Add as a nav branch in the shell (replace or add alongside Habits).

### 1.2 Exercise Library (`/exercise/library`)
**What:** Searchable, filterable database of 800+ exercises.  
**Why:** Users need to explore exercises, understand form, and add them to workouts manually.  
**Data source:** `assets/data/exercises.json` + wger API.  
**Features:**
- Search by name
- Filter by muscle group, equipment, difficulty
- Thumbnail images from wger
- Exercise detail with animated demonstration + form cues
- "Add to workout" picker mode from within player

### 1.3 Onboarding Flow (5 screens)
**What:** First-launch setup: name, age, height/weight, goals, dietary prefs, notifications.  
**Why:** Without this, the app has no user identity — everything is anonymous seed data.  
**Critical for:** Personalized AI context, meaningful dashboard data, correct calorie goals.  
**Screens:** Welcome → About You → Body & Goals → Dietary Prefs → Notifications permission.

### 1.4 Nutrition Log Screen (`/nutrition/log`)
**What:** A daily food diary showing every logged meal with macros.  
**Why:** The scanner saves macros as totals but there is no way to see what you actually ate.  
**Features:**
- Grouped by meal type (Breakfast/Lunch/Dinner/Snacks)
- Tap "Calories In" bento card → opens this screen
- Delete individual meals
- Macro ring chart for the day
- Navigate by date

### 1.5 Habits Persistence Fix
**What:** Wire `HabitDoc` Isar model — currently all habits are lost on app restart.  
**Why:** The most basic expectation of a habit tracker is that it remembers your habits.  
**This is not a "new feature" — it's a critical bug that makes Habits essentially non-functional.**

---

## Tier 2 — Major Features, High Value

### 2.1 Strength Progress Charts (`/workout/progress`)
**What:** Line charts showing strength progression per exercise over time.  
**Data needed:** Log `weightKg` and `reps` per set per exercise → stored in `WorkoutDoc.exercises[].sets[]`.  
**Charts:**
- Weight over time per exercise (line chart)
- Weekly volume bar chart
- Estimated 1RM trend
- Total workout frequency heatmap
**Package:** `fl_chart`

### 2.2 Body Weight & Measurements Tracker
**What:** A simple daily log for body weight, with optional measurements (waist, chest, arms).  
**Features:**
- Log weight once per day (small input from dashboard or profile)
- Weight trend chart (last 90 days)
- Goal weight line on chart
- Optional: waist/chest/hip measurements
**Model:** New `BodyMeasurementDoc` collection.

### 2.3 Barcode Scanner for Food
**What:** Scan packaged food barcodes to instantly log nutritional info.  
**Data source:** Open Foods Facts API (free, 3M+ products).  
**Package:** `mobile_scanner`  
**How:** New mode in scanner screen (switch between Camera AI / Barcode / Manual).

### 2.4 Personalized Calorie/Macro Goals
**What:** Auto-calculate daily calorie and macro targets from user profile (TDEE).  
**Formula:** TDEE = BMR (Mifflin-St Jeor) × activity multiplier.  
**Goal adjustments:** +300 kcal for muscle gain, -500 kcal for weight loss.  
**Displayed:** As the "goal" bars in scanner results and nutrition log.

### 2.5 Meal Planning Card in Chat
**What:** AI generates structured meal plans that appear as interactive cards in chat (like WorkoutPlanCard).  
**JSON format:** `meal_plan` fence with breakfast/lunch/dinner/snacks + macros.  
**Actions:** "Log all meals" / "Log individually" / "Show recipes".

### 2.6 Sleep Tracking (Manual Entry)
**What:** Simple sleep logger — bedtime, wake time, quality rating.  
**Entry point:** Tap "SLEEP" bento card on dashboard.  
**Features:**
- Time picker for sleep/wake
- Quality slider (1-5 stars)
- Stores in `DailyLogDoc.sleepMinutes` (already exists)
- Weekly sleep chart
- AI tip based on patterns: "You sleep 40 min less when you train after 8pm"

---

## Tier 3 — Meaningful Additions

### 3.1 Voice Input in AI Chat
Use `speech_to_text` package — mic button transcribes to text field in real-time.  
Especially valuable during workouts (hands full) or for users who prefer talking.

### 3.2 Proactive Daily Notifications
Push notifications with AI-generated motivational messages based on last day's data.  
Uses `flutter_local_notifications`.  
Configurable time in profile settings.

### 3.3 Pre-built Workout Templates
5 static workout programs bundled with the app:
- PPL (Push/Pull/Legs)
- 5×5 Beginner Strength
- Home HIIT No Equipment
- Full Body 3x/week
- Marathon Prep Running
Displayed in workout library "Templates" tab.

### 3.4 Supplement Tracker
Simple daily log for supplements (protein powder, creatine, vitamins, etc.).  
Checklist format: "Did you take your morning supplements?"  
Tracks streak, sends reminder.

### 3.5 Rest Day & Recovery Assistant
After detecting 2+ consecutive workout days (from `WorkoutDoc` history):  
- Show recovery score card on dashboard
- AI suggests: foam rolling, stretching, light walking, nutrition for recovery
- "Active Recovery" workout option in workout library

### 3.6 Water Goal Personalization
Current goal is hardcoded at `2500ml`.  
Calculate from `UserDoc.weightKg × 35ml` (WHO recommendation).  
Allow manual override in profile.

---

## Tier 4 — Social & Scale Features (Post-Beta)

### 4.1 User Authentication & Multi-Device Sync
- Firebase Auth (Google / Apple / Email)
- Firestore for cloud backup of `UserDoc`, `WorkoutPlanDoc`, `ChatSessionDoc`
- Sync on login — merge local data with cloud

### 4.2 Workout Sharing
- Generate a shareable image card of a completed workout
- Include: exercises, total volume, duration, date
- Share via system share sheet (Instagram stories format)

### 4.3 Accountability Partner
- Share progress with a friend via a unique code
- View friend's habit completion rate (privacy-controlled)
- Challenge system: "Who can hit 10k steps 5 days this week?"

### 4.4 Coach Marketplace
- Verified human coaches can upload workout programs to the app
- Users can subscribe to a coach's program
- Coach can see user's progress in a dashboard
- Revenue model: coach earns per subscriber

### 4.5 AI-Powered Progress Photos
- Monthly progress photo reminders
- AI analyzes front/side/back photos to estimate body composition changes
- Stored locally only (privacy-first) or encrypted in cloud

### 4.6 Apple Watch / WearOS Integration
- Real-time heart rate during workouts
- Step count sync
- Workout start/stop from watch
- Quick water log from watch

---

## Priority Matrix

| Feature | Impact | Effort | Build Order |
|---|---|---|---|
| Habits persistence fix | Critical | Medium | #1 |
| Onboarding flow | Critical | Large | #2 |
| Workout library screen | High | Medium | #3 |
| Nutrition log screen | High | Medium | #4 |
| Personalized calorie goals | High | Small | #5 |
| Strength progress charts | High | Large | #6 |
| Sleep manual entry | Medium | Small | #7 |
| Barcode scanner | Medium | Medium | #8 |
| Body weight tracker | Medium | Medium | #9 |
| Voice input in chat | Medium | Medium | #10 |
| Pre-built workout templates | Medium | Small | #11 |
| Meal planning card | Medium | Large | #12 |
| Proactive notifications | Medium | Medium | #13 |
| Supplement tracker | Low | Small | #14 |
| Auth + cloud sync | High (pre-launch) | Large | #15 |
| Workout sharing | Low | Medium | #16 |
| Progress photos AI | Low | Large | #17 |
