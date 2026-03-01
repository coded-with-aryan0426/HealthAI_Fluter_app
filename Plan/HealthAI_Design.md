# HealthAI - Premium UI/UX Design Specifications

## 1. Global Visual Language & Modern UI Assets

### 1.1 Color Palette
The app leverages a modern, meticulously crafted **Dual-Theme Platform (Light & Dark Mode)**. It does not simply invert colors; each mode has distinct elevation logic to ensure maximum legibility and premium feel regardless of time of day.
- **Primary Accent:** `Dynamic Mint` (`#00D4B2`) - Used for CTAs, active states, progress rings, and achievements. Remains vibrant in both modes.
- **Secondary Accent:** `Soft Indigo` (`#6B7AFF`) - Used for AI prompts, chat bubbles, and secondary actions.
- **Dark Mode (OLED Optimized - Depth via Elevation):** 
  - **Base Background:** `Deep Obsidian` (`#0B0E14`). Pure black on OLED displays.
  - **Elevated Surfaces/Cards:** `Charcoal Glass` (`#1A1D24` at 60% opacity with intense 30px native OS blur).
  - **Text:** Primary: `#FFFFFF`, Secondary: `#8A91A4`.
  - **Shadows:** None. Dark mode relies purely on subtle, 1px semi-transparent white borders (`#FFFFFF` at 5% opacity) and background blurs to separate layers.
- **Light Mode (Airy & Clean - Depth via Shadows):**
  - **Base Background:** `Pure White` (`#FFFFFF`) or slightly warm `Off-White` (`#FAFAFA`).
  - **Elevated Surfaces/Cards:** `Cloud Gray` (`#F4F6F9`) or pure white cards with soft, diffused drop shadows.
  - **Text:** Primary: `#1C1E23`, Secondary: `#6B7488`.
  - **Shadows:** Heavy use of extremely diffuse, low-opacity drop shadows (e.g., `BoxShadow(color: #000000.withOpacity(0.04), blurRadius: 40, offset: Offset(0, 10))`) to make white cards float above the white background.

### 1.2 Iconography & Premium Assets (Android 17 / iOS 26 Standard)
**DO NOT use default Material or Cupertino icons.** They look dated and unrefined for a premium app.
- **Icon Library:** Use **Phosphor Icons** (`phosphor_flutter` pack). They offer a consistent, ultra-modern, lightweight geometric weight that perfectly matches high-end iOS/Android design standards.
- **Icon Weights:** Use `Regular` for unselected states and `Fill` or `Duotone` with glowing shadows for active/selected states.
- **Glassmorphism & Blurs:** Heavy use of native-feeling blur algorithms. In Flutter, use `BackdropFilter` combined with `ImageFilter.blur(sigmaX: 20, sigmaY: 20)`. This must exactly mimic the heavy, frosted-glass look native to the newest OS control centers, ensuring the UI feels suspended over the background rather than painted on it.

### 1.3 Typography
- **Primary Font Family:** `Inter` (or `SF Pro` on iOS natively via `cupertino_icons` text themes). Chosen for its high legibility in dense data dashboards and clean, geometric aesthetic.
- **Sizes (Base 16px):**
  - H1 (Greeting): 32px, tracking -0.5px (Tight kerning for modern feel)
  - H2 (Section Titles): 22px
  - Body: 16px, line-height 1.5
  - Micro (Timestamps, Units): 12px, uppercase, letter-spacing +1px

### 1.4 Spacing, Geometry & Layout
- **Grid System:** 8pt grid system. All margins, paddings, and sizing are multiples of 8.
- **Border Radii (Squircle Geometry):**
  - Large Cards/Modals: `32px` (Mimicking the deep curve radii of modern flagship device corners).
  - Buttons/Small Cards: `16px`
  - Input Fields: `12px`
- **Screen Padding:** `24px` horizontal padding.

### 1.5 Animations & Micro-Interactions
*Powered by `flutter_animate` and custom Rive assets.*
- **Page Transitions:** Shared Axis (X or Z) or subtle Fade-and-Scale. No generic sliding.
- **Button Taps:** Down-scale to 95% on press, spring back to 100% on release with high-fidelity haptic feedback (`HapticFeedback.lightImpact()`).
- **Data Loading:** Shimmer effect (`#1A1D24` to `#242830`) matching the exact shape of the incoming data.
- **Theme Transition:** When toggling between Light and Dark mode, the entire app UI executes a fluid, 400ms cross-fade animation, ensuring text and icons smoothly interpolate their colors rather than instantly snapping.

---

## 2. Screen-by-Screen Breakdown

### 2.1 Onboarding & Authentication Flow
**Goal:** Feel like a premium health consultation, not a data entry form.
- **Layout:** Full-screen immersive gradients (Deep Obsidian blending into Soft Indigo at the bottom).
- **Logo:** Center screen. A minimalist abstract 'H' formed by two intersecting rings (Mint and Indigo). Pulse animation on load.
- **Interactive Prompts:** One question per screen (e.g., "What is your main goal?"). 
  - **Cards:** Large, tap-able cards (Height: 120px, Width: 100%) with an icon and title.
  - **Selection:** On tap, card border glows `Dynamic Mint`, slight haptic pop, automatically slides left to the next question.
- **Auth Bottom Sheet:** For returning users. Slips up from the bottom (Border Radius: 32px top-left/right). Apple/Google SSO buttons (Height: 56px, Radius: 16px, standard branding colors).

### 2.2 Dashboard (Home Tab)
**Goal:** Maximize data density without feeling cluttered. Dynamic based on time of day.
**Header:**
  - **Top Row (Height 60px):** 
    - Left: User Avatar (40px circle) + "Good Morning, Aryan" (H1, 32px).
    - Right: Notification Bell (24x24px icon, soft grey, red dot if active).
  - **AI Insight Chip (Below Greeting):** A pill-shaped container (Height 36px, `Charcoal Glass` bg, `Soft Indigo` border). Contains a real-time Gemini insight: ✨ *“You slept 8hrs. Great day for a heavy pull workout.”* Tapping expands into the AI Chat.
**Main Content (Scrollable):**
  - **Activity Rings (The Hero Widget):** 
    - Placed top-center (Size: 200x200px). 
    - 3 Concentric rings (Calories - Orange, Exercise - Mint, Stand/Habits - Indigo). 
    - **Animation:** Rings grow from 0% on page load with a smooth, 1.5s ease-out-cubic curve.
    - Center text: Current active calories in large, bold font.
  - **Quick Action Bar (Marquee or Horizontal Scroll):**
    - Row of circular buttons (64x64px) with icons: 💧 Log Water, 🍎 Scan Food, 🏋️ Start Workout. 
    - Gap: 16px. Background: `Charcoal Glass`.
  - **Today's Habits (Bento Box Layout):**
    - A 2x2 grid of cards filling the remaining width.
    - Card (Width: ~165px, Height: 120px, Radius: 20px).
    - Left icon + Title ("Read 10 Pages"). 
    - **Interaction:** Long-press to mark complete. The card fills with a gradient sweep and plays a success sound.

### 2.3 AI Diet Scanner (Floating Action Button + Camera)
**Goal:** Magical, frictionless food logging.
- **Trigger:** Center Floating Action Button (FAB) in the Bottom Nav Bar. The FAB is slightly oversized (64x64px), glowing `Dynamic Mint`, with a camera icon.
- **Camera ViewLayout:**
  - Minimalist camera UI. Full screen. 
  - A centered framing reticle (rounded corners, subtle breathing animation).
  - **Bottom Panel:** "Snap a meal or scan a barcode". Shutter button is a massive 80x80px clear ring.
- **Scanning State:**
  - After capture: The image freezes. A horizontal scanning line sweeps up and down the image (cyan glow).
  - Background blurs out.
  - A bottom sheet slides up (Height: 50% of screen).
  - Gemini visualizes its "thinking" with shimmering text -> "Identifying ingredients... 🥑 🥚 🍞".
  - **Result Card:** Displays macros (Protein, Carbs, Fats) as horizontal progress bars that animate from 0 to their value. Two massive buttons at bottom: "Looks Good (Save)" or "Retake".

### 2.4 Gemini AI Coach (Chat Tab)
**Goal:** A personal trainer and nutritionist in your pocket.
- **Layout:** Standard chat interface but elevated.
- **Header:** Sticky top. Shows "HealthAI Coach" with an animated "online" status dot.
- **Message Bubbles:**
  - User: Aligned right. Background: `Charcoal Glass`. Text: White. Max-width: 75%. Radius: 20px (bottom-right 4px).
  - AI: Aligned left. Background: Very subtle deep purple/indigo gradient. Radius: 20px (bottom-left 4px).
- **Interactive Payloads:** AI doesn't just send text. It sends *Widgets*.
  - If AI suggests a workout, the chat bubble includes a custom Card (Width: 100% of bubble, Height: 180px) showing the workout summary and a huge "Start Now" button.
- **Input Field:** Fixed to bottom. Height 56px. Pill shape. Includes a prominent microphone icon for voice inputs. When typing, "Send" button morphs into view via a spring animation.

### 2.5 Workout Player (Active State)
**Goal:** Distraction-free, dark, highly legible during physical exertion.
- **Layout:** Pure black screen (`#000000`) to save battery (OLED) and reduce glare.
- **Top:** Current exercise name (Massive font, H1, centered).
- **Middle:** A large, interactive rest timer. Circular countdown (Size: 250x250px) glowing `Dynamic Mint`.
- **Bottom List:** The sets for the current exercise. 
  - Row layout: Set Number | Prev Weight | Input Field (Current Weight) | Input Field (Reps) | Checkbox.
  - Checkbox: A large square (40x40px). Tapping it marks the set complete, turns the row green, and automatically starts the large circular rest timer in the middle of the screen.

### 2.6 Bottom Navigation Bar
- **Layout:** Floating above the content, attached to the bottom. Not a full-width block, but a rounded pill shape (Margin-bottom: 24px, Margin-horizontal: 32px, Height: 72px, Radius: 36px).
- **Background:** Blur effect (`BackdropFilter` with `sigmaX: 10, sigmaY: 10`, Color: `Charcoal Glass` at 70%).
- **Icons:** 4 icons. Home, Habits, [FAB Camera breaks the top of the pill], Chat, Profile.
- **Active State:** The active icon scales up 1.2x and changes color to `Dynamic Mint`. A tiny, brilliant glowing dot appears directly under the active icon.

---

## 3. Optimization & "No Wasted Space" Philosophy
- **Dynamic Type Scaling:** Text explicitly scales down gracefully on smaller devices (iPhone SE) without truncating.
- **Collapsing Headers (Slivers):** As the user scrolls down the Dashboard, the large "Good Morning" greeting fades and collapses into a small pinned AppBar to reclaim vertical space.
- **Bento Grid Adaptability:** The dashboard cards automatically rearrange from a 2-column grid on phones to a 3 or 4-column grid on tablets/foldables, ensuring the entire viewport is utilized productively.
