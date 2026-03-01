# HealthAI — Full App Audit
> Last updated: 2026-02-26  
> Based on complete codebase read of every screen, controller, service, and model.

---

## 1. What Is This App?

HealthAI is an **AI-first personal health companion** built in Flutter. The core vision is:
> A single app that replaces a personal trainer, nutritionist, habit coach, and health tracker — powered by on-device and cloud AI.

Stack: Flutter + Riverpod + Isar (local DB) + GoRouter + HuggingFace LLM API (Llama 3.3 70B) + HuggingFace Vision API (Qwen2.5-VL) + flutter_gemma (on-device Gemma 3).

---

## 2. Feature Map — Current State

### 2.1 Navigation Shell
| Item | Status | Notes |
|---|---|---|
| Bottom nav bar | ✅ Working | Glass morphic, 4 items: Home, Habits, Scan FAB, Coach, Profile |
| GoRouter routes | ✅ Working | All routes wired correctly |
| Theme toggle | ✅ Working | Light/dark, persisted via Riverpod |
| FAB → scanner | ✅ Working | Opens scanner as fullscreen modal |
| Coach / Profile outside shell | ✅ Working | Push route, not indexed branch |
| Workout/Habits as branches | ✅ Working | StatefulShellRoute |

**Issue:** Only 2 nav branches (Home, Habits). Workout has no tab — it lives under `/workout` pushed from buttons. No dedicated Workout tab yet.

---

### 2.2 Dashboard (`/home`)
| Item | Status | Notes |
|---|---|---|
| Greeting + avatar | ✅ Working | Hardcoded name "Aryan Suthar", placeholder avatar |
| Activity rings (3 rings) | ✅ Working | Animated, reads from `DailyLogDoc` |
| Ring legend | ✅ Working | Calories burned / Exercise / Stand |
| Water tracker card | ✅ Working | +250ml / -250ml / +500ml buttons, animated progress bar, persists to Isar |
| Quick actions row | ✅ Working | Scan / Workout / AI Coach / Profile buttons |
| Today's Stats bento grid | ✅ Working | Sleep / Steps / Protein / Calories In |
| Bento grid data | ⚠️ DUMMY | All numbers are hardcoded seed values in `_initToday()` — NOT real user input |
| Sleep data | ⚠️ DUMMY | `450 min` hardcoded — no actual sleep tracking input |
| Step count | ⚠️ DUMMY | `4500` hardcoded — no pedometer/HealthKit |
| Protein/carbs/fat | ⚠️ Partially real | Updates when food scanner saves a meal |
| Calories burned | ⚠️ DUMMY | Not updated by real workout session end |
| "Workout" quick action | ⚠️ BUG | Goes to `/workout` (player) directly without a plan — `planDoc` will be null |
| Profile avatar | ⚠️ DUMMY | `https://i.pravatar.cc/150?img=47` — not real user photo |
| User name | ⚠️ DUMMY | Hardcoded string "Aryan Suthar" |

---

### 2.3 Habits (`/habits`)
| Item | Status | Notes |
|---|---|---|
| Habit list | ✅ Working | Displays habits with progress rings, icons |
| Toggle complete | ✅ Working | Haptic, animates, marks as done |
| Swipe to delete | ✅ Working | Dismissible |
| Add new habit (name only) | ✅ Working | Bottom sheet, saves to local state |
| Date picker strip | ✅ UI only | Shows week dates, tapping day changes `_selectedDayIndex` but habits do NOT change per day |
| Progress summary | ✅ Working | Circular progress, percent complete |
| Streak card | ⚠️ DUMMY | "12 Days" hardcoded — no real streak calculation |
| "Gemini Insight" card | ⚠️ DUMMY | Static hardcoded string, NOT calling AI |
| Data persistence | ⚠️ NOT PERSISTED | `_habitsProvider` is a `StateNotifierProvider` — it's in memory only, resets on app restart. `HabitDoc` Isar model exists but is never used |
| Per-day habit history | ❌ NOT BUILT | Date strip has no effect — same habits show for all days |
| Habit editing | ❌ NOT BUILT | Cannot edit icon, color, target, or schedule |
| Habit reminder notifications | ❌ NOT BUILT | Toggle in profile does nothing |
| Habit categories | ❌ NOT BUILT | All habits are generic |
| Completion tracking over time | ❌ NOT BUILT | No history stored |

---

### 2.4 Diet Scanner (`/scanner`)
| Item | Status | Notes |
|---|---|---|
| Camera preview | ✅ Working | `camera` package, real live feed |
| Capture + analyze | ✅ Working | Takes photo, sends to HF vision API |
| Gemini Vision fallback chain | ✅ Working | Qwen2.5-VL → Llama3.2-11B-Vision |
| Results bottom sheet | ✅ Working | Name, calories, protein, carbs, fat |
| Macro bars animated | ✅ Working | Animated progress bars |
| Save to log | ✅ Working | Calls `saveMealToLog` → updates `DailyLogDoc` in Isar |
| Calorie donut | ✅ Working | Animated |
| Gallery button | ⚠️ DUMMY | Button exists, no action (just haptic) |
| Manual entry button | ⚠️ DUMMY | Button exists, no action |
| Flash toggle | ⚠️ BUG | Sets `FlashMode.torch` but never turns off |
| Food history / meal log | ❌ NOT BUILT | Meals are saved to DailyLogDoc totals only, no per-meal list |
| Meal timing tracking | ❌ NOT BUILT | No breakfast/lunch/dinner categorization |
| Calorie goal setting | ❌ NOT BUILT | Goal hardcoded as 2000 kcal |
| Barcode scanning | ❌ NOT BUILT | No barcode/QR support |
| Custom food database | ❌ NOT BUILT | No search-by-name fallback |

---

### 2.5 AI Coach Chat (`/chat`)
| Item | Status | Notes |
|---|---|---|
| Chat screen UI | ✅ Working | Glass appbar, bubble list, typing indicator |
| Send message | ✅ Working | Sends to HF LLM (Llama 3.3 70B) with health context |
| Model fallback chain | ✅ Working | Llama-3.3-70B → Llama-3.1-8B → Mistral-7B |
| Rate limit handling | ✅ Working | Countdown timer, user-visible banner |
| Session history | ✅ Working | Isar-persisted, drawer with all sessions |
| Pin / Rename / Delete sessions | ✅ Working | Long press context menu |
| Search chat history | ✅ Working | Drawer search field |
| New chat button | ✅ Working | Creates new session |
| Workout plan parsing | ✅ Working | AI response → JSON → `WorkoutPlanCard` bubble |
| Workout plan card actions | ✅ Working | Preview / Start / Save |
| Scroll to bottom button | ✅ Working | Appears when scrolled up |
| Open at bottom on session switch | ✅ Working | Two-frame post-callback jump |
| Welcome/empty state | ✅ Working | Suggestion tiles, capability pills |
| Markdown rendering | ✅ Working | `flutter_markdown` |
| Offline mode (Gemma on-device) | ✅ Working | Toggle in appbar, `flutter_gemma` |
| Gemma model setup screen | ✅ Working | Download flow with progress |
| Health context injection | ✅ Working | Daily log sent as system context on first message |
| Paperclip (attach image) | ⚠️ DUMMY | Button exists, no action |
| Mic (voice input) | ⚠️ DUMMY | Button exists, no action |
| Chat export | ❌ NOT BUILT | |
| AI-generated insights pushed to dashboard | ❌ NOT BUILT | |
| Multi-modal (image in chat) | ❌ NOT BUILT | |

---

### 2.6 Workout System (`/workout/preview`, `/workout`)
| Item | Status | Notes |
|---|---|---|
| Workout plan preview screen | ✅ Working | Shows days, exercises, wger illustrations |
| Workout player screen | ✅ Working | Set logging, timer, rest timer |
| AI-generated plan from chat | ✅ Working | JSON parsed → `WorkoutPlanData` → preview |
| Save plan to library | ✅ Working | Saved as `WorkoutPlanDoc` in Isar |
| Load saved plan | ✅ Working | `WorkoutPlanDoc` → preview/player |
| wger exercise illustrations | ✅ Working | Live API fetch, name-matched |
| Exercise animation (start/end flip) | ✅ Working | Auto-crossfade between positions |
| Set completion logging | ✅ Working | Checkbox + reps/weight input |
| Rest timer | ✅ Working | Countdown between sets |
| Workout timer | ✅ Working | Elapsed time display |
| End workout | ✅ Working | Saves `WorkoutDoc` to Isar |
| "Workout" quick action on dashboard | ⚠️ BUG | Pushes `/workout` with null `planDoc` — crashes or shows empty player |
| Workout history screen | ❌ NOT BUILT | `WorkoutDoc`s are saved but never displayed anywhere |
| Workout library screen | ❌ NOT BUILT | Saved `WorkoutPlanDoc`s have no dedicated browse screen |
| Exercise library/search | ❌ NOT BUILT | No way to manually browse or search exercises |
| Progress tracking / charts | ❌ NOT BUILT | No strength progression, no volume tracking |
| Personal records (PRs) | ❌ NOT BUILT | |
| Rest day / recovery suggestions | ❌ NOT BUILT | |
| Pre-built workout templates | ❌ NOT BUILT | |
| Body weight tracking | ❌ NOT BUILT | |
| Custom workout builder (manual) | ❌ NOT BUILT | |

---

### 2.7 Profile (`/profile`)
| Item | Status | Notes |
|---|---|---|
| Profile hero (avatar, name) | ✅ Working | Beautiful collapsible sliver |
| Weekly stats | ✅ Working | Points / Streak / Rank tiles |
| Activity bar chart | ✅ Working | Animated 7-day bars |
| Achievements section | ✅ UI only | Static badges — not connected to real data |
| AI Summary card | ⚠️ DUMMY | Static hardcoded text "Sleep Consistency Up! 15%" |
| Settings toggles | ✅ UI only | Notification / Reminder / Sync toggles — state in Riverpod but no actual behavior |
| Edit profile sheet | ⚠️ DUMMY | Has name + weight goal fields, Save does nothing (just `Navigator.pop`) |
| Export health data | ⚠️ DUMMY | Button exists, no action |
| Sign Out | ⚠️ DUMMY | Haptic only — no auth system |
| Delete Account | ⚠️ Partial | Shows confirmation dialog, does nothing on confirm |
| Points / Streak / Rank | ⚠️ DUMMY | Hardcoded "4500 / 12 days / #12" |
| Activity bars | ⚠️ DUMMY | Hardcoded `[0.7, 0.5, 0.9, 0.6, 0.8, 0.3, 0.1]` |
| User authentication | ❌ NOT BUILT | No login/register/auth system at all |
| Real user profile storage | ❌ NOT BUILT | `UserDoc` Isar model exists but is never used |
| Notifications | ❌ NOT BUILT | `flutter_local_notifications` not installed |
| Health data export (CSV/PDF) | ❌ NOT BUILT | |
| Gamification backend | ❌ NOT BUILT | Points/achievements not calculated |

---

## 3. Data Models vs Usage

| Model | Schema | Provider | Used By | Persisted |
|---|---|---|---|---|
| `UserDoc` | ✅ Full schema (uid, email, name, DOB, height, weight, preferences) | ❌ No provider | ❌ Nothing | ❌ Never written |
| `DailyLogDoc` | ✅ Full schema | ✅ `dailyActivityProvider` | Dashboard, Scanner | ✅ Isar |
| `WorkoutDoc` | ✅ Full schema | ✅ `activeWorkoutProvider` | Player (write) | ✅ Isar (write only) |
| `WorkoutPlanDoc` | ✅ Full schema | ✅ Inline in plan controller | Chat → Preview | ✅ Isar |
| `HabitDoc` | ✅ Full schema | ❌ Never used | ❌ Nothing | ❌ Never written |
| `MealDoc` | ✅ Full schema | ❌ No provider | ❌ Nothing | ❌ Never written |
| `ChatSessionDoc` | ✅ Full schema | ✅ `chatControllerProvider` | Chat screen | ✅ Isar |

**Key gap:** `UserDoc`, `HabitDoc`, `MealDoc` are fully designed but 100% unused.

---

## 4. Services Assessment

| Service | Reality |
|---|---|
| `GeminiService` | Actually uses HuggingFace Router (not Google Gemini). Llama 3.3 70B for chat, Qwen2.5-VL for vision. Model fallback chain works. |
| `GemmaService` | On-device Gemma via flutter_gemma. Download flow works. Offline mode works. |
| `LocalDBService` | Isar init, single instance provider. Works. |
| `WgerService` | Fetches exercise images from wger.de. 3-tier search strategy. In-memory cache. Works. |

---

## 5. Critical Bugs

1. **Dashboard "Workout" quick action** → pushes `/workout` with no `planDoc` → player gets `null` → undefined behavior
2. **Flash mode** → `setFlashMode(torch)` called on tap but never toggled off — user can't turn flash off
3. **Habits not persisted** → all habits reset on every app cold start
4. **Streak hardcoded** → "12 Days" always, regardless of actual habit history
5. **Gemini Insight hardcoded** → static string, AI not called

---

## 6. UI/UX Issues

1. Dashboard name "Aryan Suthar" hardcoded — should read from `UserDoc`
2. Profile photo is a random placeholder — no way to set real photo
3. Bento grid shows seed data (450/600 kcal, 4500 steps) even after real workout
4. No loading states for wger image fetch — blank space on slow connections
5. No empty states for workout history (no screen to view it)
6. No onboarding flow — user lands on dashboard with no setup
7. Settings toggles have no real effect

---

## 7. Architecture Observations

**Good:**
- Clean feature-based folder structure
- Riverpod used consistently
- Isar models well-designed with forward-looking schema
- GoRouter shell with indexed branches correct
- `GeminiService` has solid fallback chain and rate-limit handling

**Gaps:**
- No auth layer — everything is single-user anonymous
- No sync/backup — all data is device-local only  
- Hardcoded user data throughout (name, stats, seed values)
- No dependency injection for environment config (dotenv at top level)
- `WorkoutController` uses hardcoded `+45 min` exercise time on workout end
- `_habitsProvider` is file-local with `_` prefix — cannot be shared between files

---

## 8. Summary Score

| Feature | Score | Grade |
|---|---|---|
| Dashboard UI | 8/10 | A- |
| Dashboard functionality | 4/10 | D |
| Habits UI | 8/10 | A- |
| Habits functionality | 3/10 | D |
| Diet Scanner UI | 9/10 | A |
| Diet Scanner functionality | 7/10 | B |
| AI Chat UI | 9/10 | A |
| AI Chat functionality | 8/10 | A- |
| Workout UI | 8/10 | A- |
| Workout functionality | 6/10 | C+ |
| Profile UI | 8/10 | A- |
| Profile functionality | 2/10 | F |
| Auth / User system | 0/10 | F |
| Data persistence | 5/10 | C |
| Production readiness | 2/10 | F |
