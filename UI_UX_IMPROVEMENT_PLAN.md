# HealthAI — UI/UX Improvement Plan

> **Goal**: Elevate the entire app to a premium, animated, responsive, and visually uniform experience — consistent in both light and dark modes. Every screen should feel alive, transitions should be silky, typography clear, and interactions satisfying.

---

## 1. What to Improve & Where

### 1.1 Theme System (`lib/src/theme/`)
| Issue | Fix |
|---|---|
| Font only set at display/title level — body sizes inconsistent | Full `TextTheme` with all levels: `displayLarge→labelSmall` |
| No shared spacing/radius tokens | Add `AppSpacing` + `AppRadius` constants |
| Light mode looks flat — card shadows too subtle | Stronger layered shadows in light mode |
| No `InputDecorationTheme`, `BottomSheetTheme`, `DialogTheme` | Inject all into `ThemeData` |
| `withOpacity()` used everywhere = deprecated in Flutter 3.27 | Replace with `withValues(alpha:)` |
| No page-transition animation in router | Add custom `CustomTransitionPage` factory |

### 1.2 App Shell (`app_shell.dart`)
| Issue | Fix |
|---|---|
| Nav bar has no animated indicator slide between tabs | Add `AnimatedPositioned` sliding pill |
| FAB is placed too high on some screens (no safe-area offset) | Fix bottom padding calculation |
| Back-gesture exit dialog uses plain `AlertDialog` — unstyled | Replace with themed bottom sheet |
| Page switching has no cross-fade or slide transition | Add `AnimatedSwitcher` or GoRouter page transitions |

### 1.3 Splash Screen (`splash_screen.dart`)
| Issue | Fix |
|---|---|
| Fade-out is just `Opacity` — abrupt | Wrap in `Hero` + smooth fade+scale transition |
| Background stays plain colour | Add subtle animated gradient particles |

### 1.4 Onboarding (`onboarding_screen.dart`)
| Issue | Fix |
|---|---|
| Page indicator dots are plain | Replace with animated pill indicator |
| Each page content drops in with same slide — monotonous | Stagger each field with distinct delay |
| Input fields use default decoration | Custom themed inputs: rounded, accent-focused |
| Goal / fitness-level chips are plain `FilterChip` | Gradient-border cards with icon |
| Progress line at top is thin | Animated segmented progress bar |
| "Next" button stays same during loading | Shimmer + spinner state |

### 1.5 Dashboard (`dashboard_screen.dart`)
| Issue | Fix |
|---|---|
| SliverAppBar background uses `withOpacity` (deprecated) | Fix + stronger blur |
| Bento grid cards have large font (30px) that clips on small phones | Use `FittedBox` |
| Water tracker long-press hint is invisible | Show subtle ripple badge "Hold to set custom" |
| `_RingLegend` animation delay is too short | Stagger 600ms → 800ms |
| Health Tools section is a plain grid — no depth | Add hover-lift shadow on press |
| AI Insight card shimmer is barely visible | Stronger shimmer + pulsing border |
| Scroll physics `BouncingScrollPhysics` — no `decelerationRate` | Add `ClampingScrollPhysics` for Android, Bouncing for iOS |
| Section titles ("Today's Stats", "Health Tools") plain | Add gradient accent dash before title |

### 1.6 Workout Screens
| Issue | Fix |
|---|---|
| Library screen cards don't animate on scroll into view | `AnimationLimiter` + staggered `FadeInSlide` |
| Player screen timer ring has no glow | Add `BoxShadow` pulse on tick |
| Summary screen stat numbers appear instantly | Count-up number animation |
| Muscle map uses `flutter_svg` but no shimmer loading state | Add loading placeholder |
| Strength charts axis labels are small + clipped | Fix overflow, larger font |

### 1.7 Nutrition Screen
| Issue | Fix |
|---|---|
| Macro progress bars plain height-4 bars | Increase to height-6, rounded caps, glow |
| Meal entries list has no slide-in animation | Stagger list items |
| Empty state is a plain `Text` | Illustrated empty state widget |
| Food scan bottom sheet plain white | Themed glass sheet |

### 1.8 Fasting Screen
| Issue | Fix |
|---|---|
| Timer ring is static until started | Subtle idle-pulse animation even before start |
| "Start Fast" button plain green | Gradient button with ripple |
| Phase indicators are coloured boxes | Rounded pill badges with icons |

### 1.9 Habits Screen
| Issue | Fix |
|---|---|
| Habit rows have no swipe-to-complete | `Dismissible` with green swipe |
| Streak badge is a plain number | Flame icon with glow + count-up |
| Calendar dots too small | 10px → 14px with accent glow |

### 1.10 Supplements Screen
| Issue | Fix |
|---|---|
| Cards are plain rectangles | Match `_BentoCard` style |
| Time chips plain `Chip` | Pill chips with accent colour |

### 1.11 Body Composition Screen
| Issue | Fix |
|---|---|
| Charts have hard edges | Smooth `lineBarsData` with `isCurved: true` |
| Weight log list no animation | Stagger on scroll |

### 1.12 Settings Screen
| Issue | Fix |
|---|---|
| Section headers are plain `Text` | Styled uppercase + accent line |
| Toggle rows have no divider spacing | 12px spacing between groups |
| Destructive actions (delete data) plain red text | Danger card with icon |

### 1.13 Chat / Gemma Setup Screen
| Issue | Fix |
|---|---|
| Message bubbles no appear animation | Slide-up + fade on new message |
| Typing indicator is a spinner | Three-dot pulse animation |
| Setup screen progress bar plain | Gradient segmented bar |

---

## 2. Global UX Fixes (applied everywhere)

| Fix | Impact |
|---|---|
| Replace all `withOpacity()` → `withValues(alpha:)` | Silences 200+ deprecation warnings |
| `BouncingScrollPhysics` on iOS, `ClampingScrollPhysics` on Android | Platform-correct scroll feel |
| `HapticFeedback` on every tap action | Tactile feedback |
| `AnimatedPressable` wrapper for all tappable cards | Consistent press-scale feedback |
| `PageTransitionsTheme` with `FadeUpwards` on Android, `CupertinoPageTransition` on iOS | Native-feel navigation |
| Consistent border radius: 12 (chips), 16 (buttons), 20 (cards), 28 (hero cards) | Visual harmony |
| Consistent horizontal padding: 24px throughout | Clean alignment |
| `ScrollbarTheme` with auto-hiding thin scrollbar | Polish |

---

## 3. Implementation Order

1. `app_colors.dart` + `app_theme.dart` — foundation
2. `app_ui.dart` (new shared widgets file)
3. `app_router.dart` — page transitions
4. `app_shell.dart` — nav bar
5. `dashboard_screen.dart` — hero screen
6. `onboarding_screen.dart`
7. `splash_screen.dart`
8. Workout screens (library → player → summary)
9. Nutrition + Fasting
10. Habits + Supplements + Body Composition
11. Settings + Profile
12. Chat + Gemma Setup

---

## 4. Design Tokens Reference

```
Spacing: 4, 8, 12, 16, 20, 24, 28, 32, 40, 48
Radius: chip=12, button=16, card=20, hero=28, sheet=32
Font: Inter (already set)  — weights: 400, 500, 600, 700, 800
Shadows dark: accent.withValues(alpha:0.08) blur:20 y:8
Shadows light: black.withValues(alpha:0.06) blur:20 y:8
Transition duration: fast=150ms, normal=250ms, slow=400ms, page=350ms
Transition curve: easeOutCubic for slides, easeOutBack for pop-in
```
