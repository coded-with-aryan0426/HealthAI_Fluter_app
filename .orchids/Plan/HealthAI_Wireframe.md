# HealthAI - Structural Wireframe & UI Layout

This document outlines the skeletal framework, navigational hierarchy, and component placement for the HealthAI Flutter application, optimized for bezel-less screens (iOS 26 / Android 17 era).

---

## 1. Global Application Shell

**[ System Status Bar ]** (Transparent, overlaps content)
**[ Main Content Area ]** (Scrollable, extends underneath Navigation and Status Bar)
**[ Floating Bottom Navigation Pill ]** (Glassmorphic, hovered 24px above screen bottom)
**[ System Home Indicator ]** (Overlaps background)

### 1.1 Floating Bottom Navigation Pill
- **Placement:** Absolute bottom, centered. Width: 90% of screen. Height: 72px.
- **Style:** Heavy blur (Material 3/Cupertino mixed blur), `#1A1D24` at 60% opacity.
- **Items (Left to Right):**
  1. `Home` (Outlined icon default -> Filled icon active)
  2. `Habits` (Grid/checkpad icon)
  3. **[ Floating Action Button (FAB) ]** (Breaks the top boundary of the pill. Giant glowing `Mint` circle with `Camera/Scan` icon)
  4. `AI Coach` (Sparkle/Chat icon)
  5. `Profile` (User avatar circle)

---

## 2. Screen Wireframes

### 2.1 Dashboard (Home Tab)
**Behavior:** Content scrolls 'behind' the top app bar and bottom nav pill.

```text
[ Slivers.SliverAppBar - Sticky & Collapsing ]
| [ User Avatar (40x40) ]    [ Greeting Title: "Morning," ]    [ Theme Toggle ] |
|                            [ Subtitle: "Aryan" (H1, Bold) ]     [ Bell Icon ] |
|                                                                             |
| [ AI Insight Chip: Sparkle Icon + "You slept 8h, great day to lift." ]      |

[ Slivers.SliverList - Scrollable Content ]

+-------------------------------------------------------------+
|                     HERO: Activity Rings                    |
|                [ Nested Concentric Circles ]                |
|           Outer: Calories | Mid: Output | Inner: Stand      |
|                                                             |
|           Center Text: "1,240 / 2,000 kcals active"         |
+-------------------------------------------------------------+

+-------------------------------------------------------------+
| QUICK ACTIONS (Horizontal Scrollable Row)                   |
| [ (Icon) Log Water ]  [ (Icon) Scan Meal ]  [ (Icon) Lift ] |
+-------------------------------------------------------------+

+-------------------------------------------------------------+
| BENTO GRID: Today's Snapshot (2x2 Auto-Flow Grid)           |
| *Behavior:*                                                 |
| - Dark Mode: Cards have 1px sheer white borders, NO shadows.|
| - Light Mode: Cards have NO borders, deep 40px soft shadows.|
|                                                             |
| +-------------------------+ +-----------------------------+ |
| | WATER PROGRESS          | | SLEEP SCORE             | | |
| | [ Vertical Wave Fill ]  | | [ 85 ]                  | | |
| | 1200 / 2500 ml          | | "Optimal Recovery"        | | |
| +-------------------------+ +-----------------------------+ |
|                                                             |
| +-------------------------+ +-----------------------------+ |
| | NEXT: PUSH WORKOUT      | | CURRENT MACROS            | | |
| | 45 Mins • 5 Exercises   | | [ P: 120g | C: 150g ]     | | |
| | [ START NOW Button ]    | | [ F: 45g ]                  | | |
| +-------------------------+ +-----------------------------+ |
+-------------------------------------------------------------+
```

### 2.2 AI Diet Scanner (Invoked via Center FAB)
**Behavior:** Takes over full screen. Pure camera UI.

```text
[ Full Screen Camera Viewport ]

[ Top Right: Flash Toggle Icon ] [ Top Left: Close 'X' ]

  +---------------------------------------------------+
  |                                                   |
  |             [ Breathing Reticle UI ]              |
  |           Align your meal within the box          |
  |                                                   |
  +---------------------------------------------------+

[ Bottom Control Panel - Transparent Gradient Overlay ]
| "Scanning ingredients & estimating calories..."             |
|                                                             |
|                     [ GIANT SHUTTER BUTTON ]                |
|                     (Haptic click, ring flash)              |
|                                                             |
|     (Icon) Type Manual          (Icon) Browse Gallery       |
```

**[ Result Bottom Sheet (Slides up post-capture) ]**
```text
|  +-------------------------------------------------------+  |
|  | [ Image Thumbnail Thumbnail ]  "Avocado Toast"          |  |
|  |                                                         |  |
|  | [ AI Sparkle ] Gemini Analysis:                         |  |
|  | Calories: 450 kcal                                      |  |
|  |                                                         |  |
|  | Protein: [====      ] 15g                               |  |
|  | Carbs:   [========= ] 45g                               |  |
|  | Fats:    [======    ] 22g                               |  |
|  |                                                         |  |
|  | [ RETAKE BUTTON ]         [ SAVE TO LOG BUTTON (Mint) ] |  |
|  +-------------------------------------------------------+  |
```

### 2.3 Gemini AI Coach (Chat Tab)
**Behavior:** Standard messaging view, keyboard overlays content pushing it up.

```text
[ Pinned Header ]
| [ AI Avatar Logo ] "HealthAI Coach" (Online indicator)      |

[ Scrollable Chat Area ]
|                                                             |
| [ AI Bubble - Soft Indigo Gradient ]                        |
| "Hey Aryan! Based on your high calorie count yesterday,     |
| I recommend a 4k run today. Want me to log it?"             |
|                                                             |
|                                  [ User Bubble - Obsidian ] |
|                                         "No, let's do arms" |
|                                                             |
| [ AI Bubble - Soft Indigo Gradient ]                        |
| "Got it. Generating an Upper Body Hypertrophy routine..."   |
|                                                             |
| [ WIDGET BUBBLE INJECTED BY AI ]                            |
| +---------------------------------------------------------+ |
| | ARMS & SHOULDERS (35 Min)                               | |
| | • Bicep Curls (3x12)                                    | |
| | • Tricep Extensions (3x12)                              | |
| | • Lateral Raises (4x15)                                 | |
| |                 [ START WORKOUT (Massive CTA Button) ]    | |
| +---------------------------------------------------------+ |

[ Pinned Bottom Input Area ]
| [ (+) Menu ]  [ Text Input Pill: "Type or speak..." ] [ Mic ]
```

### 2.4 Active Workout Player
**Behavior:** Distraction-free, pure black OLED background, screen wake-lock enabled.

```text
[ Header Row ]
|  [ V Minimize ]    "Bicep Curls" (Exercise 2 of 5)          |

[ Center Focus Area ]
|                                                              |
|                  +-----------------------+                   |
|                  |     [ 00:45 ]         |  <-- Interactive, |
|                  |     Rest Timer        |      Glowing Ring |
|                  +-----------------------+                   |
|                                                              |

[ Set List - Horizontal Rows ]
| Set | Previous    | Current Weight | Reps     |  Complete? |
|  1  | 15kg x 12   | [ Input: 15 ]  | [ In: 12 ] |  [ X ]   |
|  2  | 17.5kg x 10 | [ Input: 17.5] | [ In: 10 ] |  [ X ]   |
|  3  | 17.5kg x 10 | [ Input: ____] | [ In: __ ] |  [   ]   |

[ Bottom Fixed Action ]
|                 [ FINISH EXERCISE BUTTON ]                 |
```
