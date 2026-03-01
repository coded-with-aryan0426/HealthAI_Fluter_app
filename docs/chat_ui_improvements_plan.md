# HealthAI Chat UI/UX — Improvement Plan

## Bugs to Fix

### 1. "HuggingFace" Label Visible in AppBar
- **Problem**: The subtitle under "HealthAI Coach" reads `Cloud · HuggingFace` — exposing the underlying API provider to users.
- **Fix**: Replace with clean provider-agnostic labels: `Cloud · AI` (online) and `On-Device · Offline` (offline). Remove all HuggingFace mentions.

### 2. Auto-Creates New Chat Session on Every Visit
- **Problem**: `initState` calls `startNewSession()` unconditionally if `chatControllerProvider == null`, which fires every time the screen is cold-opened (e.g. from onboarding AI choice cards). This creates blank sessions.
- **Fix**: Only start a new session if navigated via explicit "New Chat" trigger. Check if any sessions exist first; if so, resume the most recent one instead of creating a blank new one.

### 3. Scroll-Down Button Hidden Behind Input Bar
- **Problem**: The `_showScrollDown` button is placed at `top: -20` inside a Stack with the input bar, making it overlap/obscure the text input.
- **Fix**: Move the scroll-down button outside the input bar Stack, positioned as a floating overlay above the input area.

---

## UI/UX Improvements

### 4. Input Bar — WhatsApp-Style Transparent/Blur Design
- Replace the opaque card with a frosted-glass `BackdropFilter` container.
- Round pill shape, fully transparent background.
- Smooth border glow when typing (indigo accent).
- Attach button left, Mic + Send button right.
- Mic button: round green filled (like WhatsApp send) when active.
- Send button animates in/out replacing mic when text is present.

### 5. New AI Logo/Avatar
- Custom painted neural-network orb logo replacing the generic `auto_awesome` icon.
- Animated gradient pulse on the avatar in AppBar and welcome screen.
- Layered rings with gradient spark effect.

### 6. Premium Chat Screen — Full Space Utilisation
- Messages stretch to use full screen width.
- AI bubbles: frosted-glass surface with subtle shimmer border.
- User bubbles: deep indigo gradient, rounded pill.
- Timestamps shown on long-press.
- Improved typing dots with wave animation.

### 7. Welcome/Empty State
- Full-height centered layout.
- Large animated logo with breathing glow.
- Staggered capability pill entrance animations.
- Suggestion tiles with subtle shimmer on idle.

### 8. Animations & Transitions
- Message enter: `slideY + fadeIn` (already partially done — improve).
- Keyboard show/hide: smooth input bar slide.
- Streaming cursor: smooth blink.
- AppBar: blur + gradient underline on scroll.
- Send button: scale spring animation on press.
- Haptic feedback on: send, long-press, mic toggle, session switch.

### 9. AppBar Design
- Cleaner 2-action header: Report + Cloud-toggle only.
- Provider label removed, replaced with clean "AI Ready" status.
- Custom logo widget in title slot.

### 10. Chat Drawer (History)
- Dark frosted-glass surface.
- Session tiles: show message preview + time.
- Active session: indigo left border accent.
- Swipe-to-delete gesture on sessions.

---

## Implementation Order
1. Fix bugs (#1, #2, #3)
2. Input bar redesign (#4)
3. New logo (#5)
4. Chat screen full redesign (#6, #7, #8)
5. AppBar clean-up (#9)
6. Drawer improvements (#10)
