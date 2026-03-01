# Production Readiness — What Needs to Happen Before Beta/Launch
> This file covers everything outside features: stability, security, performance, store compliance, and release gates.

---

## 1. Current Production Score: 2/10

The app is in **demo/prototype state**. It demonstrates the vision well but cannot be shipped to users yet.  
Below is every gap, categorized by type, with clear action for each.

---

## 2. Critical Blockers (Must Fix Before Any External User Sees It)

### 2.1 No User Identity System
- **Problem:** The entire app is single-user, anonymous, no login, no registration.
- **Impact:** Cannot distinguish users, cannot sync, cannot recover data if device is lost.
- **Fix:** Add Firebase Auth (Google + Apple Sign-In minimum). Wire to `UserDoc`. Onboarding creates the `UserDoc` record.
- **Package:** `firebase_auth`, `google_sign_in`, `sign_in_with_apple`

### 2.2 API Keys Exposed in Source Code
- **Problem:** `GEMINI_API_KEY` and `HF_TOKEN` are read from a `.env` file that is presumably checked into the repo. Flutter compiles these into the app binary — they are extractable.
- **Impact:** Key theft, billing abuse, HuggingFace account compromise.
- **Fix (short-term):** Add `.env` to `.gitignore` immediately. Use `--dart-define-from-file` at build time.
- **Fix (proper):** Build a thin backend proxy (Firebase Cloud Functions or a simple Fastify server) that holds the API keys server-side. The app calls your proxy, not HuggingFace directly.
- **Urgency:** IMMEDIATE — do not push to a public repo with keys in it.

### 2.3 No Error Handling at App Level
- **Problem:** There is no global `FlutterError.onError` or `PlatformDispatcher.instance.onError` handler.
- **Impact:** Unhandled exceptions crash silently with no crash reporting.
- **Fix:** Add Firebase Crashlytics. Wrap `main()` in a `runZonedGuarded`. Add `FlutterError.onError` handler.

### 2.4 Habits Data Not Persisted
- **Problem:** Habits reset on every app restart — the most basic expectation is broken.
- **Impact:** Zero retention — any user will uninstall after the first day when their habits are gone.
- **Fix:** Described in `04_HABITS.md`. Takes ~2–3 hours. Must be done before any user testing.

### 2.5 Dashboard Shows Hardcoded Data
- **Problem:** Steps (4500), sleep (450 min), user name ("Aryan Suthar"), and streak (12 days) are hardcoded seed values.
- **Impact:** Every user sees the same fake data — app looks broken/test mode.
- **Fix:** Wire `UserDoc` for name. Zero-initialize `DailyLogDoc` for a new day. Add onboarding to capture name.

### 2.6 No Onboarding Flow
- **Problem:** First-time users land directly on the dashboard with no setup — the AI coach has no user context, calorie goals are hardcoded at 2000, and name/goals are fake.
- **Impact:** The "personalized AI health app" is not personalized at all on first launch.
- **Fix:** Build the 5-screen onboarding flow (see `07_UPCOMING_FEATURES.md` §1.3). Gate behind `UserDoc.onboardingComplete` flag.

---

## 3. Stability Issues

### 3.1 Dashboard Quick Action "Workout" Bug
- Pushes `/workout` with `null` `planDoc` — player expects a non-null plan.
- Fix: Show a bottom sheet to pick from saved plans, or navigate to workout library instead.

### 3.2 Flash Toggle Bug in Scanner
- `setFlashMode(torch)` is called on tap but never toggled off.
- Fix: Track `_flashOn` boolean in state, toggle between `torch` and `off`.

### 3.3 wger Image Fetch Has No Timeout
- `WgerService` HTTP calls have no timeout set.
- Fix: Add `.timeout(const Duration(seconds: 5))` to all `http.get` calls.

### 3.4 Camera Disposal Race Condition
- Scanner screen disposes camera controller in `dispose()` but if the user taps capture while navigating away, `CameraController.takePicture()` may throw on a disposed controller.
- Fix: Guard all camera calls with `if (_controller.value.isInitialized && mounted)`.

### 3.5 WorkoutController `+45 min` Hardcoded
- `WorkoutController.endWorkout()` adds exactly 45 minutes of exercise time to `DailyLogDoc` regardless of actual session duration.
- Fix: Calculate from `_startTime` — actual elapsed duration.

### 3.6 Isar Version Mismatch on Schema Change
- If a developer changes an Isar model schema (adds/renames a field) without incrementing `@collection` schema version + writing a migration, existing user data will be silently corrupted or wiped.
- Fix: Document a schema migration policy. Add `schemaVersion` checks in `LocalDBService.init()`.

---

## 4. Performance Issues

### 4.1 wger API Called on Every Widget Build
- `wgerExerciseProvider` is a `FutureProvider.family` — it correctly caches per key. However, the preview screen creates a new `WgerExerciseWidget` for every exercise on scroll, and the provider `family` key is the exercise name string. This is fine but needs to be tested with 20+ exercises.

### 4.2 Image Memory Leak in wger Widget
- `WgerExerciseWidget` uses `AnimationController` with a `Timer`. If the widget is removed from the tree while the Timer is active (e.g. fast list scroll), `setState` may be called on a disposed widget.
- Fix: Cancel the timer in `dispose()`. Check `if (mounted)` before every `setState`.

### 4.3 Large exercises.json Loaded Synchronously
- `exercises.json` is loaded with `rootBundle.loadString()` which is synchronous on the first load and blocks the UI thread briefly.
- Fix: Load with `compute()` to isolate from main thread.

### 4.4 ListView Rebuilds on Every Message
- Chat `ListView.builder` rebuilds all visible items on every new message because the list grows. Use `ListView.builder` with `addRepaintBoundaries: true` and ensure each `ChatBubble` is a `const` constructor where possible.

---

## 5. Security Checklist

| Item | Status | Action |
|---|---|---|
| API keys in binary | ⚠️ Risk | Use backend proxy or `--dart-define` + gitignore |
| User data encryption at rest | ❌ | Isar data is unencrypted on device. Add `Isar.open(encryptionKey:)` |
| Network calls over HTTPS | ✅ | All API calls use `https://` |
| Certificate pinning | ❌ | Not implemented. Low priority for now |
| No auth = no data isolation | ❌ | All data belongs to "the device". One auth system fixes this |
| HuggingFace token scope | ⚠️ | Token should be scoped to inference only, not write access |
| Camera/microphone permission justification | ⚠️ | Add proper usage strings in `Info.plist` (iOS) and `AndroidManifest.xml` |

---

## 6. App Store / Play Store Requirements

### iOS (App Store)
| Requirement | Status |
|---|---|
| Privacy manifest (`PrivacyInfo.xcprivacy`) | ❌ Not created |
| Camera usage description | ⚠️ Needs review |
| Microphone usage description | ❌ Missing (mic button exists) |
| Photo library usage description | ❌ Missing (gallery button) |
| Health data usage (HealthKit) if added | ❌ Not yet |
| App Store screenshots (6.7", 6.1", iPad) | ❌ Not created |
| App privacy questionnaire | ❌ Not filled |
| Age rating | ❌ Not set |
| TestFlight build | ❌ Not configured |

### Android (Play Store)
| Requirement | Status |
|---|---|
| `CAMERA` permission | ✅ Likely declared |
| `INTERNET` permission | ✅ Likely declared |
| `RECORD_AUDIO` permission | ❌ Missing |
| `READ_EXTERNAL_STORAGE` permission | ❌ Missing |
| Target SDK 34+ | ⚠️ Needs verification |
| 64-bit compliance | ✅ Flutter default |
| Data safety form | ❌ Not filled |
| Play Console account | ❌ Unknown |
| Signed release APK/AAB | ❌ Not configured |

---

## 7. Code Quality Gates

### 7.1 Flutter Analyze
- Run `flutter analyze` — currently passes with warnings only (no errors). ✅
- Goal: zero warnings too (convert all to errors in `analysis_options.yaml`).

### 7.2 Tests
| Type | Status |
|---|---|
| Unit tests | ❌ Zero test files exist |
| Widget tests | ❌ Zero |
| Integration tests | ❌ Zero |
| Golden tests | ❌ Zero |

Minimum for beta:
- Unit tests for `WgerService` (name matching, fallback logic)
- Unit tests for `WorkoutController` (set completion, timer logic)
- Unit tests for `DailyLogDoc` calorie math
- Widget test for `ChatScreen` message send/receive flow

### 7.3 Linting
- `analysis_options.yaml` exists but not checked — confirm `flutter_lints` is configured.
- Add `prefer_const_constructors`, `avoid_print`, `always_use_package_imports`.

---

## 8. Infrastructure Needed Before Public Launch

| Item | Description | Priority |
|---|---|---|
| Firebase project | Auth + Crashlytics + Analytics | Critical |
| Backend proxy | Thin API proxy to hide HuggingFace/Gemini keys | Critical |
| Privacy policy page | Required by both stores | Critical |
| Terms of service page | Required by both stores | Critical |
| App icon (all sizes) | Current icon is likely default Flutter | High |
| Splash screen | Properly branded, not default | High |
| App name / bundle ID | Confirm final app name, `com.yourcompany.healthai` | High |
| `.env` gitignored | Currently at risk | Immediate |
| Sentry or Crashlytics | Crash reporting | High |
| Analytics events | Track feature usage for data-driven decisions | Medium |

---

## 9. Beta Testing Gate — Minimum Viable Requirements

Before giving the app to any external testers (even friends), ALL of the following must be true:

- [ ] Onboarding flow complete (user sets their name, goals)
- [ ] Habits persist across app restarts
- [ ] Dashboard shows real data, not hardcoded seed values
- [ ] API keys not in source control
- [ ] Dashboard "Workout" button doesn't crash
- [ ] Flash toggle works correctly
- [ ] Camera permissions properly declared in manifests
- [ ] App doesn't crash on cold start on a clean device (no existing Isar DB)
- [ ] Basic crash reporting is live (Firebase Crashlytics)

---

## 10. Launch Readiness Checklist

- [ ] All Critical Blockers (Section 2) resolved
- [ ] All Stability Issues (Section 3) resolved
- [ ] Onboarding flow built
- [ ] Habits fully functional and persisted
- [ ] Workout library screen exists
- [ ] Nutrition log screen exists
- [ ] Auth system built (Firebase Auth)
- [ ] Privacy policy + ToS published
- [ ] App Store metadata prepared (description, keywords, screenshots)
- [ ] Play Store listing prepared
- [ ] Backend proxy deployed
- [ ] Crashlytics live with at least 1 week of data
- [ ] Tested on minimum 3 iOS devices + 3 Android devices
- [ ] Passed App Store Review Guidelines review (manually checked)
- [ ] GDPR / data deletion flow implemented

---

## 11. Recommended Build Order for Production Readiness

```
Week 1 — Foundation
  1. Add .env to .gitignore  (30 min)
  2. Build onboarding flow  (2–3 days)
  3. Wire UserDoc — replace all hardcoded strings  (1 day)
  4. Fix habits persistence  (half day)
  5. Fix all 5 critical bugs from audit  (1 day)

Week 2 — Core Features
  6. Workout library screen  (2 days)
  7. Nutrition log screen  (1.5 days)
  8. Body weight tracker  (1 day)
  9. Sleep entry from dashboard  (half day)

Week 3 — Polish & Stability
  10. Add Firebase Crashlytics  (half day)
  11. Add error boundaries + loading states everywhere  (1 day)
  12. Fix all performance issues (image dispose, timer cancel, etc.)  (1 day)
  13. Write minimum unit test suite  (1 day)
  14. App icon + splash screen  (half day)

Week 4 — Beta Launch Prep
  15. Firebase Auth (Google + Apple)  (2 days)
  16. Backend proxy for API keys  (1 day)
  17. Privacy policy + ToS  (half day)
  18. App Store / Play Store metadata  (1 day)
  19. TestFlight + Internal Play Track builds  (half day)
  20. Collect feedback from 10–20 beta users
```
