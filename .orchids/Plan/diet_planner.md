# AI Diet Planner — Complete Architecture & Implementation Plan

> **Scope:** Production-grade AI Nutrition & Diet Planning feature for HealthAI  
> **Stack:** Flutter · Riverpod · Isar · GoRouter  
> **Design System:** Phosphor Icons · Dynamic Mint · Charcoal Glass · Inter  
> **Status:** Detailed design ready for implementation

---

## Table of Contents

1. [Feature Overview](#1-feature-overview)
2. [System Architecture](#2-system-architecture)
3. [Data Flow Architecture](#3-data-flow-architecture)
4. [Database Schema](#4-database-schema)
5. [AI Inference Pipeline](#5-ai-inference-pipeline)
6. [Nutritional Logic Engine](#6-nutritional-logic-engine)
7. [State Management Flow](#7-state-management-flow)
8. [API Design](#8-api-design)
9. [UI/UX Specification](#9-uiux-specification)
10. [Offline Strategy](#10-offline-strategy)
11. [Implementation Roadmap](#11-implementation-roadmap)

---

## 1. Feature Overview

The AI Diet Planner operates as a **personal clinical-grade nutritionist** embedded inside HealthAI. It is not a static calorie counter — it is a dynamic, AI-driven system that learns from the user's food history, adapts to their goals, and generates personalized plans that evolve over time.

### Core Capabilities

| Capability | Description |
|---|---|
| AI Meal Planning | Generate daily/weekly plans based on goals, preferences, and health data |
| Food Scanner | Camera + gallery image analysis via AI Vision (cloud/offline depending on availability) |
| Nutrition Analysis | Compare intake vs targets; detect deficiencies and excesses |
| Food Logging | Timestamped per-meal entries with full macro/micronutrient data |
| AI Suggestion Engine | Recommend foods, flag risks, suggest alternatives |
| Progress Dashboard | Daily/weekly visual reports, nutrient scoring, trend charts |
| Barcode Scanner | Open Food Facts API integration for 3M+ packaged products |
| Personalization | BMR/TDEE-based targets, dietary preferences, medical flags |

### What Makes This Different

- **Context-aware AI**: Every suggestion is built from the user's actual logged data, not generic templates
- **Bi-directional sync**: Nutrition logs update the dashboard in real-time; dashboard metrics feed back into AI context
- **Micronutrient awareness**: Goes beyond protein/carbs/fat to track vitamins, minerals, fiber, sodium
- **Adaptive plans**: Meal plans adjust when workouts are logged, sleep is poor, or calorie deficit is too aggressive

---

## 2. System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        HealthAI App                             │
│                                                                 │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │  Nutrition  │  │  AI Coach    │  │     Dashboard          │ │
│  │  Screen     │  │  Chat        │  │     (Bento Grid)       │ │
│  │  /nutrition │  │  /chat       │  │     /dashboard         │ │
│  └──────┬──────┘  └──────┬───────┘  └──────────┬─────────────┘ │
│         │                │                      │               │
│  ┌──────▼────────────────▼──────────────────────▼─────────────┐ │
│  │                  Riverpod State Layer                       │ │
│  │  mealsForDateProvider · mealPlanProvider · macroProvider   │ │
│  │  nutritionInsightProvider · foodScanProvider               │ │
│  └──────┬──────────────────────────────────────┬──────────────┘ │
│         │                                      │                │
│  ┌──────▼──────────┐              ┌────────────▼─────────────┐  │
│  │  Isar Local DB  │              │    AIService             │  │
│  │  MealDoc        │              │    analyzeFoodImage()    │  │
│  │  MealPlanDoc    │              │    generateMealPlan()    │  │
│  │  NutritionLog   │              │    analyzeNutrition()    │  │
│  │  UserDoc        │              │    weeklyInsight()       │  │
│  └──────┬──────────┘              └────────────┬─────────────┘  │
│         │                                      │                │
│  ┌──────▼──────────┐              ┌────────────▼─────────────┐  │
│  │  LocalDBService │              │  Cloud AI / On-device AI │  │
│  │  (offline-first)│              │  (selected at runtime)   │  │
│  └─────────────────┘              └──────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              External APIs (optional/cached)             │   │
│  │  Open Food Facts API · USDA FoodData Central API         │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

**Presentation Layer** (`lib/src/features/nutrition/presentation/`)
- All screens, widgets, bottom sheets, charts
- Reads state via `ref.watch()`, triggers actions via `ref.read().notifier`
- No business logic — purely reactive

**Application Layer** (`lib/src/features/nutrition/application/`)
- Riverpod notifiers and providers
- Orchestrates: local DB reads/writes, AI calls, goal calculations
- Exposes clean state objects to UI

**Domain Layer** (`lib/src/features/nutrition/domain/`)
- Pure Dart models: `MealPlan`, `NutritionTargets`, `FoodScanResult`, `WeeklyReport`
- No Flutter or Isar dependencies

**Data Layer**
- `LocalDBService` (Isar): offline-first persistence
- `AIService`: AI inference wrapper (routes to cloud or on-device model based on availability)
- `OpenFoodFactsService`: barcode/search API wrapper

---

## 3. Data Flow Architecture

### 3.1 Food Scan Flow

```
User taps camera / picks gallery image
        │
        ▼
ScannerController.captureAndAnalyze()
        │
        ├── Compress image (max 1MB for API efficiency)
        ├── Show scanning animation (sweeping line)
        │
        ▼
AIService.analyzeFoodImage(imageBytes)
        │
        ├── Build multimodal prompt (image + structured JSON instruction)
        ├── Call AI Vision (cloud or on-device based on availability)
        ├── Parse JSON response → FoodScanResult
        │
        ▼
ScanResultSheet (bottom sheet 60% height)
        │
        ├── Show: name, calories, macros, micronutrients, health score
        ├── Portion slider (0.5x / 1x / 1.5x / 2x) → scales values live
        ├── Meal type chip selector
        │
        ▼ User taps "Log Meal"
        │
MealsNotifier.add()
        │
        ├── Write MealDoc to Isar
        ├── Update DailyActivityProvider totals (dashboard sync)
        └── Trigger nutrition analysis check (deficiency alerts)
```

### 3.2 Meal Plan Generation Flow

```
User opens Meal Planner tab or asks AI Coach
        │
        ▼
MealPlanNotifier.generatePlan(duration, goal)
        │
        ├── Read UserDoc (goals, preferences, allergies, weight, height)
        ├── Read last 7 days MealDocs (eating patterns)
        ├── Calculate NutritionTargets (BMR → TDEE → macro split)
        │
        ▼
AIService.generateMealPlan(context)
        │
        ├── Structured prompt with user context + targets
        ├── Returns JSON: { days: [ { meals: [...] } ] }
        ├── Parse → MealPlan domain model
        │
        ▼
MealPlanScreen renders interactive plan
        │
        ├── Day-by-day cards with swipe navigation
        ├── Per-meal: tap to expand, see macros, swap meal
        ├── "Adopt Plan" → bulk-write to MealDoc (planned=true)
        └── "Adopt Day" → write only selected day's meals
```

### 3.3 Nutrition Analysis Flow

```
Triggered: after every meal log, daily at 9pm, on manual refresh
        │
        ▼
NutritionAnalysisNotifier.analyze(date)
        │
        ├── Aggregate today's MealDocs
        ├── Compare vs NutritionTargets (from UserDoc)
        ├── Detect: deficiencies, excesses, missed micronutrients
        │
        ▼
AIService.analyzeNutrition(summary)
        │
        ├── Lightweight text prompt (no image)
        ├── Returns: { score, alerts[], suggestions[], positives[] }
        │
        ▼
NutritionInsightState
        │
        ├── Shown in Nutrition Screen insight card
        ├── Critical alerts shown as banners
        └── Suggestions surfaced in AI Coach context
```

---

## 4. Database Schema

### 4.1 MealDoc (Isar — existing, extend)

```dart
@collection
class MealDoc {
  Id id = Isar.autoIncrement;

  // Identity
  late String name;
  String mealType = 'Snack';        // Breakfast / Lunch / Dinner / Snack
  late DateTime dateLogged;
  String source = 'manual';         // manual / scan / barcode / planned / ai_generated

  // Macros
  int calories = 0;
  int proteinGrams = 0;
  int carbsGrams = 0;
  int fatGrams = 0;

  // Micronutrients (new)
  double fiberGrams = 0;
  double sodiumMg = 0;
  double sugarGrams = 0;
  double saturatedFatGrams = 0;
  double calciumMg = 0;
  double ironMg = 0;
  double vitaminCMg = 0;
  double vitaminDMcg = 0;
  double potassiumMg = 0;

  // Metadata
  bool aiGenerated = false;
  bool planned = false;
  List<String> ingredientsDetected = [];
  String? barcodeId;
  double portionMultiplier = 1.0;   // User-adjusted portion (0.5x / 1x / 2x)
  double healthScore = 0;           // 0–100 AI-scored health quality
  String? imageLocalPath;           // Cached scan image path

  // User feedback (for personalization loop)
  bool? userApproved;               // null=not rated, true=good, false=bad
  String? userNote;
}
```

### 4.2 MealPlanDoc (Isar — new)

```dart
@collection
class MealPlanDoc {
  Id id = Isar.autoIncrement;

  late DateTime createdAt;
  late DateTime targetDate;         // Start date of the plan
  int durationDays = 7;             // 1 / 7 / 30
  String goal = 'maintenance';      // fat_loss / muscle_gain / maintenance
  String status = 'draft';          // draft / active / completed

  // JSON-serialized plan data (stored as string, parsed on read)
  late String planJson;

  // Summary
  int avgDailyCalories = 0;
  int avgDailyProtein = 0;
  String userContextSnapshot = '';  // Snapshot of user data at generation time
}
```

### 4.3 NutritionLogDoc (Isar — new, daily aggregate)

```dart
@collection
class NutritionLogDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late DateTime date;               // Midnight-normalized

  // Daily totals (auto-computed from MealDocs)
  int totalCalories = 0;
  int totalProtein = 0;
  int totalCarbs = 0;
  int totalFat = 0;
  double totalFiber = 0;
  double totalSodium = 0;
  double totalSugar = 0;

  // Goals (snapshot of user goals at this date)
  int calorieGoal = 2000;
  int proteinGoal = 150;

  // AI analysis result (cached)
  String? aiInsightJson;            // Cached NutritionInsight JSON
  DateTime? insightGeneratedAt;

  // Daily score (0–100)
  double nutritionScore = 0;
}
```

### 4.4 UserDoc Extensions (add to existing)

```dart
// Add to existing UserDoc:
int calorieGoal = 2000;
int proteinGoalG = 150;
int carbGoalG = 250;
int fatGoalG = 65;
int waterGoalMlOverride = 0;        // 0 = auto from weight

// Body metrics (for BMR calculation)
double weightKg = 70;
double heightCm = 170;
int ageYears = 25;
String gender = 'male';             // male / female / other
String activityLevel = 'moderate';  // sedentary / light / moderate / active / very_active

// Dietary profile
List<String> dietaryPreferences = [];   // vegan / vegetarian / keto / paleo / gluten_free
List<String> foodAllergies = [];        // nuts / dairy / gluten / shellfish / eggs / soy
List<String> medicalConditions = [];    // diabetes / hypertension / high_cholesterol

// Fitness goal
String primaryGoal = 'maintenance'; // fat_loss / muscle_gain / maintenance / recomposition

// Meal planning preferences
int mealsPerDay = 3;                // 2 / 3 / 4 / 5 / 6
bool includePrepTime = true;
String cuisinePreference = '';      // Indian / Mediterranean / Western / Asian / Any
```

---

## 5. AI Inference Pipeline

### 5.1 Food Scan Prompt (Vision AI)

```
SYSTEM:
You are a certified nutritionist and food analyst. Analyze the food in the image with precision.
Return ONLY valid JSON, no markdown, no explanation.

USER (multimodal: image + text):
Analyze this food image. The user's dietary preferences are: {preferences}.
Return this exact JSON structure:

{
  "name": "string (dish name)",
  "confidence": "high|medium|low",
  "portion_estimate": "string (e.g. '1 cup, ~240g')",
  "calories": number,
  "protein_g": number,
  "carbs_g": number,
  "fat_g": number,
  "fiber_g": number,
  "sugar_g": number,
  "sodium_mg": number,
  "saturated_fat_g": number,
  "vitamins": { "vitamin_c_mg": number, "vitamin_d_mcg": number },
  "minerals": { "calcium_mg": number, "iron_mg": number, "potassium_mg": number },
  "health_score": number (0-100),
  "health_notes": "string (1 sentence about health quality)",
  "ingredients_detected": ["string"],
  "items": [
    { "name": "string", "calories": number, "protein_g": number, "carbs_g": number, "fat_g": number }
  ]
}

All numbers are for the estimated portion visible. If multiple dishes, populate items[].
```

### 5.2 Meal Plan Generation Prompt (Text AI)

```
SYSTEM:
You are a certified sports dietitian and meal planning expert. Generate realistic, 
practical meal plans with locally available ingredients.
Return ONLY valid JSON.

USER:
Generate a {duration}-day meal plan for:
- Goal: {goal} (fat_loss/muscle_gain/maintenance)
- Daily calories: {calorieTarget} kcal
- Protein target: {proteinTarget}g
- Dietary preferences: {preferences}
- Allergies: {allergies}
- Cuisine preference: {cuisine}
- Meals per day: {mealsPerDay}
- User context: {recentEatingPatterns}

Return:
{
  "plan_summary": {
    "avg_daily_calories": number,
    "avg_daily_protein": number,
    "primary_foods": ["string"],
    "plan_notes": "string"
  },
  "days": [
    {
      "day": number,
      "date_offset": number,
      "total_calories": number,
      "total_protein": number,
      "meals": [
        {
          "meal_type": "Breakfast|Lunch|Dinner|Snack",
          "name": "string",
          "description": "string",
          "prep_time_min": number,
          "calories": number,
          "protein_g": number,
          "carbs_g": number,
          "fat_g": number,
          "ingredients": ["string"],
          "instructions": "string (2-3 steps max)"
        }
      ]
    }
  ]
}
```

### 5.3 Nutrition Analysis Prompt (Text AI — lightweight)

```
SYSTEM:
You are a clinical nutritionist. Analyze the user's daily food intake briefly and precisely.
Return ONLY valid JSON.

USER:
Today's intake summary:
- Calories: {consumed} / {goal} kcal
- Protein: {protein}g / {proteinGoal}g
- Carbs: {carbs}g / {carbGoal}g
- Fat: {fat}g / {fatGoal}g
- Fiber: {fiber}g
- Sodium: {sodium}mg
- Meals logged: {meals}
- User goal: {goal}

Return:
{
  "score": number (0-100),
  "grade": "A|B|C|D|F",
  "summary": "string (1 sentence)",
  "positives": ["string"],
  "alerts": [
    { "type": "deficiency|excess|warning", "nutrient": "string", "message": "string", "severity": "low|medium|high" }
  ],
  "suggestions": [
    { "priority": number, "message": "string", "food_example": "string" }
  ],
  "tomorrow_tip": "string"
}
```

### 5.4 Weekly Insight Prompt (Text AI — cached, weekly)

```
SYSTEM:
You are a dietitian providing a weekly nutrition review. Be specific, actionable, encouraging.
Return ONLY valid JSON.

USER:
7-day nutrition summary:
{dailySummaries} (array of daily totals)
User goal: {goal}
Avg daily calories: {avgCal} / {goal}
Avg protein: {avgProtein}g
Best day: {bestDay}
Worst day: {worstDay}

Return:
{
  "avg_calories": number,
  "avg_protein": number,
  "consistency_score": number (0-100),
  "week_grade": "A|B|C|D|F",
  "headline": "string (punchy summary line)",
  "achievements": ["string"],
  "improvements": ["string"],
  "key_insight": "string (most important finding)",
  "next_week_focus": "string (one actionable goal)"
}
```

### 5.5 Model Routing Strategy

The app selects the AI model at runtime based on network availability and user requirements:

| Task | Mode | Notes |
|---|---|---|
| Food image scan | Cloud (online) / On-device (offline) | Vision capability required |
| Meal plan generation | Cloud preferred | Complex structured output |
| Daily nutrition analysis | Cloud or on-device | Text-only, lightweight |
| Weekly insight | Cloud preferred | Cached weekly, quality matters |

---

## 6. Nutritional Logic Engine

### 6.1 BMR Calculation (Mifflin-St Jeor)

```dart
double calculateBMR(UserDoc user) {
  // Male: BMR = 10W + 6.25H - 5A + 5
  // Female: BMR = 10W + 6.25H - 5A - 161
  final base = (10 * user.weightKg) + (6.25 * user.heightCm) - (5 * user.ageYears);
  return user.gender == 'male' ? base + 5 : base - 161;
}
```

### 6.2 TDEE Calculation (Activity Multiplier)

```dart
double calculateTDEE(double bmr, String activityLevel) {
  const multipliers = {
    'sedentary':   1.2,    // Desk job, no exercise
    'light':       1.375,  // Light exercise 1-3 days/week
    'moderate':    1.55,   // Moderate exercise 3-5 days/week
    'active':      1.725,  // Heavy exercise 6-7 days/week
    'very_active': 1.9,    // Athlete / physical job
  };
  return bmr * (multipliers[activityLevel] ?? 1.55);
}
```

### 6.3 Calorie Target by Goal

```dart
int calculateCalorieTarget(double tdee, String goal) {
  switch (goal) {
    case 'fat_loss':      return (tdee * 0.80).round(); // 20% deficit
    case 'muscle_gain':   return (tdee * 1.10).round(); // 10% surplus
    case 'recomposition': return tdee.round();           // Maintenance + high protein
    default:              return tdee.round();           // Maintenance
  }
}
```

### 6.4 Macro Distribution

```dart
NutritionTargets calculateMacros(int calorieTarget, String goal, double weightKg) {
  late int proteinG, carbsG, fatG;

  switch (goal) {
    case 'fat_loss':
      // High protein to preserve muscle, lower carbs
      proteinG = (weightKg * 2.2).round();          // 2.2g/kg
      fatG = ((calorieTarget * 0.28) / 9).round();  // 28% from fat
      carbsG = ((calorieTarget - (proteinG * 4) - (fatG * 9)) / 4).round();
    case 'muscle_gain':
      // High protein + high carbs for energy
      proteinG = (weightKg * 2.0).round();          // 2.0g/kg
      carbsG = ((calorieTarget * 0.45) / 4).round();// 45% from carbs
      fatG = ((calorieTarget - (proteinG * 4) - (carbsG * 4)) / 9).round();
    default: // maintenance / recomposition
      // Balanced: 30% protein, 40% carbs, 30% fat
      proteinG = ((calorieTarget * 0.30) / 4).round();
      carbsG = ((calorieTarget * 0.40) / 4).round();
      fatG = ((calorieTarget * 0.30) / 9).round();
  }

  return NutritionTargets(
    calories: calorieTarget,
    proteinG: proteinG,
    carbsG: carbsG,
    fatG: fatG,
    fiberG: 25,         // WHO recommendation
    sodiumMg: 2300,     // American Heart Association limit
  );
}
```

### 6.5 Dynamic Adaptation Rules

The AI plan adjusts automatically based on these triggers:

| Trigger | Adaptation |
|---|---|
| Calorie deficit >25% for 3+ days | Increase calories by 100 kcal, alert user |
| Protein <80% of goal for 5+ days | Surface high-protein food suggestions daily |
| Workout logged (strength) | Add +100–200 kcal to that day's target |
| Sleep <6h logged | Reduce recommended workout intensity, add recovery foods |
| User skips planned meal | Redistribute macros to remaining meals |
| Weight loss >1.5kg/week | Flag as too aggressive, suggest deficit reduction |
| Fiber consistently <15g | Flag in weekly insight, suggest fiber-rich swaps |

### 6.6 Personalization Engine Logic

```
User logs meal → MealDoc written to Isar
        │
        ▼
PatternAnalyzer runs (on background isolate, max 50ms)
        │
        ├── Identify: preferred meal times, most-logged foods, avg portion sizes
        ├── Detect: consistent macro gaps (protein short on weekends, etc.)
        ├── Build: UserEatingProfile (serialized to UserDoc.eatingProfileJson)
        │
        ▼
Next AI call injects UserEatingProfile into context
        │
        └── AI suggestions become progressively more personalized
```

---

## 7. State Management Flow

### 7.1 Provider Dependency Graph

```
userProvider (UserDoc)
    │
    ├── nutritionTargetsProvider (computed from UserDoc BMR/TDEE)
    │       └── used by: NutritionScreen, DashboardScreen
    │
    └── mealsForDateProvider(DateTime) (FamilyNotifier)
            ├── read by: NutritionScreen
            ├── written by: ScannerController, MealPlanNotifier
            └── syncs to: dailyActivityProvider (dashboard)

mealPlanProvider (NotifierProvider)
    ├── reads: userProvider, mealsForDateProvider
    ├── calls: AIService.generateMealPlan()
    └── writes: MealPlanDoc to Isar

foodScanProvider (StateNotifierProvider)
    ├── state: FoodScanState (idle/scanning/result/error)
    ├── calls: AIService.analyzeFoodImage()
    └── on log: calls mealsForDateProvider.notifier.add()

nutritionAnalysisProvider (FutureProvider.family<DateTime>)
    ├── reads: mealsForDateProvider
    ├── reads: nutritionTargetsProvider
    ├── calls: AIService.analyzeNutrition() (cached 1h)
    └── result: NutritionInsight domain model

weeklyNutritionInsightProvider (existing — extend)
    ├── reads: last 7 NutritionLogDocs
    ├── calls: AIService.weeklyInsight() (cached weekly)
    └── result: WeeklyInsight domain model
```

### 7.2 Key State Models

```dart
// Food scan state machine
enum ScanPhase { idle, capturing, analyzing, result, error }

class FoodScanState {
  final ScanPhase phase;
  final FoodScanResult? result;
  final String? errorMessage;
  final double portionMultiplier;   // Live slider value
}

// Nutrition analysis result
class NutritionInsight {
  final int score;                  // 0–100
  final String grade;               // A/B/C/D/F
  final String summary;
  final List<NutritionAlert> alerts;
  final List<String> suggestions;
  final String tomorrowTip;
}

// Meal plan state
class MealPlanState {
  final bool generating;
  final MealPlan? plan;
  final String? error;
  final int selectedDay;            // Current day being viewed
}
```

---

## 8. API Design

### 8.1 AIService Extensions

```dart
// New methods to add to the existing AIService

// Scan food image
Future<FoodScanResult> analyzeFoodImage(Uint8List imageBytes, UserDoc user);

// Generate full meal plan
Future<MealPlan> generateMealPlan({
  required UserDoc user,
  required NutritionTargets targets,
  required int durationDays,
  required List<MealDoc> recentMeals,
});

// Analyze today's nutrition
Future<NutritionInsight> analyzeNutrition({
  required NutritionLogDoc todayLog,
  required NutritionTargets targets,
  required List<MealDoc> todayMeals,
});

// Weekly summary (cached 7 days)
Future<WeeklyInsight> generateWeeklyInsight({
  required List<NutritionLogDoc> weekLogs,
  required UserDoc user,
});

// AI food search (natural language)
Future<List<FoodSearchResult>> searchFoodByName(String query);
```

### 8.2 OpenFoodFactsService

```dart
class OpenFoodFactsService {
  static const _base = 'https://world.openfoodfacts.org/api/v0/product';

  // Barcode lookup
  Future<FoodScanResult?> lookupBarcode(String barcode) async {
    final res = await http.get(Uri.parse('$_base/$barcode.json'));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    if (data['status'] != 1) return null;
    return FoodScanResult.fromOpenFoodFacts(data['product']);
  }

  // Text search
  Future<List<FoodSearchResult>> search(String query, {int page = 1}) async {
    final url = 'https://world.openfoodfacts.org/cgi/search.pl'
        '?search_terms=$query&search_simple=1&action=process&json=1&page=$page&page_size=20';
    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);
    return (data['products'] as List).map(FoodSearchResult.fromJson).toList();
  }
}
```

### 8.3 USDA FoodData Central (Optional — detailed micronutrients)

```
GET https://api.nal.usda.gov/fdc/v1/foods/search
  ?query={foodName}
  &dataType=SR Legacy,Foundation
  &pageSize=10
  &api_key=DEMO_KEY   (free tier: 30 req/min)

Returns detailed micronutrient data (vitamins A/C/D/K, all B vitamins, minerals)
Use as enrichment layer when AI micronutrient data is low-confidence.
```

---

## 9. UI/UX Specification

### 9.1 Navigation Structure

```
/nutrition                    NutritionScreen (tab root)
├── /nutrition/planner        MealPlannerScreen
│   └── /nutrition/planner/day/{n}  DayPlanScreen
├── /nutrition/log/{date}     NutritionLogScreen (full day view)
├── /nutrition/scan-result    ScanResultScreen (from scanner)
├── /nutrition/food-search    FoodSearchScreen
└── /nutrition/weekly-report  WeeklyReportScreen
```

### 9.2 Nutrition Tab — Main Screen

**Header (Sticky AppBar)**
- Title: "Nutrition" · Font: Inter 22px Bold
- Left: Back/Home icon (circle ghost button)
- Right: [Scan pill button] [+ icon button]

**Section 1: Date Navigator**
- Left arrow · "Today" pill · Right arrow
- Tapping "Today" pill → opens date picker modal

**Section 2: Daily Summary Card**
- Full-width card · BorderRadius 28 · Gradient background (dark/light adaptive)
- Left: Circular ring (90px) — calorie % of goal, animated on load
- Right: Large calorie number (36px Bold, Mint color) + "of {goal} kcal goal" + remaining pill

**Section 3: Macro Progress Bars**
- 4 animated bars: Calories · Protein · Carbs · Fat
- Each row: label (60px) + progress bar (animated 900ms ease-out) + "current/goal unit"
- Over-goal bars turn amber (#F59E0B)

**Section 4: Macro Chips (3 columns)**
- Protein chip (red accent) · Carbs chip (amber) · Fat chip (indigo)
- Each: large value + unit label

**Section 5: Meal Sections (Breakfast / Lunch / Dinner / Snack)**
- Each section: card with icon + type name + kcal + protein subtitle
- Meals: swipe-to-delete rows (trash icon reveals on swipe)
- Header has [+] add button per section
- Empty state: "No meals logged yet" muted text

**Section 6: Quick Add Strip**
- Horizontal scroll, 120×100px cards
- 8 preset foods, animated stagger on scroll-into-view

**Section 7: AI Insight Card**
- Mint gradient border
- Today's nutrition score (A–F grade pill)
- 2–3 bullet alerts/suggestions
- Refresh button

**Section 8: Weekly Insights Card**
- Same style, shows weekly grade + headline + stat pills

---

### 9.3 Meal Planner Screen

**Header**
- "Meal Planner" title
- Right: [Generate Plan] CTA button (Mint background)

**Empty State**
- Centered illustration placeholder
- "Generate your personalized meal plan" text
- Large [Generate with AI] button

**Plan View (after generation)**
- Scrollable day tabs (Day 1 / Day 2 ... Day 7) — horizontal pill selector
- Selected day card:
  - Daily total: "{N} kcal · {P}g protein" subtitle
  - Each meal block (Breakfast / Lunch / Dinner / Snack):
    - Meal name + description (2 lines)
    - Macro chips row
    - Prep time pill
    - [Log This Meal] ghost button

**Plan Actions (bottom fixed bar)**
- [Adopt Full Plan] primary button
- [Adopt Today Only] ghost button

---

### 9.4 Food Scan Result Sheet

**Trigger:** After image analysis completes

**Layout (60% height bottom sheet, draggable)**

Top section:
- Scanned image thumbnail (80px circle)
- Dish name (18px Bold)
- Confidence badge: High / Medium / Low (colored pill)
- Health score: score/100 with star color (green/amber/red)

Macro grid (2×2):
- Calories (large, Mint) · Protein (red) · Carbs (amber) · Fat (indigo)

Portion adjuster:
- Label: "Adjust Portion"
- Segmented control: 0.5× · 1× · 1.5× · 2×
- All macros update live on selection

Meal type chips: Breakfast · Lunch · Dinner · Snack

Micronutrients expandable section:
- Fiber · Sodium · Sugar · Vitamins (collapsible, chevron toggle)

AI health note: italic 1-sentence comment from AI

Ingredients list (collapsible):
- Horizontal wrap of ingredient chips

Bottom actions:
- [Log Meal] full-width Mint button
- [Retake / Try Again] ghost button

---

### 9.5 Food Search Screen

**Search Bar** (full-width, autofocus on open)
- Placeholder: "Search food, dish, or brand..."
- Right: [Barcode] icon button → opens barcode scanner

**Recent Searches** (when empty)
- Horizontal strip of recent search chips

**Results List**
- Each row: food name + brand + macros per serving + [+] log button
- Serving size shown: "per 100g" or "per serving (240ml)"
- Tap row → expands to show full macros + log options

**Loading state:** Shimmer rows (3 placeholder cards)

---

### 9.6 Weekly Report Screen

**Header:** "Week of {date range}"

**Section 1: Week Score Card**
- Large grade letter (A–F) in colored circle
- "Consistency score: {N}%" subtitle
- Headline text from AI

**Section 2: 7-Day Calorie Bar Chart**
- Bars colored: Mint (on-target) · Amber (over) · Red (significantly under)
- Goal line drawn across all days
- Tap bar → shows that day's summary tooltip

**Section 3: Macro Trend Lines**
- 3 lines: Protein / Carbs / Fat (7-day sparkline)
- Goal reference line for each

**Section 4: AI Achievements**
- Green checkmark list: things done well this week

**Section 5: AI Improvements**
- Amber warning list: areas to improve

**Section 6: Next Week Focus**
- Single card with AI's one key recommendation for next week

---

### 9.7 Micro-Interaction Specs

| Interaction | Animation |
|---|---|
| Meal logged | Card slides in from right, kcal counter ticks up (animated number) |
| Macro bar | Grows from 0 to value in 900ms ease-out-cubic |
| Calorie ring | Draws arc from 12 o'clock, 1200ms ease-out |
| Scan analyzing | Horizontal sweep line (opacity pulse, 600ms cycle) |
| Plan generated | Cards stagger in with 40ms delay between each meal block |
| Quick add tap | Scale to 0.94 on press, spring back, success shimmer |
| Over-goal | Bar transitions color amber → progress pulses once |
| Delete meal | Slide to reveal red background, entry fades and collapses |

---

## 10. Offline Strategy

### 10.1 Fully Offline Capabilities

All core operations work 100% without internet:

- Log meals manually (MealDoc → Isar, instant)
- View food history (all dates, full history)
- See macro progress vs stored goals
- Access previously generated meal plans (MealPlanDoc → Isar)
- Browse quick-add food presets (hardcoded + user's frequent foods)
- View last AI insight (cached in NutritionLogDoc.aiInsightJson)
- View weekly report (if previously generated)

### 10.2 Requires Network

- **Food scan** (requires AI Vision) → show "Offline: Manual entry available" banner
- **Meal plan generation** → show "Connect to generate plan" with cached plan if available
- **Fresh AI nutrition insight** → show cached insight with timestamp "Last updated {time}"
- **Barcode lookup** (Open Food Facts) → show "Barcode unavailable offline" + offer manual entry
- **Food search** → show offline message, suggest quick-add or recent foods

### 10.3 Cache Strategy

| Data | Cache Location | TTL |
|---|---|---|
| Daily nutrition insight | NutritionLogDoc.aiInsightJson | 1 hour |
| Weekly insight | WeeklyInsightDoc | 7 days |
| Meal plan | MealPlanDoc (Isar) | No expiry (until regenerated) |
| Barcode lookup results | BarcodeCache (Isar) | 30 days |
| Food search results | FoodSearchCache (Isar) | 24 hours |
| User nutrition targets | Computed + stored in UserDoc | Until profile changes |

### 10.4 Sync on Reconnect

```dart
// ConnectivityService listens for network restoration
// On reconnect:
1. Flush any pending DailyLog aggregation
2. If last AI insight >1h old → regenerate in background
3. If weekly insight due → generate silently
4. Do NOT auto-regenerate meal plans (user-triggered only)
```

---

## 11. Implementation Roadmap

### Phase 1 — Foundation (Highest Priority)

| Task | File(s) | Complexity |
|---|---|---|
| Extend MealDoc with micronutrients | `meal_doc.dart` + regenerate `.g.dart` | Small |
| Add UserDoc fields (BMR inputs, goals) | `user_doc.dart` + profile screen | Small |
| Build NutritionTargetsProvider (BMR/TDEE) | `nutrition_targets_provider.dart` | Small |
| Extend AIService: analyzeFoodImage | `ai_service.dart` | Small |
| Scan result sheet with portion adjuster | `scanner_screen.dart` | Medium |
| Flash toggle fix | `scanner_screen.dart` | Tiny |
| Gallery image picker | `scanner_screen.dart` | Small |

### Phase 2 — Core Features

| Task | File(s) | Complexity |
|---|---|---|
| Daily nutrition analysis (AI) | `nutrition_analysis_provider.dart` | Medium |
| AI insight card in Nutrition screen | `nutrition_screen.dart` | Small |
| Meal planner screen (empty + generate) | `meal_planner_screen.dart` | Large |
| MealPlanNotifier (AI call + Isar) | `meal_plan_provider.dart` | Medium |
| Barcode scanner integration | `barcode_service.dart` | Medium |
| Food search screen | `food_search_screen.dart` | Medium |

### Phase 3 — Intelligence Layer

| Task | File(s) | Complexity |
|---|---|---|
| Weekly report screen | `weekly_report_screen.dart` | Medium |
| NutritionLogDoc aggregation | `nutrition_log_service.dart` | Medium |
| UserEatingProfile pattern analyzer | `eating_pattern_analyzer.dart` | Medium |
| Dynamic plan adaptation rules | `plan_adaptation_service.dart` | Large |
| Micronutrient tracking + alerts | `micronutrient_provider.dart` | Medium |
| USDA API integration (enrichment) | `usda_service.dart` | Medium |

### Phase 4 — Advanced (Post-Beta)

| Task | Notes |
|---|---|
| Recipe URL analysis | Paste recipe link → AI extracts per-serving macros |
| Restaurant menu scan | Photo of menu → AI suggests best options for goals |
| Supplement tracker | Log vitamins, protein powder, creatine separately |
| Hydration goals from weight | `user.weightKg * 35ml` dynamic water target |
| Nutrition streaks | 5-day macro goal achievement + celebration animation |
| Export to PDF/CSV | Weekly report export for sharing with dietitian |
| Apple Health / Google Fit sync | Bi-directional calorie sync |

---

## Appendix: File Structure

```
lib/src/features/nutrition/
├── domain/
│   ├── meal_plan_model.dart          (MealPlan, MealPlanDay, PlannedMeal)
│   ├── food_scan_result.dart         (FoodScanResult, FoodItem)
│   ├── nutrition_insight.dart        (NutritionInsight, NutritionAlert)
│   ├── nutrition_targets.dart        (NutritionTargets — BMR/TDEE output)
│   └── weekly_insight.dart           (WeeklyInsight)
├── application/
│   ├── meal_provider.dart            (existing — extend)
│   ├── meal_plan_provider.dart       (existing — extend)
│   ├── meal_plan_parser.dart         (existing)
│   ├── nutrition_targets_provider.dart  (new)
│   ├── nutrition_analysis_provider.dart (new)
│   ├── food_scan_provider.dart          (new)
│   ├── food_search_provider.dart        (new)
│   └── weekly_nutrition_insight_provider.dart (existing — extend)
├── data/
│   ├── open_food_facts_service.dart  (new)
│   ├── usda_service.dart             (new, optional)
│   └── barcode_cache_service.dart    (new)
└── presentation/
    ├── nutrition_screen.dart         (existing — extend)
    ├── meal_planner_screen.dart      (new)
    ├── food_search_screen.dart       (new)
    ├── weekly_report_screen.dart     (new)
    └── widgets/
        ├── meal_plan_card.dart       (existing)
        ├── scan_result_sheet.dart    (new — replace inline in scanner)
        ├── nutrition_insight_card.dart (new)
        ├── macro_ring_chart.dart     (extract from nutrition_screen)
        ├── calorie_bar_chart.dart    (new — weekly view)
        └── portion_adjuster.dart    (new)
```

---

*Document version: 1.0 · Generated: 2026-03-03 · HealthAI Diet Planner Architecture*
