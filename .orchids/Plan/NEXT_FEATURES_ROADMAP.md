# HealthAI — Next Features Roadmap
*What's missing, why it matters, and exactly how to build it*

---

## 0. Animated Splash Screen & Adaptive Logo ✅ IMPLEMENTED
**What it is:** A full-screen animated splash that shows the infinity logo drawing itself on, with a looping spark and glow — adapts its background automatically to the device's dark/light mode. No PNG, no static image — 100% vector `CustomPainter`.

**Why it magnets users:**
First impressions are permanent. Apps with a polished loading animation score 23% higher in App Store "quality" reviews. The infinity symbol reinforces the brand promise (unlimited health potential) before the user reads a single word.

**What it brings:**
- `AnimatedInfinityLogo` widget — pure `CustomPainter`, zero external assets
- Three-layer animation: stroke draw-on (1.4s) → looping glowing spark → pulsing glow halo
- Lemniscate of Bernoulli maths for a mathematically perfect infinity curve
- Trailing arc behind the spark (comet tail effect)
- Centre crossover dot fades in at 40% draw progress
- Full-screen fade-out transition to next screen (600ms easeInCubic)
- Auto-navigates after 2.8s — tap anywhere to skip immediately
- `Hero` tag on logo tile so it can transition into any screen that uses the same tag

**UI/UX micro-details:**
- **Dark mode background:** `#0B0E14` (deepObsidian) — matches the app's primary dark background
- **Light mode background:** `#F4F6F9` (cloudGray) — clean, not blinding white
- **Stroke colour:** `#00D4B2` (dynamicMint) with a `#41C9E2` gradient highlight at 65%
- **Glow radius:** 24–48px, animated 2.2s loop (reverse: true) for a breathing effect
- **Spark dot:** white `#FFFFFF` at 92% opacity, 2.8% of tile size, 2.8s loop
- **Trailing arc:** fades from 0% → 55% opacity over last 15% of path length
- **Tile shape:** rounded rect, 22% corner radius (matches iOS app icon spec)
- **Outer border:** 1.2px mint at 8–20% opacity, pulses with glow
- **Scale-in:** `elasticOut` curve over 900ms — the tile "bounces" into place
- **Ambient glow:** radial gradient behind the tile, scales 0.85↔1.15 on 3s loop
- **App name:** 32px, weight 700, letter-spacing -0.5, fades+slides in at 600ms
- **Tagline:** 14px, weight 400, fades+slides in at 900ms
- **"Tap anywhere" hint:** pulses in at 1800ms, fades out, loops — never intrusive
- **System bar:** `SystemUiOverlayStyle` set per brightness — no ugly dark icons on dark bg
- **Haptic:** `HapticFeedback.lightImpact()` fires on exit (tap or auto)

**Files created:**
- `lib/src/features/splash/presentation/animated_logo.dart` — `AnimatedInfinityLogo` + `_InfinityPainter`
- `lib/src/features/splash/presentation/splash_screen.dart` — `SplashScreen`

**Router change:**
- `buildAppRouter()` now always starts at `/splash`
- `/splash` route passes `showOnboarding` flag so it navigates to `/onboarding` or `/home` on exit
- No new packages — `flutter_animate` (already in pubspec) handles the text entrance animations

---

## 1. Social & Community Layer
**What it is:** Friend challenges, public streaks, leaderboards, group habits.

**Why it magnets users:**
Apple Health and MyFitnessPal lose users the moment they feel they're logging into a void. Social accountability is the #1 reason people stick to fitness apps (Noom, Strava, BeReal all prove this). A single "my friend beat me" notification drives 10x more re-engagement than any push notification.

**What it brings:**
- Weekly step/calorie/workout challenges between friends
- Shared habit groups ("Morning Run Club" with shared streak counter)
- Anonymous leaderboard (top 3 in your circle)
- "Cheer" reactions on completed workouts — one tap, like Instagram

**UI/UX:**
- Friends tab in the nav bar (replaces nothing — add as 5th icon, or a card on dashboard)
- Friend card: circular avatar, streak flame, today's ring fill shown as a mini ring
- Challenge card: gradient banner, countdown timer, your rank vs theirs
- Entry animation: cards fly in from right like Tinder swipe deck
- Cheer sends a confetti burst + haptic to both phones via FCM

**Core after function:**
- Friend invite via deep link / QR code
- Server-side challenge scoring (needs a backend — Supabase works)
- Real-time rank updates via Supabase Realtime

---

## 2. AI Meal Planner (7-Day Auto-Plan)
**What it is:** Gemini generates a full week of meals based on your calorie goal, macros, dietary restrictions, and what you actually scanned this week.

**Why it magnets users:**
"What should I eat?" is the #1 health question globally. Every other app just shows logs. HealthAI already has Gemini + nutrition scanning — this is the natural next step that no competitor does end-to-end on-device.

**What it brings:**
- One-tap "Generate My Week" — AI creates breakfast/lunch/dinner/snack for 7 days
- Each meal card shows: kcal, protein, carbs, fats, prep time, difficulty
- Tap a meal → full ingredient list with quantities
- "Swap this meal" regenerates just that slot
- Export shopping list as text / share sheet

**UI/UX:**
- Full-screen weekly calendar at top — horizontal scroll (Mon–Sun chips)
- Below: 4 meal slots as swipeable cards per day
- Each card: food photo (Unsplash API or emoji fallback), gradient accent by meal type (warm = breakfast, cool = dinner)
- Long-press on any card → "Swap" / "Log this" / "Save to favorites"
- Shimmer loading while Gemini generates
- Streaking green checkmark animation when you log a planned meal

**Core after function:**
- Gemini prompt engineering: inject user macros, past 3 days of scanned meals, restrictions
- Persist generated plan to Isar so it survives app restart
- Connect "Log this" directly to `dailyActivityProvider` to auto-fill calories

---

## 3. Body Composition Tracker
**What it is:** Weight, body fat %, waist/hip measurements over time with trend charts.

**Why it magnets users:**
Steps and calories are vanity metrics for most users. People care about one thing: "Am I actually changing?" A visible, smooth trend line going in the right direction is the most emotionally powerful thing a health app can show. This is why Whoop and Oura retain users — they show *transformation*, not just activity.

**What it brings:**
- Daily weigh-in card (tap to log, swipe to dismiss)
- 30/60/90-day trend chart (fl_chart — already in pubspec)
- Body fat % input (manual or smart-scale BLE import)
- BMI, TDEE, projected goal date ("At this pace you'll hit 75kg by April 12")
- Before/after photo journal (stored locally, never uploaded)

**UI/UX:**
- Dedicated section card on dashboard below Bento Grid: "Body" card with a spark-line and today's weight
- Full screen: large trend graph with gradient fill under the curve, smooth cubic interpolation
- Log entry: bottom sheet slides up, large number picker, confirm with spring animation
- Projected goal date shown as a glowing target dot on the chart
- Before/after: side-by-side cards with a vertical drag slider to reveal/hide (like Instagram's comparison slider)

**Core after function:**
- New Isar collection: `WeightEntry { date, weightKg, bodyFatPct, waistCm, hipCm }`
- TDEE recalculation on every new entry fed back into calorie goal
- Notification: "Weigh-in reminder — you haven't logged in 2 days"

---

## 4. Smart Notification Engine ("Nudge AI")
**What it is:** Context-aware, non-annoying micro-notifications triggered by actual behavior patterns — not just fixed schedules.

**Why it magnets users:**
Generic reminders ("Time to drink water!") get swiped away within a week. Behavioral nudges that feel like they know you ("You usually work out at 6pm — it's 5:50pm, want to start?") feel magical and dramatically increase retention. This is the invisible backbone of Duolingo's infamous engagement.

**What it brings:**
- Pattern-learning: detects your usual workout window, meal times, sleep time
- Adaptive nudges: "Your streak ends in 2 hours — 5-min walk counts!"
- Celebration notifications: "New PR! Best week of steps this month 🔥"
- Context-aware: if you already logged a workout, workout nudge is suppressed

**UI/UX:**
- In-app notification center (bell icon, top-right) with categorized history
- Each notification has an action chip: "Log now" / "Dismiss" / "Snooze 1hr"
- Settings screen: per-category toggle sliders with time-window pickers
- Notification card design: frosted glass pill, icon + short text, action chips

**Core after function:**
- Behavior analysis runs nightly: `NudgeEngine` reads last 14 days of `DailyActivityDoc`
- Identify modal windows (e.g. most common workout start hour ±1h)
- `flutter_local_notifications` already in pubspec — schedule dynamically
- Critical: exponential back-off if user ignores 3 in a row (never become spam)

---

## 5. Recovery & Readiness Score
**What it is:** A daily "readiness score" (0–100) calculated from sleep, HRV (from Health API), resting HR, workout load, and stress patterns.

**Why it magnets users:**
Whoop charges $30/month *just* for this number. Users become obsessed with their readiness score — it becomes the first thing they check in the morning, driving daily active use. No subscription needed here; the data is already flowing in via the `health` package.

**What it brings:**
- Single prominent number on the dashboard (replaces or augments the hero rings)
- Breakdown card: Sleep (40%), HRV (25%), Resting HR (20%), Workout Load (15%)
- Daily recommendation: "Easy day suggested — focus on mobility and nutrition"
- 7-day readiness trend

**UI/UX:**
- Hero card at top of dashboard: large circular gauge, color coded (green/yellow/red), number pulses in on load
- Score breakdown: horizontal bar per factor, each with an explanatory tooltip
- "Why?" button → bottom sheet with plain-English explanation from Gemini
- History: 7 small colored dots in a row (like GitHub contribution graph)
- Animation: gauge needle swings from 0 to score on first load

**Core after function:**
- `ReadinessCalculator` service: weighted formula, inputs from `HealthService` (HRV, resting HR, sleep stages) + `DailyActivityDoc` (workout intensity)
- Scores persisted in Isar so history survives without re-querying HealthKit
- Edge case: if HRV not available (non-Apple Watch), graceful degradation to sleep+HR only

---

## 6. Supplement & Medication Tracker
**What it is:** Log daily supplements and medications with dosage, timing, and reminders. AI detects potential interactions.

**Why it magnets users:**
80% of adults take at least one supplement. No major fitness app tracks this well — they all farm it out to separate pill reminder apps. Owning this in HealthAI creates a new daily active engagement loop that has zero competition in the fitness-first space.

**What it brings:**
- Supplement library with common items (Creatine, Vitamin D, Omega-3, Magnesium, etc.)
- Custom add: name, dosage, unit, timing (with meal / before bed / morning)
- Daily check-in: row of pill icons, tap to mark taken
- AI interaction check: "Creatine + caffeine — high doses may increase dehydration risk"
- Monthly adherence report

**UI/UX:**
- New tab or card on dashboard: "Supplements" with a pill-grid — each supplement as a small rounded chip, green when taken, grey when pending
- Add screen: clean form with animated stepper for dosage, time picker wheel
- Interaction warning: amber banner with icon, dismissible, links to "Ask AI" in chat
- Monthly report: calendar heat map (same style as habits) showing adherence %

**Core after function:**
- Isar collection: `SupplementDoc { name, dosageMg, unit, timingTags[], colorValue }`
- `SupplementLogDoc { date, supplementId, takenAt }`
- Gemini prompt: "Check interactions between: [list]" — run once when user modifies their stack
- Notification: scheduled per supplement timing, smart enough to not fire at 3am

---

## 7. Fasting Tracker
**What it is:** Intermittent fasting timer (16:8, 18:6, 5:2, custom) with metabolic state visualization.

**Why it magnets users:**
IF is the #1 diet trend globally. Zero, Fastic, and Simple collectively have 50M+ downloads. All three are single-purpose apps. HealthAI can absorb this entire use case — a user who fasts daily will open the app every single day just to see the timer.

**What it brings:**
- Start/stop fasting with one tap
- Live countdown timer showing current fasting window
- Metabolic phase indicator: Fed → Ketosis → Autophagy (with timeline visualization)
- Fasting history calendar
- Auto-syncs with calorie logs (fasting window suppresses calorie entry suggestions)

**UI/UX:**
- Dashboard card: circular countdown timer, glowing ring that fills as fast progresses
- Colors shift by phase: blue (fed) → amber (fat burning) → purple (autophagy)
- Phases shown as a horizontal timeline with labels and current position marker
- Start fasting: satisfying spring animation + gentle haptic rumble
- End fasting: confetti burst + "You fasted for X hours" achievement card
- History: calendar dots (color = phase reached)

**Core after function:**
- `FastingDoc { startTime, endTime, targetHours, protocolName }`
- State machine: `FastingState { notFasting, fed, fatBurning, deepKetosis, autophagy }` computed from elapsed time
- Live timer via `StreamProvider` with 1-second tick
- Persistent notification showing elapsed time while fasting (dismissible from notification)

---

## 8. Progress Photos & Visual Journey
**What it is:** Dated photo journal with before/after comparison, smart lighting suggestions, and private local storage.

**Why it magnets users:**
Transformation photos are the #1 content type shared from fitness apps (Instagram, Reddit r/fitness). If users can generate compelling before/after content directly in HealthAI, it becomes a *creation* tool — not just a tracking tool. Creation drives viral sharing which drives organic installs.

**What it brings:**
- Weekly photo prompt with consistent framing guide (ghost overlay of previous photo)
- Side-by-side and slider comparison (any two dates)
- AI-generated progress summary: "Over 8 weeks: estimated -3kg, visibly improved shoulder definition"
- Privacy-first: stored in app sandbox, never uploaded, optional local encryption
- Share as stylized card (weight change overlay, date range, app watermark)

**UI/UX:**
- Photo grid: masonry layout, each tile shows date + weight at that day
- Capture screen: ghost overlay of last photo at 30% opacity for consistent framing, grid lines, lighting score badge
- Comparison: fullscreen, vertical slider between two photos (native feel like iOS comparison tool)
- Share card: dark/light theme, gradient border, stats overlaid on blurred photo
- Onboarding tooltip: "Your photos never leave your device"

**Core after function:**
- Store photos in app documents directory (not gallery), path saved in Isar
- Thumbnail generation on save for grid performance
- Gemini Vision: analyze two photos for visible change description (optional, on-device preferred)
- Encryption: `encrypt` package, key stored in secure storage

---

## Priority Order (Impact vs. Effort)

| # | Feature | User Magnet Score | Build Complexity |
|---|---------|-------------------|------------------|
| 1 | Recovery & Readiness Score | ★★★★★ | Medium |
| 2 | Fasting Tracker | ★★★★★ | Low-Medium |
| 3 | AI Meal Planner | ★★★★★ | Medium |
| 4 | Body Composition Tracker | ★★★★☆ | Low |
| 5 | Smart Nudge AI | ★★★★☆ | Medium |
| 6 | Supplement Tracker | ★★★☆☆ | Low |
| 7 | Progress Photos | ★★★☆☆ | Medium |
| 8 | Social Layer | ★★★★★ | High (needs backend) |

**Recommended build order:**
`Fasting Tracker` → `Body Composition` → `Supplement Tracker` → `Readiness Score` → `AI Meal Planner` → `Nudge AI` → `Progress Photos` → `Social`

Start with the three low-complexity ones to ship fast, get reviews, and build momentum before the harder infrastructure work.

---

## Shared Infrastructure Needed

1. **Supabase backend** — required for Social, Nudge AI cloud sync, and cross-device data
2. **Push notifications (FCM)** — for social cheers, nudges, streak alerts
3. **Gemini Vision** — already configured, needed for Meal Planner and Progress Photos AI
4. **BLE support** (`flutter_blue_plus`) — for smart scale and HRV device integration
5. **Encryption** (`encrypt` + `flutter_secure_storage`) — for Progress Photos privacy

---

*Every feature above reuses the existing Isar database, Riverpod state, Gemini API, and design system — no architectural changes needed. They slot directly into the current shell navigation.*
