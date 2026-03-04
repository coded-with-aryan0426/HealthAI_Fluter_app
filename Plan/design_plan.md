# HealthAI — Ultra-Detailed UI/UX Redesign System
### Senior Product Designer · Mobile UI/UX Architect · Motion Designer · Flutter Engineer
### Version 2.0 — Full Wireframes · Color Plates · Section Outcomes · Micro-Details

---

## TABLE OF CONTENTS

1. [Current State Audit](#1-current-state-audit)
2. [Design Vision & Inspiration](#2-design-vision--inspiration)
3. [Complete Design Token System](#3-complete-design-token-system)
4. [Motion System — Full Specification](#4-motion-system--full-specification)
5. [Interaction Design — Complete Matrix](#5-interaction-design--complete-matrix)
6. [Screen-by-Screen Redesign with Wireframes](#6-screen-by-screen-redesign-with-wireframes)
   - 6.1 Dashboard Screen
   - 6.2 Navigation System
   - 6.3 Workout Feature (Library · Player · Summary)
   - 6.4 Nutrition Screen
   - 6.5 Habits Screen
   - 6.6 Chat Screen
   - 6.7 Settings Screen
7. [Performance Strategy](#7-performance-strategy)
8. [Implementation Guide](#8-implementation-guide)
9. [Priority Implementation Order](#9-priority-implementation-order)

---

## 1. Current State Audit

### What currently exists (code-verified)

| Widget / Component | File | Status |
|---|---|---|
| `AppAnimatedPressable` | `app_ui.dart:32` | Excellent — pressScale 0.95, 130ms, Curves.easeInOut |
| `AppGlassCard` | `app_ui.dart:112` | Good — BackdropFilter blur 12, adaptive borders |
| `AppSectionHeader` | `app_ui.dart:184` | Weak — accent dash identical across all sections |
| `AppGradientButton` | `app_ui.dart` | Good base |
| `AppShimmer` | `app_ui.dart` | Present |
| `_BentoCard` number | `dashboard_screen.dart:957` | **30px** bold — undersized on modern displays |
| `_BentoCard` progress | `dashboard_screen.dart:990` | **4px** height — near invisible |
| `_WaterTrackerCard` progress | `dashboard_screen.dart:527` | **10px** height — adequate but flat |
| Active workout barbell | `dashboard_screen.dart:1469` | Has `.scaleXY(0.9→1.05)` pulse ✓ |
| `_AiInsightCard` icon | `dashboard_screen.dart:1292` | Uses `Icons.auto_awesome` — Mixed icon library ⚠ |
| `_AiInsightCard` button | `dashboard_screen.dart:1360` | Uses `Icons.chat_bubble_outline_rounded` — Mixed ⚠ |
| `HeroActivityRings` | `dashboard/widgets/hero_activity_rings.dart` | Exists but rings need celebration logic |
| Chat send button | `chat_screen.dart:1229` | `PhosphorIconsFill.paperPlaneRight` ✓ |
| Chat input border | `chat_screen.dart:1019` | Animates to `AppColors.softIndigo` on text input ✓ |
| `_AiLogoWidget` | `chat_screen.dart:1251` | Breathing scale 1.0→1.04 @ 2400ms repeat ✓ |
| `_NeuralIconPainter` | `chat_screen.dart:1343` | CustomPaint neural network ✓ |
| Listening banner pulse dot | `chat_screen.dart:406` | Fade repeat ✓ |
| Scroll-down FAB | `chat_screen.dart:324` | `easeOutBack` scale entrance ✓ |
| Habit icons | `habits_screen.dart` | Full Phosphor icon mapping ✓ |
| Category colors | `habits_screen.dart:70` | 6 categories with hex values ✓ |
| `_UpcomingHabitsBanner` | `dashboard_screen.dart:1037` | Plain list rows — no burst animation |
| `BouncingScrollPhysics` | `app_ui.dart:24` | `decelerationRate: fast` ✓ |

### Dead zones — exact code locations

| Problem | Exact Location | Visual Impact |
|---|---|---|
| `mainValue` font **30px** (line 957) — too small for 6.7" screens | `_BentoCard.build` | Numbers fail to command attention |
| Progress bars **4px** (line 999) in bento cards | `_BentoCard` Stack | Nearly invisible, conveys no urgency |
| `Icons.auto_awesome` mixed with Phosphor (line 1292) | `_AiInsightCard` | Visual incoherence — two icon styles in same card |
| Uniform fade-in on ALL bento cards simultaneously (lines 833-869) | `_BentoGrid.build` | Mass appears — no cascade, no life |
| `_UpcomingHabitsBanner` tap = toggle but no animation on the row | line 1151 | Completing feels like tapping a link, not an achievement |
| Water progress `10px` single-color fill (line 527) | `_WaterTrackerCard` | Low impact; goal completion has no celebration |
| Weekly banner is a static rectangle with icons (line 1539–) | `_WeeklyBanner` | No data visualization; missed opportunity |
| `_AiInsightCard` text loads instantly — no typewriter | line 1326 | AI feels like a database lookup, not intelligence |
| Chat welcome: plain `RadialGradient` bg, no particles | `chat_screen.dart:251` | Static; contradicts the "living AI" premise |
| `AppSectionHeader` accent dash — same on every screen | `app_ui.dart:184` | All sections feel identical; hierarchy lost |
| Bento grid: 3 uniform 2-column rows | `_BentoGrid.build` | No flagship metric; everything equal weight |

---

## 2. Design Vision & Inspiration

> **"The app should feel like premium gym glass — transparent, sharp, illuminated from within."**

### Inspiration Breakdown

| Source | What We Take | What We Don't Take |
|---|---|---|
| **Apple Fitness+** | Ring animations, workout player polish, celebration moments, JetBrains Mono timer | Dense UI, fitness-only focus |
| **Swiggy** | Scrollable pill tabs with calorie sub-labels, gradient food cards, bottom-anchored CTA | Aggressive orange color overuse |
| **Uber** | Live timer feeds, real-time data updates, dark mode excellence, sparse layout | Map-heavy design patterns |
| **Airbnb** | Hero cards with generous whitespace, mesh gradient photography treatment | Travel-specific photo grids |
| **Material Design 3** | Dynamic color seeding via `ColorScheme.fromSeed`, elevation + shadow tokens | Tonal fills that clash with dark obsidian |

---

## 3. Complete Design Token System

### 3.1 Color System — Full Plate

#### Dark Mode Palette

```
┌─────────────────────────────────────────────────────────────────┐
│                    DARK MODE COLOR PLATE                        │
├─────────────────────────────────┬───────────────────────────────┤
│  BACKGROUND LAYERS              │  HEX         USAGE            │
│  Ground (page bg)               │  #080B12     deepObsidian     │
│  Warm surface (new)             │  #0E0C15     warmObsidian     │
│  Card surface                   │  #141720     charcoalCard     │
│  Card hover / active            │  #1A1D2A     charcoalGlass    │
│  Elevated sheet                 │  #1E2130     charcoalElevated │
│  Modal overlay                  │  #000000@60% barrier          │
├─────────────────────────────────┼───────────────────────────────┤
│  ACCENT COLORS                  │  HEX         USAGE            │
│  Primary CTA                    │  #00D4B2     dynamicMint      │
│  AI / Secondary                 │  #6B7AFF     softIndigo       │
│  Celebration / Streak           │  #FFB347     amberGlow (NEW)  │
│  Heart Rate / Body              │  #FF6B9D     roseAccent (NEW) │
│  Water / Hydration              │  #41C9E2     skyBlue          │
│  Warning                        │  #F59E0B     warning (amber)  │
│  Danger / Workout               │  #FF3D3D     danger (red)     │
│  Sleep                          │  #8B5CF6     purple           │
│  Nutrition                      │  #10B981     green            │
├─────────────────────────────────┼───────────────────────────────┤
│  TEXT                           │  HEX         USAGE            │
│  Primary text                   │  #FFFFFF@95% darkTextPrimary  │
│  Secondary text                 │  #FFFFFF@50% darkTextSecondary│
│  Disabled text                  │  #FFFFFF@28% dimmed           │
│  Label / ALL CAPS               │  accent@80%  label color      │
├─────────────────────────────────┼───────────────────────────────┤
│  BORDERS / DIVIDERS             │  HEX         USAGE            │
│  Subtle card border             │  #FFFFFF@6%  standard card    │
│  Active border                  │  accent@40%  selected state   │
│  Danger border                  │  #FF3D3D@30% error state      │
└─────────────────────────────────┴───────────────────────────────┘
```

#### Light Mode Palette

```
┌─────────────────────────────────────────────────────────────────┐
│                    LIGHT MODE COLOR PLATE                       │
├─────────────────────────────────┬───────────────────────────────┤
│  BACKGROUND LAYERS              │  HEX         USAGE            │
│  Ground (page bg)               │  #F7F8FC     cloudGray        │
│  Card surface                   │  #FFFFFF     pureWhite        │
│  Card active / hover            │  #F0F2FF     softLavender     │
│  Section header bg              │  #FFFFFF@90% frosted          │
├─────────────────────────────────┼───────────────────────────────┤
│  TEXT                           │  HEX         USAGE            │
│  Primary text                   │  #1C1E23     lightTextPrimary │
│  Secondary text                 │  #1C1E23@55% lightTextSecond  │
│  Disabled text                  │  #1C1E23@30% dimmed           │
└─────────────────────────────────┴───────────────────────────────┘
```

#### Per-Feature Gradient Plates

```
WORKOUT GRADIENTS
  Active banner:     #FF6B35 → #FF3D3D  (left→right, topLeft→bottomRight)
  Strength card:     #FF3D3D → #FF6B35
  Cardio card:       #FF6B35 → #F59E0B
  Rest card:         #8B5CF6 → #6B7AFF

NUTRITION GRADIENTS
  Calories ring:     #F59E0B → #FFD700  (arc gradient via SweepGradient)
  Protein ring:      #FF3D3D → #FF6B35
  Carbs ring:        #10B981 → #00D4B2
  Fat ring:          #6B7AFF → #8B5CF6
  Add food button:   #10B981 → #00D4B2

WATER GRADIENTS
  Progress fill:     #41C9E2 → #00B4D8  (left→right)
  Card background:   #1A2A3A → #0D1B2A  (dark) / #E0F7FF → #B3E5FC (light)

HABITS GRADIENTS
  Streak banner:     #FFB347 → #FF8C42  (warm amber, streak > 0)
  Zero-streak:       #4A5568 → #2D3748  (cool slate, streak = 0)
  Fitness category:  #6366F1 → #8B5CF6
  Nutrition cat:     #10B981 → #00D4B2
  Mental cat:        #8B5CF6 → #A855F7
  Sleep cat:         #06B6D4 → #6B7AFF

AI / CHAT GRADIENTS
  Send button:       #6B7AFF → #00C2A8  (topLeft→bottomRight) ✓ existing
  AI logo inner:     #6B7AFF → #00D4B2  ✓ existing
  Insight card left: #6B7AFF → #00D4B2  (3px left-edge pulse strip, NEW)
  Welcome header:    #1A1D35 → #080B12  RadialGradient center:(0,-0.6) ✓

DASHBOARD GRADIENTS
  Hero card bg:      Mesh — two radial orbs: mint@15% + indigo@12%
  Weekly bar chart:  Current day bar: #00D4B2 → #6B7AFF
                     Past bars:       #FFFFFF@15% dark / #000000@8% light
  Bento sleep:       #6B7AFF → #9B59B6
  Bento steps:       #00D4B2 → #00B4D8
  Bento protein:     #FF3D3D → #FF6B35
  Bento calories:    #F59E0B → #FFD700
  Bento heartrate:   #FF3D3D → #FF6B35
  Bento distance:    #00C9A7 → #00B4D8
```

---

### 3.2 Typography System — Full Scale

```
FONT FAMILIES
  Display / Body:  Inter (already in assets/fonts/) — keep
  Timers / Live:   JetBrains Mono — ADD to pubspec.yaml for workout timer,
                   live step count, calorie counters

SCALE (line-height = size × 1.2 for display, × 1.5 for body)
  ┌────────────┬────────┬────────┬──────────────┬──────────────────────────────────┐
  │ Name       │ Size   │ Weight │ LetterSpacing │ Usage                            │
  ├────────────┼────────┼────────┼──────────────┼──────────────────────────────────┤
  │ Display XL │ 40px   │ w900   │ -1.2         │ Ring center values, hero metrics │
  │ Display L  │ 32px   │ w800   │ -0.8         │ Screen titles, celebration nums  │
  │ Display M  │ 26px   │ w700   │ -0.5         │ Bento card values (UP from 30px) │
  │            │        │        │              │ NOTE: 26px Inter w700 renders    │
  │            │        │        │              │ LARGER than 30px w400 due to     │
  │            │        │        │              │ weight — bold is visually bigger │
  │ Headline   │ 22px   │ w700   │ -0.3         │ Section titles, sheet headers    │
  │ Title      │ 18px   │ w600   │ -0.2         │ Card headers, bottom sheet title │
  │ Body L     │ 16px   │ w500   │  0.0         │ Primary body, button labels      │
  │ Body M     │ 14px   │ w400   │  0.1         │ Secondary body, insight text     │
  │ Caption    │ 12px   │ w500   │  0.3         │ Chip labels, timestamps, units   │
  │ Label      │ 10px   │ w700   │  1.0–1.5     │ ALL CAPS micro-labels (existing) │
  │ Micro      │  9px   │ w800   │  1.5         │ Badge text only                  │
  └────────────┴────────┴────────┴──────────────┴──────────────────────────────────┘

MONOSPACE (JetBrains Mono — add to pubspec.yaml)
  Timer large:   28px w700 letterSpacing: 2.0  — workout elapsed timer
  Timer small:   20px w600 letterSpacing: 1.5  — rest countdown
  Metric live:   22px w700 letterSpacing: 0.5  — step count live updates

GRADIENT TEXT (ShaderMask — already used in chat welcome)
  Hero headlines: LinearGradient([softIndigo, dynamicMint]) — Chat, Workout Summary
  Achievement:    LinearGradient([amberGlow, warning])       — Trophy modal
```

---

### 3.3 Spacing System

```dart
class AppSpacing {
  static const double xs     =  4.0;   // icon internal gap
  static const double sm     =  8.0;   // chip internal, row gap
  static const double md     = 12.0;   // card internal top/bottom
  static const double base   = 16.0;   // standard card padding
  static const double lg     = 20.0;   // card generous internal
  static const double xl     = 24.0;   // horizontal page margin ✓ existing
  static const double xxl    = 28.0;   // between major sections
  static const double xxxl   = 32.0;   // hero section separation
  static const double huge   = 40.0;   // hero breathing room
  static const double giant  = 56.0;   // bottom safe zone above nav
  static const double navBar = 84.0;   // nav bar total height
}
```

---

### 3.4 Elevation & Shadow Tokens

```
Layer 0 — Ground      shadow: none                           page bg
Layer 1 — Card        dark:  0 8 20 #000000@6% + accent@8%  standard cards
                      light: 0 8 20 #000000@6%
Layer 2 — Raised      dark:  0 12 28 #000000@25%             hero cards
                      light: 0 12 28 #000000@10%
Layer 3 — Floating    dark:  0 16 40 accent@25%              FAB, active nav, sheet
                      light: 0 16 40 accent@18%
Layer 4 — Modal       dark:  0 24 60 #000000@35%             bottom sheets, dialogs
                      light: 0 24 60 #000000@20%

GLOW SHADOWS (colored — used on accent elements)
  Mint glow:   BoxShadow(color: #00D4B2@35%, blurRadius: 16, offset: (0,6))
  Indigo glow: BoxShadow(color: #6B7AFF@35%, blurRadius: 16, offset: (0,6))
  Amber glow:  BoxShadow(color: #FFB347@40%, blurRadius: 14, offset: (0,5))
  Red glow:    BoxShadow(color: #FF3D3D@35%, blurRadius: 16, offset: (0,6))
  Water glow:  BoxShadow(color: #41C9E2@35%, blurRadius: 14, offset: (0,5))
```

---

### 3.5 Component Library — New Components

#### A. `AppMetricDisplay` — Animated count-up metric

```dart
// lib/src/theme/app_metrics.dart
// Used for: bento card values, ring centers, celebration numbers

class AppMetricDisplay extends StatelessWidget {
  final double value;         // target value
  final String unit;          // 'kcal', 'steps', 'hrs'
  final TextStyle? valueStyle;
  final TextStyle? unitStyle;
  final Duration duration;    // count-up duration
  final bool animated;        // false = static for tests

  // FINAL OUTCOME:
  //   A number that counts from 0.0 to [value] over [duration]
  //   Unit appears as a smaller suffix in accent color
  //   TweenAnimationBuilder<double> drives the count
  //   Uses JetBrains Mono when [mono] is true
}
```

#### B. `AppRingStack` — Concentric activity rings

```dart
// Three concentric arcs: outer (calories), middle (exercise), inner (stand)
// Each ring: CustomPainter with SweepGradient paint
// Staggered animation: outer starts at 0ms, middle at 200ms, inner at 400ms
// Center: dominant metric in Display XL
// On 100%: flash → particle burst from ring endpoint
// FINAL OUTCOME: Matches Apple Fitness ring quality on first render
```

#### C. `AppPillTabBar` — Swiggy-style scrollable pills

```dart
// Horizontal scroll, no overflow indicator from Flutter
// Selected pill: gradient fill (#6B7AFF → #00D4B2), white text, scale 1.05
// Unselected pill: transparent fill, border 1px at #FFFFFF@20%
// Sub-label: calorie total shown as smaller text below pill name
// Transition: color slides from left to right over 180ms (ClipRect + alignment)
// FINAL OUTCOME: Category switching feels instant, tactile, premium
```

#### D. `AppCelebration` — Particle burst overlay

```dart
// Triggered via: AppCelebration.trigger(context, origin: tapOffset)
// 12 dots, radii 2–5px, velocity fan 0–360°
// Colors: mix of [accent, white, accent.lighten(20%)]
// Physics: initial velocity + gravity (vy += 0.3 per frame)
// Life: 400ms total, opacity = life remaining
// CustomPainter with TickerProvider — single canvas, no widget tree
// FINAL OUTCOME: Completing a habit or closing a ring feels like confetti
```

#### E. `AppWeeklyBarChart` — 7-day mini bar chart

```dart
// CustomPaint: 7 bars, each bar height proportional to value/maxValue
// Bar width: (availableWidth - 6 * gapWidth) / 7
// Current day bar: gradient fill + glow shadow + 1px white top cap
// Past bars: #FFFFFF@15% dark / #000000@8% light
// Future bars: not rendered (greyed outline only)
// Animation: bars grow from 0 height on reveal (TweenAnimationBuilder)
// FINAL OUTCOME: At-a-glance weekly trend without leaving dashboard
```

---

## 4. Motion System — Full Specification

### 4.1 Duration & Curve Tokens

```dart
class AppDurations {
  // Press feedback
  static const xfast  = Duration(milliseconds: 100);
  // Icon swap, state micro
  static const fast   = Duration(milliseconds: 150);
  // State transitions, chip selection
  static const normal = Duration(milliseconds: 250);
  // Card reveals, skeleton dissolves
  static const slow   = Duration(milliseconds: 380);
  // Page transitions
  static const page   = Duration(milliseconds: 420);
  // Hero entrances, bottom sheet
  static const long   = Duration(milliseconds: 600);
  // Ring fill, activity arc
  static const ring   = Duration(milliseconds: 1400);
  // Count-up number animations
  static const count  = Duration(milliseconds: 1200);
  // Idle float cycle
  static const float  = Duration(milliseconds: 3000);
  // Typewriter: 18ms per character
  static const typewriterChar = Duration(milliseconds: 18);
}

class AppCurves {
  // Bouncy icon transitions, chip pops
  static const pop      = Curves.easeOutBack;
  // Card reveals, page slides
  static const slide    = Curves.easeOutCubic;
  // State changes, tab switches
  static const settle   = Curves.easeInOutCubic;
  // Celebration elements only (springs)
  static const spring   = Curves.elasticOut;
  // Progress fills, ring arcs
  static const smooth   = Curves.fastEaseInToSlowEaseOut;
  // Idle animations
  static const breathe  = Curves.easeInOut;
}
```

---

### 4.2 Page Transitions — Complete Specification

```
STANDARD SCREEN PUSH (→ any feature screen)
  Direction:    slide up + fade
  begin:        Offset(0, 0.06)
  end:          Offset.zero
  slide curve:  Curves.easeOutCubic / 380ms
  fade curve:   Curves.easeOut / 280ms
  Trigger:      context.push() / context.go()

MODAL / SHEET SCREENS (workout player, food detail, habit edit)
  Direction:    slide up from bottom
  begin:        Offset(0, 1.0)
  end:          Offset.zero
  curve:        Curves.easeOutCubic / 400ms
  reverse:      Curves.easeInCubic / 320ms

BACK NAVIGATION
  Direction:    slide down + fade
  begin:        Offset.zero
  end:          Offset(0, 0.04)
  curve:        Curves.easeInCubic / 280ms

HERO CONTINUITY (specific flows)
  Workout card → Workout Player:
    Hero tag:   'workout_title_${workout.id}'
    Widget:     Text(workout.title) wrapped in Hero()
    Flight:     default hero flight, 420ms

  Meal item → Meal Detail:
    Hero tag:   'meal_calories_${meal.id}'
    Widget:     calorie badge container

  Habit card → Habit Detail:
    Hero tag:   'habit_streak_${habit.id}'
    Widget:     streak number Text widget
```

---

### 4.3 All Micro-Interactions — Complete Specifications

#### MI-01: Habit Completion Burst
```
TRIGGER:    User taps habit checkbox (or swipes right)
SEQUENCE:
  T+0ms:    HapticFeedback.mediumImpact()
  T+0ms:    Checkbox circle: AnimationController.forward()
             scale: 1.0 → 0.0 → 1.2 → 1.0 (spring, 300ms total)
             Implement with TweenSequence:
               0-40%:  scale 1.0 → 0.0 (Curves.easeIn)
               40-80%: scale 0.0 → 1.2 (Curves.easeOutBack)
               80-100%:scale 1.2 → 1.0 (Curves.easeOut)
  T+80ms:   Checkmark path draws in via PathMetric.extractPath
             duration: 220ms, Curves.easeOut
  T+120ms:  8 dot particles burst from tap point
             CustomPainter(_ParticleBurst), 400ms, fan 0-360°
             colors: [habit.colorValue, habit.colorValue@60%, white]
  T+150ms:  Row background floods from left:
             AnimatedContainer width: 0 → double.infinity
             color: habit.colorValue@12%, duration: 500ms, Curves.easeOut
  T+450ms:  Strikethrough text animation:
             Custom TextPainter overlay, line draws left→right, 300ms
  T+600ms:  Row slides to bottom of list:
             AnimatedList remove + insert at end, 400ms slide

CANCEL (if un-tapping):
  Row background fades out, strikethrough reverses, checkbox reverses
```

#### MI-02: Ring Completion Celebration
```
TRIGGER:    Any activity ring value reaches >= 1.0
SEQUENCE:
  T+0ms:    HapticFeedback.heavyImpact()
  T+0ms:    Ring flash: opacity 1.0 → 0.5 → 1.0 → 0.6 → 1.0 (TweenSequence)
             2 flash cycles, 200ms each
  T+100ms:  16 particles burst from ring endpoint position
             Endpoint calc: center + Offset(cos(progress*2π), sin(progress*2π)) * radius
             CustomPainter(_RingBurst), 600ms
  T+200ms:  Center metric value: scale 1.0 → 1.12 → 1.0, spring, 400ms
  T+200ms:  Ring color brightens: .withValues(alpha: 1.0) sustained for 800ms
             then settles back to normal
OUTCOME:    User feels accomplishment; rings feel alive, not just progress bars
```

#### MI-03: Message Send
```
TRIGGER:    User taps send button (PhosphorIconsFill.paperPlaneRight)
SEQUENCE:
  T+0ms:    HapticFeedback.lightImpact() (existing ✓)
  T+0ms:    Send button: rotate 0° → 45° + scale 1.0 → 0.0, 200ms Curves.easeIn
  T+180ms:  Send button dissolves (opacity 0)
  T+0ms:    Input text: slideY 0 → -8px + opacity 1.0 → 0.0, 150ms
  T+0ms:    Input border: flash #6B7AFF @ alpha 0.8, then settle to 0.6, 300ms
  T+100ms:  User bubble: slideX(begin: 0.15, end: 0) + fadeIn, 250ms easeOutCubic
  T+100ms:  Typing indicator: appears from left + fadeIn, 180ms
OUTCOME:    Message feels physically "sent" — like paper flying away
```

#### MI-04: Water Add (+250ml / +500ml)
```
TRIGGER:    Tap +250ml or +500ml button
SEQUENCE:
  T+0ms:    HapticFeedback.selectionClick() (existing ✓)
  T+0ms:    Tapped button: scale 0.92, 100ms
  T+100ms:  Button: scale back 1.0 with easeOutBack, 180ms
  T+0ms:    Progress bar: TweenAnimationBuilder to new percent, 1200ms smooth ✓
  T+0ms:    Water ml number: count-up from old to new value, 800ms
  T+80ms:   Drop icon: scale 1.0 → 0.7 → 1.15 → 1.0, spring, 350ms
  IF GOAL REACHED (percent >= 1.0):
  T+200ms:  Blue ripple: circular expand from bar center
             CustomPainter, radius 0 → barWidth/2, 400ms
  T+400ms:  Bar color: subtle wave shimmer sweeps left→right, 600ms
  T+400ms:  AppCelebration.trigger(context, origin: barCenter)
  T+400ms:  HapticFeedback.heavyImpact()
  T+600ms:  SnackBar: "Hydration Goal! 💧" slides down from top
OUTCOME:    Logging water feels rewarding; goal hit is a memorable moment
```

#### MI-05: Input Focus (Chat + any TextField)
```
TRIGGER:    TextField receives focus
SEQUENCE:
  T+0ms:    Container border: 1px neutral → 1.5px #6B7AFF@60%, 200ms
  T+0ms:    Glow shadow appears: #6B7AFF@22% blurRadius 20, 200ms
             (AnimatedContainer with boxShadow)
  T+0ms:    Placeholder text: opacity 1.0 → 0.4, slight slideY -2px, 150ms
TRIGGER:    TextField loses focus
  T+0ms:    Border, glow, placeholder all reverse at 180ms
OUTCOME:    Text fields feel responsive, context-aware, not generic
```

#### MI-06: Pull-to-Refresh (Custom)
```
Replace default RefreshIndicator on Dashboard and Nutrition screens

SEQUENCE:
  Pull 0px:    Nothing
  Pull 1-40px: AI sparkle icon appears at 0% scale, fades in proportional to pull
  Pull 41-70px:Icon scales 0.5 → 0.9, begins rotating (proportional to pull delta)
  Pull 71-90px:Icon at 1.0 scale, pulse ring starts expanding
  Pull 90px+:  Spring overshoot indicator — icon at 1.1 scale, ring at max
  Release:     Spinner ring (gradient sweep) plays, 900ms
  Complete:    Checkmark draws in, 300ms → dissolves, 200ms
  Icon colors: gradient #6B7AFF → #00D4B2 matching AI theme

IMPLEMENTATION:
  NotificationListener<OverscrollNotification> wrapping CustomScrollView
  Track overscrollDelta to drive indicator position/scale
```

#### MI-07: Skeleton → Content Dissolve
```
Every async widget pattern:
  STATE 1 (loading):
    AppShimmer skeleton renders immediately
    shimmer plays continuously ✓ existing

  STATE 2 (data arrives):
    Skeleton: fadeOut 200ms
    Content: fadeIn 300ms + slideY(begin: 0.08, end: 0), 300ms
    Stagger if multiple items: 40ms between items

  STATE 3 (error):
    Content: shake animation
    Horizontal oscillation: -6 → +6 → -4 → +4 → -2 → +2 → 0
    Duration: 400ms total, Curves.elasticOut
    Error color tint: card border turns #FF3D3D@40%

OUTCOME: Data arrival feels organic; errors are communicated without modals
```

#### MI-08: Bento Card Staggered Entrance
```
CURRENT: All 6 cards fade in with 80ms stagger (exists)
UPGRADE:
  Each card: fadeIn(delay: i*60ms) + slideY(begin:0.15, end:0, delay: i*60ms)
  Card 0 (Sleep):    delay 0ms
  Card 1 (Steps):    delay 60ms
  Card 2 (Protein):  delay 120ms
  Card 3 (Calories): delay 180ms
  Card 4 (Heart):    delay 240ms
  Card 5 (Distance): delay 300ms

  ADDITIONALLY: Scale from 0.95 → 1.0 on entrance
  TOTAL: fadeIn + slideY + scaleXY, all 500ms duration ✓ already close
  Remove: simultaneous renders at same delay (current issue)

OUTCOME: Dashboard builds like a visual reveal, left→right, top→bottom
```

#### MI-09: Nav Item Press
```
EXISTING: scale → 0.82, easeOutBack ✓
ADD:
  T+0ms:    Scale 0.82 (existing ✓)
  T+0ms:    Sliding indicator line (3px gradient) animates to new item:
            AnimationController drives indicator X position
            Spring physics: CustomTween with spring simulation
            Duration: 400ms easeOutBack
  T+0ms:    Previous item: icon swaps Fill → Regular (Phosphor Fill/Regular)
  T+0ms:    New item: icon swaps Regular → Fill

OUTCOME: Nav tab switching feels physicaly connected via the sliding line
```

#### MI-10: Typewriter AI Insight
```
TRIGGER:    dailyInsightProvider delivers text data
SEQUENCE:
  T+0ms:    Skeleton dissolves (see MI-07)
  T+0ms:    _displayed = '' (empty string in state)
  T+0ms:    Timer.periodic(18ms) increments character index
  Every 18ms: setState(() => _displayed = full.substring(0, ++i))
              This re-renders only the Text widget (not the entire card)
  End:      Timer cancels at full.length
  Cursor:   '|' appended to _displayed while typing (blinks at 500ms interval)
  Speed:    18ms/char = ~56 chars/sec = premium feel (not too fast, not slow)

PERFORMANCE NOTE:
  Use a separate StatefulWidget (_TypewriterText) so the Timer's setState
  only rebuilds that small Text widget, not the entire _AiInsightCard

OUTCOME: AI insight feels like it's being composed live — intelligence, not lookup
```

---

## 5. Interaction Design — Complete Matrix

### 5.1 Tap / Gesture Matrix

```
┌─────────────────────────┬────────────────────────┬──────────────────────────┬──────────────────────────┐
│ Element                 │ Single Tap             │ Long Press               │ Swipe                    │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Bento card (any)        │ Navigate to feature    │ Quick-add sheet          │ —                        │
│                         │ Spring scale 0.95      │ (water/steps/sleep)      │                          │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Habit row checkbox      │ Toggle complete        │ Edit habit bottom sheet  │ Right = complete (green) │
│                         │ MI-01 burst animation  │                          │ Left = delete (red zone) │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Water progress bar      │ +250ml (anywhere)      │ Custom amount sheet      │ —                        │
│                         │ MI-04 animation        │                          │                          │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Meal log item           │ Expand portion row     │ Edit sheet               │ Left = delete red zone   │
│                         │ AnimatedSize reveal    │                          │                          │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Chat bubble (AI)        │ Nothing                │ Copy + Share sheet       │ —                        │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Chat bubble (user)      │ Nothing                │ Delete message confirm   │ —                        │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Workout set row         │ Mark complete          │ Edit reps/weight inline  │ —                        │
│                         │ Green fill + checkmark │                          │                          │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Activity ring segment   │ Tooltip expands        │ Full breakdown sheet     │ —                        │
│                         │ AnimatedSize tooltip   │                          │                          │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ AI Insight card         │ Expand full text       │ Copy insight text        │ —                        │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Weekly banner           │ Navigate /weekly       │ —                        │ —                        │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Workout exercise card   │ Expand video/GIF       │ Swap exercise            │ Left/Right = prev/next   │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Nutrition day pill      │ Select date            │ —                        │ —                        │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ Streak flame icon       │ View streak details    │ —                        │ —                        │
├─────────────────────────┼────────────────────────┼──────────────────────────┼──────────────────────────┤
│ FAB (AI Coach)          │ Open chat              │ Show tooltip             │ —                        │
│                         │ Spring scale entrance  │ "Chat with your coach"   │                          │
└─────────────────────────┴────────────────────────┴──────────────────────────┴──────────────────────────┘
```

### 5.2 Scroll Behavior Matrix

```
DASHBOARD
  0–60px scroll:    Header greeting fades (opacity 1→0), name scales 20px→16px
  60–120px scroll:  AppBar background opacity increases to 0.92 (glassmorphic)
  0px scroll:       AppBar at 0.85 opacity (current ✓)
  Past 200px:       FAB label "AI Coach" fades out (Text opacity 1→0)
  Scroll up >50px:  FAB label fades back in
  Card enters view: fadeIn + slideY once per card (VisibilityDetector)

NUTRITION
  Header macro rings: SliverPersistentHeader, floating:true — always visible
  Meal tab strip:     SliverPersistentHeader, pinned:true — sticks below rings
  Food log:           SliverList.builder — only visible items built

CHAT
  Scroll down >80px from bottom: scroll-down FAB appears (existing ✓)
  Scroll up:                     scroll-down FAB stays visible
  At bottom:                     scroll-down FAB disappears (existing ✓)
  New message arrives:           auto-scroll to bottom (existing ✓)

HABITS
  Streak banner:    Collapses from 100px → 60px as user scrolls down 50px
  Category tabs:    SliverPersistentHeader, pinned — always visible
  Habit cards:      Reveal stagger as they enter viewport

WORKOUT LIBRARY
  Category tabs:    SliverPersistentHeader floating — sticks at top
  Program cards:    Reveal stagger on scroll
```

---

## 6. Screen-by-Screen Redesign with Wireframes

---

### 6.1 Dashboard Screen

#### Color Plate

```
Dark mode:
  Page bg:          #080B12  (deepObsidian)
  AppBar bg:        #080B12@85% + BackdropFilter(blur:16)
  Card surfaces:    #141720  (charcoalCard)
  Hero ring area:   Warm radial gradient bg: #12101A→#080B12

Light mode:
  Page bg:          #F7F8FC
  AppBar bg:        #FFFFFF@85% + BackdropFilter(blur:16)
  Card surfaces:    #FFFFFF
```

#### Final Outcome Description

The Dashboard should feel like opening a premium health cockpit. The first scroll-down reveals the activity rings with a staggered cascade of colored light — outer ring fills first, then middle, then inner, each with its own glow. Below sits the water card with a thick, glowing progress bar that feels physical. The AI insight card appears to "type itself" letter by letter, as if the coach is composing a thought for you. The bento grid builds card by card from top-left to bottom-right, each appearing with a satisfying spring. The entire screen feels alive and responds to every touch with immediate, physical feedback.

#### Annotated Wireframe

```
┌─────────────────────────────────────────────┐  ← Status bar (system)
│ ████████████████████████████████████████    │
├─────────────────────────────────────────────┤  ← SliverAppBar (pinned, 72px)
│ Good Morning,           ☀️  [AVATAR]         │    bg: deepObsidian@85% + blur:16
│ Alex                                         │    Left: greeting column (20px bold)
│─────────────────────────────────────────────│    Right: theme toggle (38px circle) + avatar (38px)
│                          12px top padding    │
│  ┌───────────────────────────────────────┐  │  ← _WelcomeBanner (dismissible, first-use only)
│  │ 🌟  Welcome back! Ready to crush it?  │  │    height: 48px, gradient border
│  │ [Dismiss ×]                           │  │    CHANGE: make dismissible with horizontal swipe
│  └───────────────────────────────────────┘  │
│                                             │
│  ┌─────────────────────── ACTIVE WORKOUT ──┐│  ← _ActiveWorkoutBanner (conditional)
│  │ 🏋️  Push Day A          00:24:38        ││    height: 72px
│  │     Exercise 3 of 8  ░░░░░░░▓▓▓ 40%   ││    bg: gradient #FF6B35→#FF3D3D
│  │     Currently: Bench  [RESUME]         ││    NEW: add "Exercise N of M" + mini progress bar
│  └─────────────────────────────────────────┘│
│                                             │
│  ┌─────────────── TODAY'S HABITS ─── 3 left┐│  ← _UpcomingHabitsBanner
│  │ [🏃 Morning Run    ○] [🧘 Meditate   ○]  ││    CHANGE: compact horizontal chip scroll
│  │ [💊 Vitamins       ○] + 2 more →        ││    Each chip: 36px height, gradient border
│  └─────────────────────────────────────────┘│    Chip tap = MI-01 burst inline
│                                             │
│         ┌─────── ACTIVITY RINGS ───────┐    │  ← HeroActivityRings (200px outer radius)
│         │                              │    │    Stagger: outer 0ms / mid 200ms / inner 400ms
│         │   ╔════════════════════╗     │    │    Center: Display XL metric (40px w900)
│         │   ║  ╔══════════╗      ║     │    │    Ring colors:
│         │   ║  ║  ╔════╗  ║      ║     │    │      Outer: #F59E0B→#FFD700 (calories)
│         │   ║  ║  ║1,840║  ║      ║     │    │      Middle: #00D4B2→#00B4D8 (exercise)
│         │   ║  ║  ║kcal ║  ║      ║     │    │      Inner: #6B7AFF→#8B5CF6 (stand)
│         │   ║  ║  ╚════╝  ║      ║     │    │    Each ring: strokeWidth 18px
│         │   ║  ╚══════════╝      ║     │    │    Ring glow: 6px colored shadow on arc
│         │   ╚════════════════════╝     │    │
│         └──────────────────────────────┘    │
│                                             │
│  ┌─────────────────────────────────────────┐│  ← Ring Legend strip (was 3 dots, NOW pill chips)
│  │ 🟡 1,840 kcal  🟢 42 min  🔵 7 hrs      ││    Each: colored dot + label + value as pill chip
│  └─────────────────────────────────────────┘│    Tap a pill → highlights corresponding ring
│                                             │
│  ┌────────────────── WATER ───────────────┐ │  ← _WaterTrackerCard
│  │ 💧 WATER · Daily Hydration  1,750/2,500│ │    bg: gradient #1A2A3A→#0D1B2A (dark)
│  │                                        │ │    border: #41C9E2@25%
│  │  ████████████████████░░░░░░  70%       │ │    Progress bar: 16px height (UP from 10px)
│  │  │← gradient fill #41C9E2→#00B4D8 →│  │ │    Animated fill: TweenAnimationBuilder ✓
│  │                                        │ │    Goal celebration: blue ripple + burst
│  │  [−250ml]    [+ Add 250ml]   [+500ml]  │ │    Controls: 3 equal-width buttons
│  └────────────────────────────────────────┘ │
│                                             │
│  ┌────────────── AI INSIGHT ──────────────┐ │  ← _AiInsightCard
│  │ ┃ ✨ AI INSIGHT              🔄        │ │    Left border: 3px gradient strip #6B7AFF→#00D4B2
│  │ ┃                                      │ │    pulsing opacity 0.6→1.0 @ 2400ms
│  │ ┃ Your protein intake is trending      │ │    Text: typewriter effect MI-10
│  │ ┃ below goal. Consider adding a|       │ │    '|' cursor blinks while typing
│  │ ┃                                      │ │    Icon: PhosphorIconsFill.sparkle (not Material)
│  │                    [💬 Chat about this] │ │    Chat button: bottom-right, gradient pill
│  └────────────────────────────────────────┘ │
│                                             │
│  ┌─────────────── WEEKLY ─────────────────┐ │  ← _WeeklyBanner
│  │  THIS WEEK          🔥 4-day streak    │ │    NEW: 7 mini bars
│  │                                        │ │    bar chart heights proportional to calories
│  │  ▄  ▄  ▄  █  █  ░  ░               │ │    Current day: gradient + glow + dot cap
│  │  M  T  W  T  F  S  S                  │ │    Past days: #FFFFFF@15%
│  └────────────────────────────────────────┘ │    Bars animate from 0 on reveal
│                                             │
│  TODAY'S STATS                              │  ← AppSectionHeader
│  ─────────────────────────────────          │    UPGRADE: per-screen unique accent pattern
│                                             │
│  ┌─────────────────────────────────────────┐│  ← Bento Grid
│  │ ┌──────────────────────────────────────┐││  ← Row 1: Feature flagship card (full width)
│  │ │ 🌙  SLEEP                            │││    height: 120px
│  │ │    8.2 hrs  ████████████████████     │││    This card shows the metric FURTHEST from goal
│  │ │    Goal: 8hrs  ✓ On track           │││    Large gradient bg matching metric color
│  │ └──────────────────────────────────────┘││    Display L number (32px), circular mini-ring
│  │                                         ││
│  │ ┌────────────────┐ ┌────────────────┐   ││  ← Row 2: 2-column
│  │ │ 👟 STEPS       │ │ 🥚 PROTEIN     │   ││    Height: equal (IntrinsicHeight ✓ existing)
│  │ │  8,432         │ │  142g          │   ││    Main value: Display M 26px w700 (UP from 30px)
│  │ │  / 10,000      │ │  / 160g target │   ││    NOTE: 26px w700 Inter visually bigger than
│  │ │  ████████░░    │ │  ████████████░ │   ││          30px w400 due to weight and tracking
│  │ └────────────────┘ └────────────────┘   ││    Progress bar: 6px (UP from 4px)
│  │ ┌────────────────┐ ┌────────────────┐   ││  ← Row 3: 2-column
│  │ │ 🍽️ CALORIES IN │ │ ❤️ HEART RATE  │   ││
│  │ │  1,840         │ │  72            │   ││
│  │ │  / 2,200 goal  │ │  bpm avg today │   ││
│  │ │  ████████████░ │ │  ████░░░░░░░░  │   ││
│  │ └────────────────┘ └────────────────┘   ││
│  │ ┌────────────────┐ ┌────────────────┐   ││  ← Row 4: 2-column
│  │ │ 📍 DISTANCE    │ │ [Locked slot]  │   ││
│  │ │  4.2 km        │ │ + Add metric   │   ││
│  │ │  Walk + run    │ │               │   ││
│  │ │  ████████░░░░  │ │               │   ││
│  │ └────────────────┘ └────────────────┘   ││
│  └─────────────────────────────────────────┘│
│                                             │
│  HEALTH TOOLS                               │  ← AppSectionHeader (accent: softIndigo)
│  ─────────────────────────────              │
│                                             │
│  ─── horizontal scroll ──────────────────→ │  ← _HealthToolsSection
│  │[🧬 Body]│[⚡ Fast]│[💊 Supps]│[📊 Scan]│  │    Each tool: 120×90px card
│  │         │         │          │         │  │    icon badge + name + tagline
│  └─────────┴─────────┴──────────┴─────────┘  │    Gradient fade on right edge (more content)
│                                             │
│     100px bottom padding (nav bar safe)     │
└─────────────────────────────────────────────┘
```

#### Section-by-Section Final Outcomes

**Header Section**
- Final state: Clean two-line greeting ("Good Morning, / Alex") with animated theme toggle and circular avatar. On scroll, greeting fades progressively — by 60px scroll only "Alex" is visible as the AppBar title, sized 16px. The glassmorphic blur (BackdropFilter sigmaX:16) ensures content reads through without distraction.

**Active Workout Banner**
- Final state (when active): A vibrant red-orange gradient card that pulses the barbell icon (existing 0.9→1.05 scale loop). Adds exercise progress ("Exercise 3 of 8") with a 4px gradient mini-progress bar. The JetBrains Mono timer counts up every second. The "RESUME" pill is white@20% glass. The entire banner has a red glow shadow: `BoxShadow(color: #FF3D3D@35%, blurRadius:16, offset:(0,6))`.

**Upcoming Habits Banner**
- Final state: Compact horizontal chip scroll showing 3 habits max. Each chip (36px height, 8px border radius) shows icon + name + incomplete circle. Tapping a chip fires MI-01 burst inline without navigating away. A "+ N more" pill at the end shows remaining count. The banner is 52px tall total — much less invasive than the current full list.

**Activity Rings**
- Final state: Three glowing concentric arcs that build from zero with staggered starts. Each ring has a colored endpoint glow (6px colored shadow). The center shows the calories burned in 40px white bold Inter. Below the rings, three pill chips replace the current plain dots: "🟡 1,840 kcal", "🟢 42 min", "🔵 7 hrs". Tapping a pill chip animates that ring to briefly increase its glow intensity.

**Water Tracker**
- Final state: 16px progress bar with a water-blue gradient fill (#41C9E2→#00B4D8) and a subtle cyan glow shadow. Three equal-width buttons: [-250ml], [+Add 250ml (primary gradient)], [+500ml]. When goal is reached, a blue ripple expands from the bar center, `AppCelebration.trigger()` fires, and a snackbar with custom slide-down animation confirms.

**AI Insight Card**
- Final state: Text types letter by letter at 18ms/char. A 3px left-border gradient strip (indigo→mint) pulses at 2400ms. The AI icon uses `PhosphorIconsFill.sparkle` (fixing the `Icons.auto_awesome` mixed-library issue). The "Chat about this" button uses `PhosphorIconsFill.chatCircle` instead of the Material chat icon.

**Weekly Banner**
- Final state: A compact 7-column bar chart built with `CustomPaint`. Each past day shows a semitransparent bar. Today's bar is full gradient (#00D4B2→#6B7AFF) with a glow. Future days show empty outlines. Bars animate from 0 height when the widget enters the viewport.

**Bento Grid**
- Final state: Row 1 is a full-width flagship card (120px) showing the most critical metric in large type with a gradient background matching that metric's color. Rows 2-4 are the existing 2-column layout but with 26px w700 numbers (not 30px w400) and 6px progress bars (not 4px). All values are driven by `AppMetricDisplay` with count-up animations.

---

### 6.2 Navigation System

#### Color Plate

```
Nav bar bg:        #141720 (charcoalCard)
                   + BackdropFilter(blur:20) underneath transparent sections
Nav bar border:    #FFFFFF@6% (1px top border)
Active pill bg:    gradient #6B7AFF@20% → #00D4B2@20% (border only)
Active pill border:#6B7AFF@60% → #00D4B2@40%
Active icon:       gradient (ShaderMask: softIndigo → dynamicMint)
Inactive icon:     #FFFFFF@45% dark / #1C1E23@45% light
Sliding indicator: 3px line, gradient #6B7AFF → #00D4B2
FAB gradient:      #6B7AFF → #00D4B2 (topLeft→bottomRight) ✓ existing
FAB pulse ring:    #6B7AFF@35% → transparent (expanding ring ✓ existing)
```

#### Wireframe

```
┌─────────────────────────────────────────────┐
│   ← page content ↑                         │
├───────────────────────────────┬─────────────┤
│  ════════════════════════════│             │  ← nav top border #FFFFFF@6%
│                               │   [  FAB  ] │  ← FAB: 60px circle, elevated
│  [🏠]    [🏋️]    [🍽️]    [✅]  │   [ AI 🤖 ] │    gradient + pulse ring ✓
│  Home  Workout  Nutrition  Habits           │    label "AI Coach" fades on deep scroll
│  ──                                         │  ← 3px sliding gradient indicator line
│  ●                                          │    slides between items on tap
│     3px gradient line under active item    │    spring physics (400ms easeOutBack)
└─────────────────────────────────────────────┘
         ↑ system safe zone padding
```

#### Active State Details

```
ACTIVE ITEM (e.g. Home):
  Icon:  Phosphor Fill variant (PhosphorIconsFill.house)
         ShaderMask with gradient #6B7AFF → #00D4B2
  Pill:  Container(
           padding: EdgeInsets.symmetric(horizontal:12, vertical:6),
           decoration: BoxDecoration(
             gradient: LinearGradient(colors: [#6B7AFF@20%, #00D4B2@20%]),
             borderRadius: BorderRadius.circular(14),
             border: Border.all(color: #6B7AFF@40%, width:1.5),
           )
         )
  Label: 10px w700 letterSpacing:0.8, gradient text

INACTIVE ITEM:
  Icon:  Phosphor Regular variant, color: #FFFFFF@45%
  Label: 10px w500, color: #FFFFFF@35%

PRESS ANIMATION (existing ✓):
  scale: 0.82, easeOutBack on release

TRANSITION ANIMATION (new):
  1. Sliding 3px line: AnimationController drives X position
     Lerps from old item center → new item center, 400ms easeOutBack
  2. Icon swap: AnimatedSwitcher, 150ms crossfade
  3. Pill appear: FadeTransition + ScaleTransition, 200ms easeOutBack
```

#### Final Outcome

The nav bar feels physical — tapping between items slides an underline indicator to the new position with a satisfying spring, like a physical slider. The FAB pulsing ring (existing) combined with the gradient glow makes it feel like the most important element on screen. The icon swap between Fill and Regular Phosphor variants gives immediate visual feedback for the active state.

---

### 6.3 Workout Feature

#### 6.3.1 Workout Library Screen

##### Color Plate

```
Page bg:         #080B12 dark / #F7F8FC light
AppBar:          transparent → glassmorphic on scroll
Category tabs:   selected pill: #FF6B35@20% background, #FF6B35 border
Active program:  card border: #FF6B35@60%, glow shadow: #FF6B35@20%
Inactive cards:  #141720 dark / #FFFFFF light
Progress ring:   gradient sweep from #00D4B2@20% → #00D4B2 (SweepGradient)
```

##### Wireframe

```
┌─────────────────────────────────────────────┐
│ ← Back    WORKOUT PROGRAMS        + Create  │  ← SliverAppBar (120px expanded)
│ ─────────────────────────────────────────── │
│  [💪 Strength] [🏃 Cardio] [🧘 Flex] [Custom]│  ← AppPillTabBar (slides from top, 200ms delay)
│  ─────────────────────────────────────────  │    selected: gradient fill
│                                             │
│  ┌─── ACTIVE ────────────────────────────┐  │  ← Active program card (pinned top)
│  │ PUSH/PULL/LEGS   [ACTIVE badge]        │  │    border: #FF6B35@60% glow
│  │ 🔥 6 days/week   Advanced   21 days   │  │    progress ring (right): 68% completion
│  │ Currently: Week 3 / Day 2             │  │    "ACTIVE" badge: gradient pill
│  │ Progress: ████████████████░░░░  68%   │  │
│  │ [▶ Resume Workout]     [View Program] │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  ┌─── PROGRAMS ──────────────────────────┐  │  ← Standard cards (SliverList.builder)
│  │ 💪 Beginner Strength Builder           │  │    Each: 80px height
│  │    4 days/week · 8 weeks · Beginner   │  │    Left: 60×60 gradient icon square
│  │    ⚡ Progressive overload design     │  │    Center: name + badges
│  │                              [Start]  │  │    Right: progress ring (if started)
│  ├────────────────────────────────────────┤  │
│  │ 🏃 HIIT Cardio Blast                  │  │
│  │    5 days/week · 4 weeks · Inter      │  │
│  │                              [Start]  │  │
│  ├────────────────────────────────────────┤  │
│  │ 🧘 Mobility & Flexibility             │  │
│  │    3 days/week · Ongoing · Any level  │  │
│  │                              [Start]  │  │
│  └────────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

##### Final Outcome

The active program card commands the top position with an orange glow border and a resume button. Category tabs slide in from the top after the header settles (200ms delay), creating a cinematic reveal. Each program card stagger-fades in as you scroll. The progress ring on the right of each card gives an at-a-glance completion status using `CustomPainter` with `SweepGradient`.

---

#### 6.3.2 Workout Player Screen

##### Color Plate

```
Full screen bg:   #080B12 dark (deepObsidian)
Exercise header:  gradient background matching workout theme color
Timer display:    JetBrains Mono 28px w700 letterSpacing:2.0
Set complete row: #10B981@15% fill + #10B981 left border 3px
Set active row:   #6B7AFF@10% fill + #6B7AFF left border 3px
Rest timer ring:  gradient: #10B981 → #F59E0B → #FF3D3D (color shifts at 50% and 80%)
Log CTA button:   gradient #FF6B35 → #FF3D3D, full width, 56px height
```

##### Wireframe

```
┌─────────────────────────────────────────────┐
│ ← Back   Push Day A          ⏱ 00:24:38     │  ← timer: JetBrains Mono 28px
│                                             │    timer pulses: scale 1.0→1.02 @ 1000ms
│─────────────────────────────────────────────│
│                                             │
│   ┌─────────────────────────────────────┐   │  ← Exercise image/animation area
│   │                                     │   │    height: 180px
│   │     [Exercise Illustration]         │   │    gradient overlay at bottom
│   │     or muscle group diagram         │   │
│   └─────────────────────────────────────┘   │
│                                             │
│         BARBELL SQUAT                       │  ← Exercise name: Headline 22px w700
│         Sets: 3 × 8  ·  85 kg              │    Sets/weight: Body L 16px
│                                             │
│  ────────────────────────────────────────   │
│                                             │
│  ┌──── REST TIMER (when active) ──────────┐ │  ← Rest countdown: circular ring
│  │        ╔══════════════╗                │ │    Ring depletes clockwise
│  │        ║   1:42       ║                │ │    Color: green→amber→red (at 50%/80%)
│  │        ║  remaining   ║                │ │    JetBrains Mono 28px center
│  │        ╚══════════════╝                │ │    Haptic at 10s, 5s, 1s, 0s
│  └────────────────────────────────────────┘ │
│                                             │
│  Set 1   85kg × 8    ✓  ━━━━━━━━━━━━━━━━  │  ← Set rows
│  Set 2   85kg × 8    ✓  ━━━━━━━━━━━━━━━━  │    Complete: green fill floods left→right
│  Set 3   ●●●●●●●● (dots = reps)            │    Active: indigo tinted row
│          [tap to log weight/reps]           │    Pending: default card surface
│                                             │
│  ─────────────────────────────────────────  │
│                                             │
│  ┌──── PREV ──────┐      ┌──── NEXT ──────┐│  ← prev/next exercise previews
│  │ ← Bench Press  │      │ Romanian DL → ││    peek: 48px height each
│  └────────────────┘      └───────────────┘│    Swipe to navigate (snap threshold: 40%)
│                                             │
│  ┌─────────────────────────────────────────┐│  ← AppBottomCTABar
│  │         [ LOG THIS SET ▶ ]              ││    gradient #FF6B35→#FF3D3D
│  │  Weight: 85kg ↕    Reps: 8 ↕           ││    56px height, full width
│  └─────────────────────────────────────────┘│
└─────────────────────────────────────────────┘
```

##### Final Outcome

The workout player screen becomes the premium centerpiece of the app. The JetBrains Mono timer ticks with a 1.02x pulse every second, giving the sense of a live stopwatch. Set completion floods each row with green from left to right, the checkmark draws itself in (PathMetric animation), and a rest timer ring automatically appears with a color that shifts from calm green to urgent red. Swiping left/right previews the next/previous exercise with a rubber-band snap effect. The "LOG THIS SET" button dominates the bottom with an orange-red gradient glow.

---

#### 6.3.3 Workout Summary Screen

##### Color Plate

```
Full-screen bg:   #080B12 with animated mesh gradient (2 orbs: mint + indigo)
Trophy:           #FFB347 (amberGlow), scale-in with spring bounce
Stats text:       white primary, accent colored values
Share card:       #141720 + gradient border + frosted backdrop
Confetti:         mix of [#FFB347, #00D4B2, #6B7AFF, #FF6B35, #FFFFFF]
```

##### Wireframe

```
┌─────────────────────────────────────────────┐
│                                             │  ← Full screen celebration
│           ✨ ✨ ✨ ✨ ✨ ✨                    │  ← Confetti falls from top
│                                             │
│              🏆                             │  ← Trophy: scales from 0, spring bounce, 600ms
│         WORKOUT COMPLETE!                  │  ← gradient text (amber→warning)
│         Push Day A                         │
│                                             │
│  ┌────────────────────────────────────────┐ │  ← Stats grid (count-up each value)
│  │  ⏱ 42 min    📊 24 sets   💪 2,040kg  │ │    count-up stagger: 0ms, 200ms, 400ms
│  │  🔥 380 kcal  🏅 2 PRs    💧 -600ml   │ │    values in amberGlow color
│  └────────────────────────────────────────┘ │
│                                             │
│  ┌────────────────────────────────────────┐ │  ← Share card (slides up 500ms after trophy)
│  │  GREAT WORK TODAY!                     │ │    frosted glass bg
│  │  [📤 Share Results]  [View History]    │ │
│  └────────────────────────────────────────┘ │
│                                             │
│  [← Back to Workouts]  [Log Next Session]  │  ← Navigation pills
│                                             │
└─────────────────────────────────────────────┘
```

##### Final Outcome

The summary screen is a premium celebration moment. The background has two slowly drifting gradient orbs (mint and indigo) creating a living mesh gradient. Confetti falls from the top using `confetti` package. Stats count up one by one with a 200ms stagger, each value appearing to "materialize." The share card slides up from the bottom with a spring bounce. This screen should feel like finishing a level in a game.

---

### 6.4 Nutrition Screen

#### Color Plate

```
Page bg:          #080B12 dark / #F7F8FC light
Macro ring area:  #141720 dark (pinned header)
Calories ring:    #F59E0B → #FFD700 (SweepGradient arc)
Protein ring:     #FF3D3D → #FF6B35
Carbs ring:       #10B981 → #00D4B2
Fat ring:         #6B7AFF → #8B5CF6
Day pill active:  gradient #00D4B2@20%, border #00D4B2@60%
Meal type tabs:   same AppPillTabBar pattern as habits
Food item row:    #141720 with accent left-border 3px based on meal type
Add food bar:     gradient #10B981 → #00D4B2, frosted glass
```

#### Wireframe

```
┌─────────────────────────────────────────────┐
│ ← Back   NUTRITION          🔍  + Add       │  ← AppBar with Search icon
│─────────────────────────────────────────────│
│                                             │
│  ┌────── MACRO RINGS (pinned header) ──────┐│  ← SliverPersistentHeader, floating:true
│  │                                         ││    height: 130px
│  │  ┌────────┐ ┌──────┐ ┌──────┐ ┌──────┐ ││    4 circular rings horizontal row
│  │  │  1,840 │ │ 142g │ │ 220g │ │  62g │ ││    Calories: 60px circle (largest)
│  │  │  kcal  │ │  P   │ │  C   │ │  F   │ ││    Protein/Carbs/Fat: 44px circles
│  │  │  ████  │ │ ████ │ │ ████ │ │ ████ │ ││    Each: arc progress + value center + label
│  │  │ 84%    │ │ 89%  │ │ 80%  │ │ 91%  │ ││    Entrance: staggered scale 0.5→1.0 spring
│  │  └────────┘ └──────┘ └──────┘ └──────┘ ││    Over-goal: ring shifts to red + shake
│  └─────────────────────────────────────────┘│
│                                             │
│  ┌────── WEEK STRIP (day picker) ─────────┐ │  ← Horizontal 7-day pill strip
│  │  M    T    W   [T]   F    S    S        │ │    Today pill: gradient fill
│  │  ·    ·    ·   ●     ·                  │ │    Past days with food: dot indicator
│  └─────────────────────────────────────────┘ │    Tap: content cross-dissolves 200ms
│                                             │
│  [All] [Breakfast 420] [Lunch 680] [Dinner]  │  ← AppPillTabBar
│  [Snack 160]                                 │    Sub-label: calorie total per meal
│                                             │
│  ┌─── BREAKFAST ───────────── 420 kcal ───┐ │  ← Meal section header
│  │ ┌─────────────────────────────────────┐│ │  ← Food log item
│  │ │ 🥣  Oatmeal                          ││ │    Left: food emoji / color dot
│  │ │      P: 12g  C: 58g  F: 7g          ││ │    Center: name (bold) + macro pills
│  │ │                          350 kcal   ││ │    Right: calorie badge (amber bg)
│  │ │  [tap to expand: portion slider]    ││ │    Expanded: portion slider + full macros
│  │ └─────────────────────────────────────┘│ │    Swipe left: red delete zone
│  │ ┌─────────────────────────────────────┐│ │
│  │ │ 🍳  Eggs × 2                         ││ │    Entrance: slideX(0.08) + fadeIn, 40ms stagger
│  │ │      P: 13g  C: 1g   F: 11g         ││ │
│  │ │                          155 kcal   ││ │
│  │ └─────────────────────────────────────┘│ │
│  └─────────────────────────────────────────┘ │
│                                             │
│  [+ Add Breakfast item]                     │  ← Section-level add button
│                                             │
│  ┌─── LUNCH ──────────────────── 680 kcal ─┐│
│  │   ... meals ...                          ││
│  └─────────────────────────────────────────┘│
│                                             │
├─────────────────────────────────────────────┤
│  📷  [ + LOG FOOD ───────────────── ]  🤖  │  ← AppBottomCTABar
│      (camera scan)  (gradient button)  (AI) │    frosted glass bg
│                                             │    Slides up spring on page load, 400ms delay
└─────────────────────────────────────────────┘
```

#### Final Outcome

The macro rings are pinned above the fold so users always see their progress. The rings animate from zero on each load, counting up to current values. The week strip replaces the single prev/next navigation, making it easy to navigate between days. The bottom CTA bar with three options (scan, log, AI) is always accessible without scrolling. Food log items have colored macro pills (P in red, C in green, F in blue) and swipe-to-delete with a red reveal zone.

---

### 6.5 Habits Screen

#### Color Plate

```
Page bg:          #080B12 dark / #F7F8FC light
Streak banner:    #FFB347 → #FF8C42 gradient (streak > 0)
                  #4A5568 → #2D3748 (streak = 0)
Flame icon:       #FFB347, oscillating scale animation
Category tabs:    per-category gradient colors (see token system)
Habit complete:   #10B981@15% row fill, #10B981 left border
Habit active:     habit.colorValue as accent everywhere
Calendar today:   gradient border #6B7AFF → #00D4B2
Calendar filled:  habit.colorValue@80% fill
```

#### Wireframe

```
┌─────────────────────────────────────────────┐
│ ← Back    HABITS               + New Habit  │  ← AppBar
│─────────────────────────────────────────────│
│                                             │
│  ┌─────────────── STREAK BANNER ──────────┐ │  ← Full-width gradient card (100px)
│  │  🔥  14-DAY STREAK!                    │ │    bg: #FFB347→#FF8C42 gradient
│  │      Keep the momentum going!         │ │    Flame icon: scale 0.95↔1.05 oscillate
│  │                                        │ │    Right: 7 fire icons (filled=done, hollow=missed)
│  │  🔥 🔥 🔥 🔥 🔥 🔥 🔥               │ │    First use today: burst from flame
│  │  Mon Tue Wed Thu Fri Sat Sun           │ │    Collapse on scroll 50px: 100px→60px
│  └────────────────────────────────────────┘ │
│                                             │
│  ┌────── 7-DAY CALENDAR STRIP ────────────┐ │  ← Weekly calendar
│  │  Mo  Tu  We  [Th]  Fr  Sa  Su           │ │    7 columns, each with:
│  │  ●   ◕   ◑   ○     ·   ·   ·            │ │    - Day letter
│  └────────────────────────────────────────┘ │    - Completion ring (full/partial/empty)
│                                             │    - Today: gradient border ring
│  [All] [Fitness] [Nutrition] [Mental] [Sleep│  ← AppPillTabBar (scrollable)
│  [Productivity]                              │    Count badge on each tab
│  ──────────────────────────────────────────  │
│                                             │
│  ┌── PENDING (4 remaining) ───────────────┐ │  ← Pending habits section
│  │ ┌─────────────────────────────────────┐│ │
│  │ │ [🏃] Morning Run      Streak: 🔥14  ││ │    Habit card (72px height):
│  │ │      Daily · Fitness               ○││ │    Left: 40×40 gradient icon badge
│  │ │                                     ││ │    Center: title + frequency + streak count
│  │ │   ← swipe right to complete         ││ │    Right: 36px completion circle (animated)
│  │ └─────────────────────────────────────┘│ │    Long press: edit sheet
│  │ ┌─────────────────────────────────────┐│ │    Swipe right: MI-01 burst
│  │ │ [🧘] Meditate 10 min  Streak: 🔥14  ││ │    Swipe left: red delete zone
│  │ │      Daily · Mental               ○ ││ │
│  │ └─────────────────────────────────────┘│ │
│  │  [+ Add Habit]  [Browse Templates]     │ │
│  └─────────────────────────────────────────┘│
│                                             │
│  ┌── COMPLETED TODAY (3) ─────────────────┐ │  ← Completed section (collapsed by default)
│  │ [💊] Vitamins        ✓ 9:00 AM  ━━━━━━ ││ │    strikethrough text
│  │ [💧] Water 2L        ✓ 11:30 AM ━━━━━  ││ │    green fill row background
│  │ [🥗] Eat Healthy     ✓ 12:15 PM ━━━━━  ││ │    checkmark with glow
│  └─────────────────────────────────────────┘│
└─────────────────────────────────────────────┘
```

#### Completion Circle State Machine

```
STATE: INCOMPLETE
  Widget:   Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: habit.colorValue@40%,
        width: 2,
        style: BorderStyle.dashed,   ← dashed border (CustomPaint)
      ),
    ),
    child: Icon(PhosphorIconsRegular.check, size: 16, color: accent@30%),
  )

STATE: COMPLETING (animation)
  AnimationController drives TweenSequence:
    0→40%:   scale 1.0 → 0.0
    40→80%:  scale 0.0 → 1.2   ← spring overshoot
    80→100%: scale 1.2 → 1.0
  Simultaneously:
    - Checkmark path draws in via PathMetric
    - Background floods from left
    - Particles burst outward

STATE: COMPLETE
  Widget: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(colors: [habit.colorValue, habit.colorValue.lighter]),
      boxShadow: [BoxShadow(color: habit.colorValue@40%, blurRadius: 10)],
    ),
    child: Icon(PhosphorIconsFill.check, color: white, size: 18),
  )
  Row: background habit.colorValue@12%, text strikethrough, shifts to bottom
```

#### Final Outcome

The streak banner is the emotional anchor of the screen — a warm amber gradient flame counter that users feel proud to maintain. The 7-fire icon row gives a visual history of the past week. The habit completion animation (MI-01) is the single most delightful moment in the app — the burst, flood, and strikethrough make checking off a habit feel like a small celebration. Completed habits animate to the bottom of the list with a smooth slide, keeping pending items always at top.

---

### 6.6 Chat Screen

#### Color Plate

```
Page bg dark:     RadialGradient(center:(0,-0.6), radius:1.2, [#1A1D35, #080B12]) ✓
Page bg light:    LinearGradient(top→bottom, [#FFFFFF, #F7F8FC]) ✓
Particle field:   12 dots, #6B7AFF@25% and #00D4B2@20%, drifting upward
User bubble:      gradient #6B7AFF → #00C2A8 (topLeft→bottomRight)
User bubble tail: custom bottom-right QuadraticBezierTo shape
AI bubble dark:   #1E2130 (charcoalElevated) + border #FFFFFF@8%
AI bubble light:  #FFFFFF + border #000000@6% + shadow
Typing dots:      3 dots, #6B7AFF, bounce stagger
Input pill dark:  #FFFFFF@7% → #FFFFFF@10% (on focus), border active: #6B7AFF@60%
Input pill light: #FFFFFF@72% → #FFFFFF@82%
Send button:      gradient #6B7AFF → #00C2A8 ✓ existing
AppBar bottom:    gradient divider: transparent → #6B7AFF@30% → #00D4B2@20% → transparent ✓
```

#### Wireframe — Welcome State

```
┌─────────────────────────────────────────────┐
│ ← Back  [🤖 HealthAI Coach  ● AI·Ready]     │  ← glassmorphic AppBar ✓
│         [Weekly Report] [☁️ Cloud] [🕐]     │
│─────────────────────────────────────────────│← gradient divider ✓
│  ·   ·      ·        ·          ·          │  ← Particle field (CustomPainter)
│     ·    ·      ·         ·          ·     │    12 dots, drift upward
│  ·      ·           ·         ·       ·   │    0.15–0.35 opacity
│                                             │
│           ┌─── AI Logo (80px) ─────┐        │  ← _AiLogoWidget (80px, breathing ✓)
│           │ ╔═══════════════════╗  │        │    scale 1.0→1.04 @ 2400ms repeat
│           │ ║  [neural painter] ║  │        │
│           │ ╚═══════════════════╝  │        │
│           └─────────────────────────┘        │
│                                             │
│          Your Personal                      │  ← ShaderMask gradient text ✓
│          Health Coach                       │    28px w800, gradient softIndigo→mint
│                                             │
│    Ask me anything about workouts,          │  ← subtitle: 14px #FFFFFF@50%
│    nutrition, sleep, or your goals.         │
│                                             │
│  ┌────────────────────────────────────────┐ │  ← Capability pills (Wrap) ✓
│  │ [🏋️ Workouts] [🍽️ Nutrition]           │ │
│  │ [❤️ Recovery]  [🌙 Sleep]              │ │
│  └────────────────────────────────────────┘ │
│                                             │
│  SUGGESTED  [AI]                            │  ← label ✓
│                                             │
│  ┌─────────────────────────────────────────┐│  ← Suggestion tiles (stagger ✓)
│  │ [🏋️] How should I structure my splits? ││    slideX(0.06) + fadeIn, 70ms stagger
│  ├─────────────────────────────────────────┤│
│  │ [⭐] Show my weekly progress summary   ││    highlighted tile: #6B7AFF@14% bg
│  ├─────────────────────────────────────────┤│
│  │ [🍽️] Suggest a high-protein lunch      ││
│  └─────────────────────────────────────────┘│
│                                             │
├─────────────────────────────────────────────┤
│  [📎]  [ Ask your coach anything...  🎤 ]  │  ← Input bar (glass pill ✓)
└─────────────────────────────────────────────┘
```

#### Wireframe — Active Conversation

```
┌─────────────────────────────────────────────┐
│ ← Back  [🤖 HealthAI Coach  ● AI·Ready]     │
│─────────────────────────────────────────────│
│                                             │
│  ┌─────────────────────────────────────┐   │  ← AI bubble (left-aligned)
│  │ Based on your training data, I      │   │    bg: #1E2130 dark / #FFFFFF light
│  │ recommend increasing your protein   │   │    tail: bottom-left custom shape
│  │ by 20g today. Your last workout     │   │    streaming: text appears char by char
│  │ depleted glycogen significantly.    │◄──│    via AnimatedSize + partial reveal
│  └─────────────────────────────────────┘   │    NOT rebuild per char
│  10:24 AM                                  │    timestamp: 10px, 300ms fadeIn after done
│                                             │
│                                             │
│  How much protein should I               ┐ │  ← User bubble (right-aligned)
│  have after a heavy leg day?             │ │    gradient bg #6B7AFF→#00C2A8
│                                          ◄─│    tail: bottom-right custom shape
│                                10:25 AM    │    entrance: slideX(0.1) + fadeIn, 250ms
│                                             │
│  ┌─── typing ─────────────────────────┐   │  ← Typing indicator: glass card matches AI bubble
│  │  ● ● ●  (8px dots, stagger bounce) │   │    dot size: 8px (up from current)
│  └───────────────────────────────────┘   │    dots: #6B7AFF, bounce at 120ms stagger
│                                             │
│  ┌──── scroll-down FAB ───┐               │  ← existing ✓ gradient circle
│  │  ▼ (caretDoubleDown)   │               │
│  └────────────────────────┘               │
│                                             │
├─────────────────────────────────────────────┤
│  [📎]  [  Ask your coach anything...  🎤] │  ← input bar
│        [         🔵  SEND ▶           ]    │    send button: appears on text input
└─────────────────────────────────────────────┘
```

#### Final Outcome

The chat welcome screen has a subtle particle field drifting upward behind the hero content, creating depth and life without distraction. The AI logo breathing animation (existing) and the neural painter (existing) are already excellent — keep them. Chat bubbles have custom tail shapes and smooth entrance animations. The send action triggers MI-03 — the paper plane rotation makes the message feel physically launched. AI streaming text appears via AnimatedSize for performance (no per-character setState on the full ListView). The typing indicator uses 8px dots (up from current size) in an elegant glass card.

---

### 6.7 Settings Screen

#### Color Plate

```
Page bg:         #080B12 dark / #F7F8FC light
Profile card:    mesh gradient unique per user (seeded from name hash)
Profile ring:    gradient border #6B7AFF → #00D4B2, 3px
Section cards:   #141720 dark / #FFFFFF light (AppSettingsSectionCard ✓)
Section icons:   gradient badge per section theme
Toggle on:       gradient fill #00D4B2 → #6B7AFF
Toggle off:      #FFFFFF@20% dark / #000000@12% light
Destructive row: #FF3D3D@10% bg, #FF3D3D icon
Version badge:   #FFFFFF@8% bg, monospace text
```

#### Wireframe

```
┌─────────────────────────────────────────────┐
│ ← Back    SETTINGS                          │
│─────────────────────────────────────────────│
│                                             │
│  ┌─────────────────────────────────────────┐│  ← Profile header card (120px)
│  │  [mesh gradient bg — unique per user]   ││    gradient seeded from user.displayName hash
│  │                                         ││
│  │  ┌──┐                                   ││    Left: 70px avatar with gradient ring border
│  │  │👤│  Alex Johnson        ✏️ Edit      ││    gradient ring: #6B7AFF → #00D4B2, 3px
│  │  └──┘  Premium Member  [🌟 PREMIUM]     ││    Status pill: gradient gradient background
│  └─────────────────────────────────────────┘│
│                                             │
│  ┌────── 🎯 GOALS & TARGETS ──────────────┐ │  ← Settings groups (AppSettingsSectionCard ✓)
│  │  🏃 Daily Steps Goal    10,000  →       │ │    Group icon: gradient badge (new)
│  │  🔥 Calorie Target      2,200   →       │ │    Selected values: accent color text
│  │  💪 Protein Goal        160g    →       │ │    Right arrows: #FFFFFF@30%
│  │  🌙 Sleep Target        8 hrs   →       │ │
│  └────────────────────────────────────────┘ │
│                                             │
│  ┌────── 🔔 NOTIFICATIONS ────────────────┐ │
│  │  Evening Nudge           [●──────]      │ │    Custom toggle: thumb slides with spring
│  │  Workout Reminders       [──────●]      │ │    On state: gradient fill #00D4B2→#6B7AFF
│  │  Achievement Alerts      [●──────]      │ │    Off state: #FFFFFF@20% fill
│  └────────────────────────────────────────┘ │    Thumb: white circle with shadow
│                                             │
│  ┌────── 🤖 AI & PRIVACY ─────────────────┐ │
│  │  AI Mode          Cloud ↔ On-Device →  │ │
│  │  Data Sharing              [──────●]   │ │
│  └────────────────────────────────────────┘ │
│                                             │
│  ┌────── ⚠️ DANGER ZONE ─────────────────┐ │  ← Destructive group: red tint
│  │  Clear All Data                    →  │ │    bg: #FF3D3D@8%
│  │  Sign Out                          →  │ │    icon: #FF3D3D
│  └────────────────────────────────────────┘ │    border: #FF3D3D@20%
│                                             │
│         v2.4.0  ·  Build 2024.03           │  ← Version: JetBrains Mono 11px, centered
└─────────────────────────────────────────────┘
```

#### Custom Toggle Switch

```dart
// Replaces Switch widget with animated custom toggle
// FINAL VISUAL:
//   Off: track color #FFFFFF@20%, thumb white 20px circle
//   On:  track gradient #00D4B2→#6B7AFF, thumb white 20px + glow shadow
// ANIMATION:
//   Thumb: AnimationController drives Tween<double>(0.0, 1.0)
//          thumbX = lerp(4, trackWidth - 24, animation.value)
//          Track fill: AnimatedContainer color transition
//   Duration: 220ms, Curves.easeInOutCubic (spring-like)
//   On press: thumb scale 1.0 → 1.15 → 1.0, 100ms
//   HapticFeedback.selectionClick() on each toggle
```

#### Final Outcome

The settings screen gains a distinctive personality through the per-user mesh gradient profile card. The custom animated toggle switches replace Flutter's default `Switch` widget with physics-spring thumb movement. Section groups have gradient icon badges. The destructive actions section has a clear red tint treatment so users never accidentally tap dangerous actions. The version number appears in JetBrains Mono for a developer-premium feel.

---

## 7. Performance Strategy

### 7.1 Animation Framework Decision Table

```
┌─────────────────────────────────┬──────────────────────────────────────────────────┐
│ Animation Type                  │ Best Approach                                    │
├─────────────────────────────────┼──────────────────────────────────────────────────┤
│ Entrance (fade+slide)           │ flutter_animate .fadeIn().slideY() ✓ existing    │
│ Count-up numbers                │ TweenAnimationBuilder<double> ✓ existing         │
│ Continuous idle (float, pulse)  │ AnimationController.repeat(reverse:true)         │
│ Ring/arc progress fills         │ AnimationController → CustomPaint (SweepGradient)│
│ Page transitions                │ CustomTransitionPage in go_router                │
│ Particles / burst effects       │ Single AnimationController → CustomPainter       │
│ Scroll-driven effects           │ ScrollController.addListener → setState(only t)  │
│ Staggered list items            │ flutter_animate with delay: index*60ms           │
│ State-change animations         │ AnimatedSwitcher with custom transitionBuilder   │
│ Height/width expand             │ AnimatedSize (smooth) or AnimatedContainer       │
│ Skeleton shimmer                │ flutter_animate .shimmer() ✓ existing            │
│ Typewriter text                 │ Timer.periodic → separate StatefulWidget state   │
│ Path drawing (checkmark)        │ AnimationController → PathMetric.extractPath()   │
│ Custom toggle switch            │ AnimationController → Transform.translate thumb  │
└─────────────────────────────────┴──────────────────────────────────────────────────┘
```

### 7.2 GPU-Friendly Rules (enforce these)

```
RULE 1: Transform over layout
  ✓ Transform.translate, Transform.scale → GPU layer promotion
  ✗ NEVER animate width/height/padding in hot paths
  Example: Use Transform.scale for card press, not AnimatedContainer(width)

RULE 2: RepaintBoundary isolation
  ALL continuously animating widgets MUST be wrapped:
    - FAB pulse ring → RepaintBoundary ✓ (apply if not already)
    - Activity rings during fill animation
    - Chat typing indicator dots
    - Particle burst CustomPainter
    - AI insight typewriter text widget
    - Streak flame icon

RULE 3: FadeTransition not Opacity
  ✓ FadeTransition(opacity: CurvedAnimation(...)) — GPU composited
  ✗ Opacity(opacity: animation.value) — triggers repaint on parent
  ✓ AnimatedOpacity for simple non-animated transitions — acceptable

RULE 4: BackdropFilter budget
  MAXIMUM 2 simultaneous BackdropFilter widgets:
    - Slot 1: Top AppBar (always present)
    - Slot 2: Bottom nav bar OR chat input bar (not both)
  When bottom sheet opens: Offstage(offstage: true) the nav bar backdrop

RULE 5: Particle systems
  Single Canvas per particle system — never use Widget tree for particles
  _ParticleBurst.paint() draws ALL dots in one canvas.drawCircle() loop
  NO Column([Container, Container, ...]) for particle effects

RULE 6: ListView re-build minimization
  Chat streaming: DO NOT rebuild full ListView per character
  Use _StreamingBubble as isolated StatefulWidget
  AnimatedSize wraps the text — only that widget rebuilds
```

### 7.3 Lazy Loading Strategy

```
DASHBOARD (priority order):
  Frame 1 — AppBar, rings, water card, habits banner (above fold)
  +100ms  — Bento grid (SliverList, below fold acceptable delay)
  async   — AI insight (FutureProvider ✓ existing)
  scroll  — Health tools section (SliverList.builder, only visible cards built)

NUTRITION:
  Immediate  — Macro rings header + today's meal log
  On navigate— Historical dates load on date selection
  Never preload— Future dates (waste of memory)

WORKOUT LIBRARY:
  Immediate  — Active program card (top, always visible)
  Scroll     — Rest of programs via SliverList.builder

CHAT:
  Render only last 50 messages — ListView.builder with cacheExtent: 500
  Older messages: load on scroll up (pagination via loadBefore())
  Images: cached_network_image with memCacheWidth = displayWidth

HABITS:
  Immediate — Streak banner + category tabs
  Scroll    — Habit list items (VisibilityDetector triggers entrance anim once)
```

### 7.4 Frame Rate Targets

```
60fps minimum: ALL screens, mid-range device (Pixel 6a)
120fps target: Activity rings fill (Flutter auto-schedules on ProMotion ✓)
              Workout player timer tick
              Chat message slide-in

MEASUREMENT:
  Use Flutter DevTools Performance overlay during:
  - Dashboard scroll (most expensive: 3 gradients + BackdropFilter)
  - Habit completion burst (particle + animation cascade)
  - Chat message list scroll (many bubbles in view)

TARGET frame budget: 16.67ms (60fps) / 8.33ms (120fps)
  Dashboard steady-state scroll: < 8ms build + paint combined
```

---

## 8. Implementation Guide

### 8.1 File Structure

```
lib/src/theme/
  app_colors.dart          ✓ existing — add warmObsidian, amberGlow, roseAccent
  app_ui.dart              ✓ existing — add AppPillTabBar, AppBottomCTABar, custom toggle
  app_animations.dart      NEW — AppDurations, AppCurves, _ParticleBurst painter
  app_metrics.dart         NEW — AppMetricDisplay, AppWeeklyBarChart
  app_celebrations.dart    NEW — AppCelebration.trigger(), ring burst, confetti

lib/src/features/
  dashboard/presentation/
    widgets/
      hero_activity_rings.dart  — add celebration logic, staggered start
      _typewriter_text.dart     NEW — isolated typewriter widget
      _particle_burst.dart      NEW — CustomPainter for MI-01 and MI-04

  habits/presentation/
    widgets/
      habit_card.dart           REFACTOR — extract from habits_screen.dart
      completion_circle.dart    NEW — state machine circle

  nutrition/presentation/
    widgets/
      macro_rings_header.dart   NEW — 4 pinned arc rings
      food_log_item.dart        NEW — with swipe + expand

  workout/presentation/
    widgets/
      rest_timer_ring.dart      NEW — CustomPaint countdown ring
      set_row.dart              NEW — with green flood animation
```

### 8.2 New Color Tokens to Add

```dart
// In app_colors.dart — ADD these:
static const Color warmObsidian  = Color(0xFF0E0C15);
static const Color amberGlow     = Color(0xFFFFB347);
static const Color roseAccent    = Color(0xFFFF6B9D);
// skyBlue already used inline as Color(0xFF41C9E2) — promote to named token

// Fix mixed icon library (2 instances):
// dashboard_screen.dart line 1292: Icons.auto_awesome → PhosphorIconsFill.sparkle
// dashboard_screen.dart line 1360: Icons.chat_bubble_outline_rounded → PhosphorIconsFill.chatCircle
// chat_screen.dart appbar actions line 533: Icons.insert_chart_outlined_rounded → PhosphorIconsFill.chartBar
// chat_screen.dart appbar actions line 543: Icons.memory_rounded → PhosphorIconsFill.cpu
// chat_screen.dart appbar actions line 544: Icons.cloud_outlined → PhosphorIconsRegular.cloud
```

### 8.3 AppPillTabBar Implementation

```dart
// lib/src/theme/app_ui.dart — add this component

class AppPillTabBar extends StatefulWidget {
  final List<String> tabs;
  final List<String>? subLabels;   // optional calorie totals below tab name
  final ValueChanged<int> onChanged;
  final int initialIndex;
  final Color? accentColor;

  const AppPillTabBar({...});
}

class _AppPillTabBarState extends State<AppPillTabBar> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: widget.tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = i == _selected;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selected = i);
              widget.onChanged(i);
            },
            child: AnimatedContainer(
              duration: 180.ms,
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? LinearGradient(
                  colors: [
                    (widget.accentColor ?? AppColors.softIndigo).withValues(alpha: 0.25),
                    AppColors.dynamicMint.withValues(alpha: 0.15),
                  ],
                ) : null,
                color: isSelected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                    ? (widget.accentColor ?? AppColors.softIndigo).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.15),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.tabs[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                        ? (widget.accentColor ?? AppColors.softIndigo)
                        : Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  if (widget.subLabels != null && i < widget.subLabels!.length)
                    Text(
                      widget.subLabels![i],
                      style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.4)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 8.4 Particle Burst CustomPainter

```dart
// lib/src/theme/app_celebrations.dart

class _Particle {
  double x, y, vx, vy, radius;
  Color color;
  double life; // 1.0 → 0.0

  _Particle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.radius, required this.color,
  }) : life = 1.0;
}

class _ParticleBurstPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t; // 0.0 → 1.0

  _ParticleBurstPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final life = (1.0 - t).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: life * 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p.x + p.vx * t * 60, p.y + p.vy * t * 60 + 30 * t * t),
        p.radius * (1 - t * 0.4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticleBurstPainter old) => old.t != t;
}

// USAGE: AppCelebration.trigger()
class AppCelebration {
  static void trigger(BuildContext context, {required Offset origin}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ParticleBurstOverlay(
        origin: origin,
        onComplete: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}
```

### 8.5 Custom Page Transitions in go_router

```dart
// lib/src/routing/app_router.dart — add to all GoRoute entries

// Standard screen push (slide up + fade):
GoRoute(
  path: '/habits',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const HabitsScreen(),
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (ctx, animation, secondaryAnim, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      );
    },
  ),
),

// Modal screens (workout player, food search): slide up from bottom
GoRoute(
  path: '/workout/player',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const WorkoutPlayerScreen(),
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (ctx, animation, _, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
  ),
),
```

### 8.6 State-Driven Animation Triggers

```dart
// Pattern: use ref.listen (NOT ref.watch) to trigger animations on data changes
// Applied in: DashboardScreen, HabitsScreen, NutritionScreen

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {

  late final AnimationController _bentoReveal;
  late final AnimationController _ringFill;

  @override
  void initState() {
    super.initState();
    _bentoReveal = AnimationController(vsync: this, duration: 600.ms);
    _ringFill = AnimationController(vsync: this, duration: 1400.ms);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger ring fill after health data loads
      ref.listen<DailyLogDoc>(dailyActivityProvider, (prev, next) {
        if (prev?.caloriesBurned != next.caloriesBurned) {
          _ringFill.forward(from: 0);
        }
      });
    });
  }
}
```

### 8.7 Typewriter Text Widget (isolated)

```dart
// lib/src/features/dashboard/presentation/widgets/_typewriter_text.dart

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  const TypewriterText({required this.text, this.style, super.key});

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayed = '';
  bool _showCursor = true;
  Timer? _typeTimer;
  Timer? _cursorTimer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
    _cursorTimer = Timer.periodic(500.ms, (_) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  void _startTypewriter() {
    _typeTimer = Timer.periodic(18.ms, (t) {
      if (_charIndex >= widget.text.length) {
        t.cancel();
        _cursorTimer?.cancel();
        if (mounted) setState(() => _showCursor = false);
        return;
      }
      if (mounted) {
        setState(() {
          _charIndex++;
          _displayed = widget.text.substring(0, _charIndex);
        });
      }
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayed + (_showCursor ? '|' : ''),
      style: widget.style,
    );
  }
}
```

---

## 9. Priority Implementation Order

Ordered strictly by **user-visible impact** vs. **implementation effort ratio**.

### Phase 1 — Maximum Impact (implement first, highest ROI)

```
1. FIX ICON LIBRARY CONSISTENCY (1 hour)
   Replace 5 instances of Material Icons in files that use Phosphor:
   - dashboard_screen.dart: Icons.auto_awesome → PhosphorIconsFill.sparkle
   - dashboard_screen.dart: Icons.chat_bubble_outline_rounded → PhosphorIconsFill.chatCircle
   - chat_screen.dart: Icons.insert_chart_outlined_rounded → PhosphorIconsFill.chartBar
   - chat_screen.dart: Icons.memory_rounded → PhosphorIconsFill.cpu
   - chat_screen.dart: Icons.cloud_outlined → PhosphorIconsRegular.cloud
   WHY FIRST: This is a quality regression — visible on every AI insight load

2. CUSTOM PAGE TRANSITIONS in go_router (2 hours)
   Add CustomTransitionPage to all routes
   Immediately transforms how the entire app feels
   No feature code changes required

3. BENTO CARD NUMBER SIZE (30 min)
   Change fontSize: 30 → 26, fontWeight: bold → w700, letterSpacing: -0.5
   dashboard_screen.dart line 957
   Combined with weight increase: visually larger, more impactful

4. BENTO CARD PROGRESS BAR (30 min)
   Change height: 4 → 6 in _BentoCard Stack
   dashboard_screen.dart line 999

5. WATER TRACKER PROGRESS BAR (30 min)
   Change height: 10 → 16 in _WaterTrackerCard
   dashboard_screen.dart line 527

6. AI INSIGHT TYPEWRITER EFFECT
   Extract _AiInsightCard text into TypewriterText widget
   High emotional impact — AI feels "alive"

7. HABIT COMPLETION ANIMATION (MI-01)
   The single most delightful interaction in the app
   Priority: extract HabitCard, add AnimationController cascade
```

### Phase 2 — High Impact, Moderate Effort

```
8. ACTIVITY RING CELEBRATION (MI-02)
   Add flash + particle burst when ring reaches 100%
   Requires AppCelebration.trigger() — build that first

9. APPILLTABBAR COMPONENT
   Build the component once, integrate on:
   - Nutrition screen meal types
   - Habits screen categories
   - Workout library categories

10. NUTRITION MACRO RINGS HEADER
    Add SliverPersistentHeader with 4 arc rings above meal list
    Pin above fold — major feature visibility improvement

11. WEEKLY BANNER BAR CHART
    Replace static banner with 7-bar CustomPaint chart
    Bars animate from 0 on reveal

12. STREAK BANNER WITH FLAME ANIMATION
    Add oscillating scale to flame icon
    7-fire icon row showing last 7 days

13. BENTO GRID FLAGSHIP ROW
    Replace first 2-column row with full-width feature card
    Shows most critical metric with gradient bg
```

### Phase 3 — Polish & Delight

```
14. CHAT PARTICLE FIELD (welcome state)
    12-dot drifting particle CustomPainter in background

15. SETTINGS PROFILE CARD UPGRADE
    Gradient header + avatar gradient ring border

16. WORKOUT PLAYER TIMER (JetBrains Mono)
    Add font to pubspec.yaml, apply to timer display
    Add 1.02x pulse on second tick

17. CUSTOM PULL-TO-REFRESH
    Replace default RefreshIndicator with AI sparkle animation

18. NAV BAR SLIDING INDICATOR
    3px gradient line that slides between nav items

19. SCROLL-DRIVEN DASHBOARD HEADER PARALLAX
    Greeting fade + avatar scale on scroll

20. WORKOUT SUMMARY CELEBRATION SCREEN
    Full-screen trophy + confetti + count-up stats
```

---

## 10. Quick Reference — Animation Cheatsheet

```dart
// ── ENTRANCE (flutter_animate) ───────────────────────────────────
widget
  .animate()
  .fadeIn(duration: 380.ms)
  .slideY(begin: 0.12, end: 0, duration: 380.ms, curve: Curves.easeOutCubic)

// ── STAGGERED LIST ───────────────────────────────────────────────
widget
  .animate(delay: Duration(milliseconds: index * 60))
  .fadeIn(duration: 350.ms)
  .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic)

// ── COUNT-UP NUMBER ──────────────────────────────────────────────
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: value.toDouble()),
  duration: 1200.ms,
  curve: Curves.easeOutCubic,
  builder: (_, v, __) => Text(
    v.toInt().toString(),
    style: const TextStyle(
      fontFamily: 'JetBrainsMono',   // for timers/metrics
      fontSize: 28, fontWeight: FontWeight.w700,
    ),
  ),
)

// ── PRESS SCALE ──────────────────────────────────────────────────
// Use existing AppAnimatedPressable(pressScale: 0.95) for cards
// Use AppAnimatedPressable(pressScale: 0.88) for icon buttons

// ── RING ARC (CustomPainter + SweepGradient) ─────────────────────
class _RingPainter extends CustomPainter {
  final double progress;   // 0.0 → 1.0
  final Color startColor;
  final Color endColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width/2, size.height/2),
      radius: size.width/2 - strokeWidth/2,
    );
    // Background track
    canvas.drawArc(rect, -pi/2, 2*pi, false,
      Paint()
        ..color = startColor.withValues(alpha: 0.15)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
    );
    // Progress arc
    canvas.drawArc(rect, -pi/2, 2*pi*progress, false,
      Paint()
        ..shader = SweepGradient(
            startAngle: -pi/2,
            endAngle: -pi/2 + 2*pi*progress,
            colors: [startColor, endColor],
          ).createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── HABIT COMPLETION TweenSequence ───────────────────────────────
final _checkScale = TweenSequence<double>([
  TweenSequenceItem(tween: Tween(begin:1.0, end:0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 40),
  TweenSequenceItem(tween: Tween(begin:0.0, end:1.2).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
  TweenSequenceItem(tween: Tween(begin:1.2, end:1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
]).animate(CurvedAnimation(parent: _checkController, curve: Curves.linear));

// ── TYPEWRITER ────────────────────────────────────────────────────
// Use TypewriterText widget (see Section 8.7)
// Do NOT implement inline in _AiInsightCard — isolate for performance

// ── REPAINT BOUNDARY (apply to ALL continuous animations) ─────────
RepaintBoundary(
  child: AnimatedBuilder(
    animation: _controller,
    builder: (_, child) => Transform.scale(
      scale: _animation.value,
      child: child,
    ),
    child: _staticContent(), // rebuilt only on structural change
  ),
)
```

---

*This document is the complete, developer-ready UI/UX redesign specification for HealthAI.*
*All section outcomes are defined. All animations have duration + curve + trigger.*
*All wireframes show exact layout. All color values are hex-precise.*
*Implementation order is prioritized by user-visible impact.*
*No feature logic changes required — presentation layer only.*
