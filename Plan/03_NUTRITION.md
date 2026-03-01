# Nutrition & Diet Scanner — Detailed Plan
> Features: `/scanner`, Food logging, Nutrition tracking  
> Models: `MealDoc`, `DailyLogDoc`  
> Services: `GeminiService.analyzeFoodImage()`, `ScannerController`

---

## Vision

> Turn your phone camera into a complete nutritionist. Scan any food, get instant macro breakdown, track every meal throughout the day, and get AI-driven dietary advice tailored to your fitness goals.

---

## Current State

### What works
- Live camera preview with animated reticle
- Take photo → HuggingFace vision API (Qwen2.5-VL → Llama3.2-Vision fallback)
- Results sheet: meal name, calories, protein, carbs, fat — animated
- "Save to Log" → adds macros to `DailyLogDoc` (updates dashboard bento grid)
- Rate limit handling

### What's broken / dummy
- **Gallery button** — no action (just haptic feedback)
- **Manual entry button** — no action
- **Flash toggle** — turns on, can't turn off
- **Meal history** — `MealDoc` Isar model exists but never used; meals saved as totals only, no per-meal list
- **Calorie/protein goals** — hardcoded as 2000 kcal / 150g protein everywhere
- **Food history** — user can't see what they ate today or yesterday

---

## Phase 1 — Fix Bugs + Meal Log

### 1.1 Fix flash toggle
```dart
bool _flashOn = false;
// in onTap:
_flashOn = !_flashOn;
_cameraController?.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
```
Also update the flash icon to show the correct state.

### 1.2 Build Gallery picker
Use `image_picker` package (add to pubspec).  
On Gallery tap → `ImagePicker().pickImage(source: ImageSource.gallery)` → send bytes to same `analyzeMeal()` flow.

### 1.3 Build Manual Entry sheet
Bottom sheet with fields:
- Food name (text field with AI autocomplete)
- Calories (number)
- Protein, Carbs, Fat (number fields)
- Meal type (Breakfast / Lunch / Dinner / Snack) — chip selector
- Save → same `saveMealToLog()` flow

### 1.4 Build Meal Log (per-meal history)
**Change:** When saving a meal, write a `MealDoc` to Isar instead of (or in addition to) updating `DailyLogDoc` totals:
```dart
// ScannerController.saveMealToLog():
final meal = MealDoc()
  ..name = data['name'] ?? 'Meal'
  ..calories = calories
  ..protein = protein
  ..carbs = carbs
  ..fat = fat
  ..loggedAt = DateTime.now()
  ..mealType = 'snack'; // from manual entry
await isar.writeTxn(() => isar.mealDocs.put(meal));
```

**New screen: Nutrition Log** (`/nutrition/log`)
- Grouped by meal type (Breakfast / Lunch / Dinner / Snacks)
- Each meal: name, macro chips, time logged, delete button
- Daily total bar at top with macro ring chart
- Navigate from dashboard bento grid "Calories In" tap or from scanner

### 1.5 Calorie/macro goal personalization
Read user's goals from `UserDoc`:
- `UserDoc.calorieGoal` (new field) — default 2000
- `UserDoc.proteinGoal` — default 150g
- Show personalized % in scanner results: "42% of YOUR 1800 kcal goal"
- Goals editable in Profile screen

---

## Phase 2 — Smarter Scanning

### 2.1 Scan confidence indicator
The AI sometimes misidentifies food. Show a confidence chip:
- Green: "High confidence" (when response has no hedging language)
- Yellow: "Moderate" (when AI says "approximately" or similar)
- Red: "Uncertain" (when AI can't identify clearly)

### 2.2 Multi-food scanning
When the AI detects multiple foods in one image, return an array:
```json
{
  "items": [
    {"name": "Rice", "calories": 200, "protein": 4, "carbs": 44, "fat": 1},
    {"name": "Grilled Chicken", "calories": 180, "protein": 28, "carbs": 0, "fat": 6}
  ],
  "total": {"calories": 380, "protein": 32, "carbs": 44, "fat": 7}
}
```
Show each item as an expandable section in the results sheet with individual toggles (deselect items you didn't eat).

### 2.3 Portion size estimation
Add to vision prompt: "Also estimate the portion size (small/medium/large/exact grams if visible)."  
Show portion indicator in results.  
Allow user to adjust portion via a slider (0.5x / 1x / 1.5x / 2x) which scales macros in real time.

### 2.4 Barcode scanning
Use `mobile_scanner` package (add to pubspec).  
Open Foods Facts API (`https://world.openfoodfacts.org/api/v0/product/{barcode}.json`) — completely free, 3M+ products.  
Add a "Barcode" mode button next to the shutter button.  
Shows same results sheet with fetched nutritional data.

### 2.5 Food search by name
Add a search tab in the scanner bottom area:
- User types "banana" → search Open Foods Facts API for matching products
- Shows results with macros → tap to log

---

## Phase 3 — Nutrition Intelligence

### 3.1 Daily nutrition summary
On the dashboard, tap "Calories In" bento card → opens full nutrition day view:
- Macro ring chart (protein/carbs/fat as donut slices)
- Progress bars vs daily goals
- Meal timeline (8am: Breakfast 480 kcal, 1pm: Lunch 620 kcal)
- Net calories (calories in - calories burned)
- AI tip for the day

### 3.2 Weekly nutrition insights
Every Monday: AI generates a weekly nutrition summary:
- Average daily calories/macros vs goals
- Best/worst day analysis
- Specific actionable suggestion
- Stored in `DailyLogDoc.weeklyNutritionSummary` or new collection

### 3.3 Meal planning with AI
New feature in the AI Coach:
- User asks: "Plan my meals for tomorrow targeting 2000 kcal and 150g protein"
- AI returns a structured meal plan JSON (similar to workout plan JSON)
- Parsed and displayed as a "Meal Plan Card" in chat (like `WorkoutPlanCard`)
- Tap to preview → shows breakfast/lunch/dinner with macros
- "Add to my day" saves each meal as a `MealDoc` with `planned = true` flag

### 3.4 Dietary preferences & restrictions
- `UserDoc.preferences.dietary` field already exists: `['vegan', 'gluten_free']`
- Wire this to scanner and AI coach prompts
- Show dietary badges on meal cards: "Vegan", "Low carb", etc.

---

## Phase 4 — Advanced (Post-Beta)

- Recipe analysis: photograph a recipe card or paste a recipe URL → AI calculates per-serving macros
- Restaurant menu scanner: scan a menu → AI suggests best options for your goals
- Supplement tracker: log daily vitamins, protein powder, creatine
- Hydration goals per body weight: `UserDoc.weightKg * 35ml` = water goal
- Nutrition streaks: 5-day macro goal achievement

---

## Implementation Priority

| Task | Priority | Effort |
|---|---|---|
| Fix flash toggle | Critical | Tiny |
| Gallery picker | High | Small |
| Manual entry sheet | High | Small |
| Per-meal MealDoc saving | High | Small |
| Nutrition log screen | High | Medium |
| Personalized calorie/macro goals | High | Small |
| Barcode scanning | Medium | Medium |
| Portion size slider | Medium | Small |
| Multi-food results | Medium | Medium |
| Meal planning AI card | Medium | Large |
| Weekly nutrition insights | Low | Medium |

---

## Data Model Changes Needed

### Update `MealDoc` (currently unused)
```dart
@collection
class MealDoc {
  Id id = Isar.autoIncrement;
  late String name;
  int calories = 0;
  int protein = 0;
  int carbs = 0;
  int fat = 0;
  late DateTime loggedAt;
  String mealType = 'snack'; // breakfast/lunch/dinner/snack
  String source = 'scan'; // scan/manual/barcode/planned
  String? barcode;
  bool planned = false;
}
```

### Update `UserDoc`
```dart
// Add to UserDoc:
int calorieGoal = 2000;
int proteinGoal = 150;
int carbGoal = 250;
int fatGoal = 65;
int waterGoalMlOverride = 0; // 0 = auto-calculate from weight
```
