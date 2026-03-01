# Profile & Settings Page — Complete Plan

## Overview
Split the current monolithic `profile_screen.dart` into two focused full-screen pages:
- **ProfileScreen** — identity, body metrics, progress, achievements, AI insights
- **SettingsScreen** — notifications, AI model config, data, privacy, account actions

Both pages share the app's dark-glass premium design language (frosted glass cards, soft indigo/mint gradients, spring animations, haptic feedback at every interaction point).

---

## 1. Profile Page

### 1.1 Hero Header (SliverAppBar expandedHeight 320)
| Element | Detail |
|---|---|
| Background | Radial gradient from `softIndigo.withOpacity(0.18)` to transparent, animated floating orbs |
| Avatar | 100 × 100 gradient-ring, ClipOval, pulse animation; tap → photo picker sheet |
| Name | Bold 24 sp; tap inline to edit |
| Subtitle row | PRO badge pill + member-since date |
| Action row | "Edit Profile" glass pill + "Share" icon |
| Scroll collapse | Pinned mini-header shows avatar+name at 44 px on scroll |

### 1.2 Body Metrics Strip (horizontal scroll)
Six metric cards: **Weight · Height · BMI · Body Fat % · Age · Goal Calories**
- Each card: icon + value + unit + trend arrow
- Tap any card → inline edit sheet
- BMI card has color-coded indicator (underweight/normal/overweight/obese)

### 1.3 Weekly Activity Summary
- Three stat pills (Kcal Burned · Active Minutes · Hydration) — today's data
- Animated 7-day bar chart (already exists, keep + polish with gradients)
- "View Full Report" → `/weekly`

### 1.4 Goals & Nutrition Targets
Expandable card showing:
- Daily calorie goal (progress ring)
- Protein target (g)
- Water goal (ml)
- Primary goal badge (Weight Loss / Muscle Gain / General Fitness / Endurance)
- Fitness level badge (Beginner / Intermediate / Advanced)
- Dietary restrictions chips (Vegan, Gluten-Free, etc.)
- "Edit Goals" button → opens goal edit bottom sheet

### 1.5 Achievements Gallery
- Horizontal `PageView`-style scroll
- 12 badges total (Early Bird, Hydration Hero, Marathon, Scan Master, Streak 7d/30d/90d, Calorie Crusader, Protein Pro, Sleep Champion, Gym Rat, Perfect Week)
- Locked badges: grayscale + shimmer effect
- Unlocked: glowing colour ring + pop-in scale animation
- Progress bar per badge showing how close to unlock
- "Total Points" counter with `AnimatedFlipCounter`

### 1.6 AI Insights Card
- Weekly AI summary (cached from chat)
- "Regenerate" button triggers AI call
- Sentiment emoji row (energy, mood, recovery scores)
- Sparkline of past-week trend

### 1.7 Personal Bests / PRs
- Compact list of top 5 exercise PRs (from isar `ExercisePrDoc`)
- Trophy icon per item, date stamp

### 1.8 Streaks & Consistency
- Current active streak (fire icon with counter)
- Longest streak ever
- Monthly heatmap calendar (GitHub-contribution style)

---

## 2. Settings Page

### 2.1 Appearance
| Setting | Control |
|---|---|
| Theme | Segmented control: Light / Dark / System |
| Accent colour | 6 colour swatches |
| Font size | Slider (Small / Normal / Large) |
| Haptic feedback | Toggle |

### 2.2 AI Model
| Setting | Control |
|---|---|
| AI provider | Segmented: On-Device (Gemma) / Cloud (Gemini) |
| Cloud model | Dropdown: gemini-2.0-flash / gemini-1.5-pro |
| On-device model | Download progress, model version, delete button |
| Context memory | Toggle: remember health context across sessions |
| Streaming responses | Toggle |

### 2.3 Notifications
| Setting | Control |
|---|---|
| All notifications master | Toggle |
| Daily motivation (time picker) | Toggle + time |
| Habit reminders (time picker) | Toggle + time |
| Water reminders (interval picker) | Toggle + interval |
| Weekly report (day picker) | Toggle + day |
| Workout reminder | Toggle + time |
| Calorie log reminder | Toggle + time |

### 2.4 Health & Data
| Setting | Control |
|---|---|
| Apple Health / Google Fit sync | Toggle |
| Auto-sync interval | Picker (Real-time / Hourly / Daily) |
| Export data (CSV) | Button → share sheet |
| Backup to cloud | Toggle |
| Clear cached AI data | Button with confirmation |
| Data usage info | Info tile |

### 2.5 Privacy & Security
| Setting | Control |
|---|---|
| App lock (biometrics/PIN) | Toggle |
| Face ID / Touch ID | Toggle (if biometrics available) |
| Analytics opt-out | Toggle |
| Privacy policy | Link tile |
| Terms of service | Link tile |

### 2.6 Units & Locale
| Setting | Control |
|---|---|
| Unit system | Segmented: Metric / Imperial |
| Language | Dropdown |
| First day of week | Picker |

### 2.7 About
- App version, build number
- "What's New" bottom sheet (changelog)
- Rate the App → store link
- Send feedback → mailto
- Open source licenses

### 2.8 Account (Danger Zone)
- Sign Out (warning colour)
- Delete Account (destructive confirm dialog)

---

## 3. Design Tokens

```
Card radius:        20–24 dp
Section spacing:    24 dp
Icon container:     36×36, radius 10, color.opacity(0.15)
Toggle color:       activeColor = section accent
Header gradient:    deepObsidian → softIndigo (18% opacity)
Glass card:         charcoalGlass bg + white 5% border
Divider:            white 6% opacity, indent 56
Section label:      11 sp, bold, letterSpacing 1.1, opacity 0.45
Row title:          14 sp, w600
Row subtitle:       11 sp, opacity 0.45
Haptic:             selectionClick on toggle, lightImpact on tap, mediumImpact on destructive
```

---

## 4. Animations & Transitions

| Trigger | Animation |
|---|---|
| Page enter | Staggered fade+slideY(0.06) per section, 80ms delay increments |
| Avatar pulse | Continuous scaleXY 0.97↔1.03, 2 s |
| Achievement unlock | Scale from 0.5 easeOutBack + glow pulse |
| Stat tile press | ScaleXY 0.97 on press, spring return |
| Toggle flip | Switch.adaptive with activeColor transition |
| Bottom sheet | Slide up with spring curve |
| Delete confirm | Shake animation on confirm button |
| Progress rings | TweenAnimationBuilder from 0 to value, 800ms easeOutCubic |
| Bar chart bars | Staggered grow from bottom, 600+i*80 ms |
| Flip counter (points) | AnimatedFlipCounter with 400ms spring |

---

## 5. Settings Page Architecture

```
SettingsScreen (ConsumerStatefulWidget)
├── _AppearanceSection
├── _AIModelSection
├── _NotificationsSection
├── _HealthDataSection
├── _PrivacySection
├── _UnitsSection
├── _AboutSection
└── _AccountSection

Shared widgets:
├── _SettingsHeader         (section label with icon)
├── _SettingsTile           (icon + label + subtitle + trailing)
├── _ToggleTile             (extends _SettingsTile)
├── _SegmentedTile          (inline segmented control)
├── _SliderTile
└── _LinkTile
```

---

## 6. New Routes

```dart
GoRoute(path: '/settings', child: SettingsScreen())
```

Profile page gets a gear icon in its AppBar → `/settings`.

---

## 7. State Management

All settings persist via `UserNotifier.updateProfile()` to Isar.  
New notification time preferences stored via `NotificationService`.  
Unit system & theme stored in `UserPreferences` (already in `UserDoc`).  
AI model preference stored in `SharedPreferences` (already used by `gemma_service.dart`).
