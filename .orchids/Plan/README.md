# HealthAI — Plan Folder Index
> Last updated: 2026-02-26

This folder contains the complete strategic plan for building HealthAI into a production-ready, publicly shippable app. Read in order for full context.

---

## Files in This Folder

| File | What It Covers |
|---|---|
| `00_APP_AUDIT.md` | Complete current-state audit — every screen, every feature, every bug. What works, what's dummy, what's broken, with scores. **Start here.** |
| `01_DASHBOARD.md` | Dashboard improvements — wiring real data, fixing hardcoded seeds, adding sleep/step entry, bento grid actions |
| `02_WORKOUT.md` | Workout system — library screen, history log, exercise browser, strength progress charts, custom builder, templates |
| `03_NUTRITION.md` | Nutrition — meal log screen, barcode scanner, calorie goal calculation, macro targets, meal planning AI card |
| `04_HABITS.md` | Habits — persistence fix (critical bug), per-day history, editing, streaks, real Gemini insight, notifications |
| `05_AI_COACH.md` | AI Coach — voice input, image attach, proactive insights, meal plan cards, context improvements, export |
| `06_PROFILE_AUTH.md` | Profile + Auth — onboarding flow, UserDoc wiring, Firebase Auth, real stats, gamification backend |
| `07_UPCOMING_FEATURES.md` | Full iceberg roadmap — every feature not yet built, tiered by priority with effort estimates |
| `08_PRODUCTION_READINESS.md` | Production gates — API key security, crash reporting, App Store requirements, beta checklist, 4-week launch plan |

---

## App Vision (One Paragraph)

HealthAI is an **AI-first personal health OS** — a single app that replaces a personal trainer, nutritionist, habit coach, sleep tracker, and health data analyzer. The AI coach knows your entire health context (what you ate, how you slept, what you lifted, what habits you hit) and gives advice that is actually personalized. Every feature feeds every other feature: your workout ends → calories burned updates → AI coach knows you're tired → habit reminder adjusts → nutrition goal recalculates.

---

## Current State (February 2026)

```
Core loop:        WORKING (dashboard → workout → scan food → chat → habits)
AI features:      WORKING (chat, workout plan generation, food scanning)
Data persistence: PARTIAL (chat sessions ✅, workouts ✅, habits ❌, meals ❌, user ❌)
User identity:    NOT BUILT (no auth, no onboarding, hardcoded name/data)
Production:       NOT READY (API keys exposed, no crash reporting, hardcoded data)
```

**Overall readiness: ~35% toward public beta.**

---

## Immediate Next Actions (Do These First)

1. **`git ignore .env`** — API keys must not be in source control. Do this now.
2. **Fix habits persistence** (`04_HABITS.md` §2) — habits resetting on restart is unacceptable for any user test.
3. **Build onboarding flow** (`06_PROFILE_AUTH.md` §3) — without this the app has no identity and all data is fake.
4. **Fix dashboard hardcoded data** (`01_DASHBOARD.md` §2) — replace "Aryan Suthar" and seed numbers.
5. **Fix dashboard Workout crash** (`00_APP_AUDIT.md` §5, item 1) — the quick action crashes.

---

## Feature Build Order (Prioritized)

### Phase 1 — Make It Real (Before Any User Sees It)
- Onboarding flow (name, goals, body metrics, dietary prefs)
- Wire `UserDoc` — replace all hardcoded strings and seed data
- Fix habits persistence (Isar `HabitDoc`)
- Fix all 5 critical bugs
- Firebase Crashlytics

### Phase 2 — Complete Core Features
- Workout library + history screen
- Nutrition log screen (tap "Calories In" → see meals)
- Sleep entry from dashboard
- Body weight tracker
- Personalized calorie/macro goal calculation

### Phase 3 — Elevate AI
- Voice input in chat
- Image attach in chat
- Proactive AI insights pushed to dashboard
- Meal planning card in chat (like WorkoutPlanCard)
- Real Gemini insight in Habits screen

### Phase 4 — Launch Readiness
- Firebase Auth (Google + Apple)
- Backend API proxy (hide keys)
- App icon + splash screen
- Privacy policy + ToS
- App Store / Play Store metadata
- TestFlight internal → external beta

### Phase 5 — Scale (Post-Beta)
- Barcode food scanner
- Strength progress charts
- Pre-built workout templates
- Supplement tracker
- Rest day / recovery suggestions
- Apple Health / Google Fit integration
- Wearable support

---

## Key Decisions To Make

| Decision | Options | Recommendation |
|---|---|---|
| Auth provider | Firebase vs Supabase vs custom | Firebase (fastest, Flutter SDK best-in-class) |
| API key security | Proxy vs `--dart-define` only | Backend proxy (even a single Cloud Function is enough) |
| Step counting | HealthKit/Google Fit vs pedometer package | `health` package — wraps both |
| Nutrition database | OpenFoodFacts (barcode) vs manual vs Nutritionix API | OpenFoodFacts free tier first |
| Workout nav | Add 3rd nav tab vs keep under Home | Add Workout tab — it's a primary feature |
| Monetization | Free vs freemium vs subscription | Freemium: core free, AI coach unlimited as Pro |
