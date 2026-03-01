# AI Coach Chat — Detailed Plan
> Feature: `/chat` | `ChatScreen`, `ChatController`, `GeminiService`  
> Models: `ChatSessionDoc`, `ChatMessageDoc`  
> Services: HuggingFace LLM (Llama 3.3 70B), GemmaService (on-device)

---

## Vision

> Not just a chatbot — a proactive, context-aware health coach that knows your workout history, what you ate, how you slept, and what your goals are. It proactively surfaces insights, remembers everything you've told it, and generates structured plans (workouts, meals, recovery) that integrate directly into the app.

---

## Current State

### What works extremely well
- Full chat UI with session management (create, rename, pin, delete, search)
- Cloud mode: Llama 3.3 70B via HuggingFace with 3-model fallback chain
- Offline mode: on-device Gemma via `flutter_gemma`
- Workout plan parsing: AI JSON → `WorkoutPlanCard` bubble → preview/player
- Chat persisted to Isar with full message history
- Rate-limit handling with countdown
- Markdown rendering
- Scroll to bottom button + opens at bottom on session switch
- Health context injection (daily log sent on first message)

### What's dummy / incomplete
- **Paperclip (attach)** — no action
- **Microphone (voice input)** — no action
- **No proactive AI** — AI only responds when user messages, never initiates
- **No cross-feature context** — AI doesn't know about workout history, past meals, saved plans
- **No structured "Meal Plan" response** — only workout plans are parsed/displayed as cards
- **No persistent user profile in AI context** — only TODAY's log is sent, not goals/history

---

## Phase 1 — Complete the Dummy Buttons

### 1.1 Voice input (microphone)
Use `speech_to_text` package (add to pubspec).
```dart
// On mic button tap:
if (!_listening) {
  _speech.listen(onResult: (result) {
    _controller.text = result.recognizedWords;
  });
  setState(() => _listening = true);
} else {
  _speech.stop();
  setState(() => _listening = false);
}
```
Mic icon pulses red while listening. Stop on second tap or silence timeout.

### 1.2 Image attachment
Use `image_picker` (already planned for nutrition).
On paperclip tap → show bottom sheet: "From Gallery" / "Take Photo".  
Send image to HF Vision model with the user's text as context prompt.  
Show image thumbnail in the user's chat bubble.

---

## Phase 2 — Richer AI Context

### 2.1 Persistent user profile in every AI message
Currently only today's log is sent on first message. Change this to a comprehensive context block sent on the FIRST message of EVERY session:

```dart
final context = '''
[User Profile]:
- Name: ${user.displayName ?? 'User'}, Age: ${user.age ?? 'unknown'}
- Height: ${user.heightCm}cm, Weight: ${user.weightKg}kg
- Goal: ${user.primaryGoal ?? 'general fitness'}
- Dietary: ${user.preferences.dietary.join(', ')}
- Experience: ${user.fitnessLevel ?? 'intermediate'}

[Today ($todayDate)]:
- Calories burned: ${log.caloriesBurned}/${log.caloriesBurnedGoal}
- Calories consumed: ${log.caloriesConsumed} kcal
- Protein: ${log.proteinGrams}g | Carbs: ${log.carbsGrams}g | Fat: ${log.fatGrams}g
- Water: ${log.waterMl}ml | Steps: ${log.stepCount} | Sleep: ${(log.sleepMinutes/60).toStringAsFixed(1)}h

[Recent Workouts (last 3)]:
${recentWorkouts.map((w) => '- ${w.title} on ${w.date}: ${w.durationSeconds ~/ 60}min').join('\n')}

[Active Habits]: ${completedHabits}/${totalHabits} completed today
''';
```

### 2.2 Workout history context
Load last 3 `WorkoutDoc`s from Isar and include them in the context block above.  
AI can now say "I see you did push day yesterday — today might be good for pull or legs."

### 2.3 Saved plans context
Include names of saved `WorkoutPlanDoc`s:
```
[Saved Workout Plans]: "PPL Hypertrophy Week", "Home HIIT Plan"
```
AI can reference: "You already have a PPL plan saved — want me to adjust it or create something different?"

---

## Phase 3 — Meal Plan Cards

### 3.1 Meal plan JSON format
Update the AI system prompt to also emit a `meal_plan` JSON fence when generating a meal plan:

```json
meal_plan
{
  "title": "High Protein Day",
  "targetCalories": 2200,
  "targetProtein": 160,
  "meals": [
    {
      "type": "breakfast",
      "name": "Oats + Egg Whites",
      "calories": 380,
      "protein": 28,
      "carbs": 52,
      "fat": 6,
      "recipe": "Cook 80g oats, add 4 egg whites, top with banana"
    }
  ]
}
```

### 3.2 `MealPlanCard` widget
Similar to `WorkoutPlanCard` — shows:
- Total kcal / protein target
- Each meal as a collapsible row (breakfast / lunch / dinner / snacks)
- Each meal: name, macros, recipe hint
- "Log all meals" button → saves each as a `MealDoc` with `planned = true`
- "Log meal" per individual meal

### 3.3 Meal plan parser
Similar to `WorkoutPlanParser.parse()` — extract `meal_plan` JSON fence from AI response, parse into `MealPlanData` object, emit a `isWidget = true` `ChatMessageDoc`.

---

## Phase 4 — Proactive AI Coach

### 4.1 Daily AI push
Every morning (local notification at configurable time):
- AI generates a 1-sentence motivation based on yesterday's data
- Notification: "You hit 89% of your macros yesterday — great effort! Today's first priority: morning workout 💪"
- Tapping notification → opens chat with that context pre-loaded

### 4.2 Chat suggestions based on data
On the empty state (welcome screen), suggestions dynamically update based on context:
- If yesterday was a workout day: "How sore should I expect to be?" / "Best recovery foods today?"
- If calorie goal was under by 30%: "Help me reach my calorie goal today"
- If 3-day habit streak at risk: "Help me stay consistent today"
- If no workout in 3 days: "Time for a workout? Give me a plan"

### 4.3 Weekly AI report
Every Sunday: AI generates a full weekly health report card:
```
Week 4 Review:
✅ Workouts: 3/4 planned
⚠️ Nutrition: Avg 1650 kcal (17% under goal)
✅ Habits: 68% completion
💤 Sleep: 7.1h avg (great)
---
Next week focus: Increase calorie intake by adding a post-workout shake.
```
Displayed as a special "Report Card" chat bubble with a week summary layout.

### 4.4 AI memory summary
After 5+ messages in a session, AI generates a session summary stored as `ChatSessionDoc.aiSummary`.  
On next session start: this summary is injected as context.  
Gives the AI "memory" across sessions: "Last time we spoke, you were working on your PPL program..."

---

## Phase 5 — Advanced (Post-Beta)

- **Gemini 2.0 Flash** upgrade: Google Gemini API directly (using the `GEMINI_API_KEY` already in `.env` but currently unused). Better quality than HF Llama.
- **Streaming responses**: Stream tokens instead of waiting for full response — feels much faster
- **Chat export**: Export any session as PDF / share as link
- **Group coach**: shared coach context for couples/accountability partners
- **Specialist modes**: toggle between "Nutrition Coach", "Workout Coach", "Mental Wellness" — each with specialized system prompt
- **Voice responses**: TTS for AI responses (especially useful during workouts)

---

## Implementation Priority

| Task | Priority | Effort |
|---|---|---|
| Voice input (STT) | High | Medium |
| Image attachment in chat | Medium | Medium |
| Expanded user context block | High | Medium |
| Workout history in context | High | Small |
| Meal plan JSON + parser | High | Large |
| MealPlanCard widget | High | Medium |
| Dynamic welcome suggestions | Medium | Small |
| Daily proactive notification | Medium | Medium |
| Weekly AI report card | Medium | Large |
| Switch to Gemini API (flash) | Low | Medium |
| Streaming responses | Low | Medium |

---

## Notes on Current AI Provider

The app is named "Gemini" throughout the UI but actually uses HuggingFace:
- `GeminiService` → HuggingFace Router → Llama 3.3 70B
- `GEMINI_API_KEY` in `.env` is present but **not used anywhere** 
- The real plan should be to switch to Google Gemini 2.0 Flash (which IS free-tier) for higher quality and reliability
- Current HF setup works but Llama 3.3 70B can hit rate limits on free tier

**Recommended migration:**
1. Add `google_generative_ai` (already in pubspec as `^0.4.0`)
2. Create `GeminiApiService` using the SDK
3. Use as primary, fall back to HF on error
