// ============================================================
//  src/lib/ollamaClient.ts
//  Ollama inference client — Volcanic-Nutrition-Engine
//  Sends the system prompt + user input to a local Ollama model
//  and parses the raw JSON diet plan response.
// ============================================================

import { Ollama } from "ollama";
import { DietPlan, UserProfile } from "../types/index";

const OLLAMA_BASE_URL = process.env.OLLAMA_BASE_URL ?? "http://localhost:11434";
const OLLAMA_MODEL    = process.env.OLLAMA_MODEL    ?? "llava";

// ── System prompt injected into every inference call ─────────────────────
function buildSystemPrompt(profile: UserProfile): string {
  return `
You are the Volcanic-Nutrition-Engine — an elite AI nutrition core inside the Aura Diet Planner.

USER PHYSICAL SPECIFICATIONS:
- Height: ${profile.heightCm} cm
- Weight: ${profile.weightKg} kg
- Focus: ${profile.focus}

OPERATIONAL MANDATE:
Analyze the user's input (meal description, diet style, or food image text) and generate a
high-performance, tactically optimized daily diet plan.

OUTPUT RULES — CRITICAL:
1. Output ONLY a raw, valid JSON object. No prose, no markdown, no code fences.
   The response must start with '{' and end with '}'.
2. Every meal must have a "tacticalIntent" string explaining the physiological/performance
   reason for its macro distribution and ingredient timing.
3. MATHEMATICAL EXACTNESS: the sum of each ingredient's macros MUST equal the meal totals.
   The sum of all meal totals MUST equal the root targetCalories/Protein/Carbs/Fats.
   Zero rounding errors tolerated.

REQUIRED JSON SCHEMA:
{
  "name": "String",
  "type": "KETO | CARNIVORE | HIGH_PROTEIN_CUT | BULK | CUSTOM",
  "targetCalories": Integer,
  "targetProtein": Integer,
  "targetCarbs": Integer,
  "targetFats": Integer,
  "meals": [
    {
      "order": Integer,
      "name": "String",
      "scheduledTime": "String",
      "tacticalIntent": "String",
      "totalCalories": Integer,
      "totalProtein": Integer,
      "totalCarbs": Integer,
      "totalFats": Integer,
      "ingredients": [
        {
          "name": "String",
          "weightGrams": Integer,
          "protein": Integer,
          "carbs": Integer,
          "fats": Integer,
          "calories": Integer
        }
      ]
    }
  ]
}
`.trim();
}

// ── Main inference function ───────────────────────────────────────────────
export async function generateDietPlan(
  userInput: string,
  profile: UserProfile
): Promise<DietPlan> {
  const ollama = new Ollama({ host: OLLAMA_BASE_URL });

  const response = await ollama.chat({
    model: OLLAMA_MODEL,
    messages: [
      {
        role: "system",
        content: buildSystemPrompt(profile),
      },
      {
        role: "user",
        content: userInput,
      },
    ],
    // Force JSON output where the model supports it
    format: "json",
    options: {
      temperature: 0.3,   // Low temp for mathematical precision
      num_predict: 4096,  // Allow full plan output
    },
  });

  const raw = response.message.content.trim();

  // ── Parse & validate ──────────────────────────────────────────────────
  let plan: DietPlan;
  try {
    plan = JSON.parse(raw) as DietPlan;
  } catch {
    throw new Error(
      `Ollama returned non-JSON content. Raw output: ${raw.slice(0, 300)}...`
    );
  }

  // ── Self-Healing Math Correction ──────────────────────────────────────
  correctMathInconsistencies(plan);

  return plan;
}

// ── Self-healing math corrector ──────────────────────────────────────────
function correctMathInconsistencies(plan: DietPlan): void {
  let planCal = 0;
  let planPro = 0;
  let planCarb = 0;
  let planFat = 0;

  for (const meal of plan.meals) {
    let mealCal = 0;
    let mealPro = 0;
    let mealCarb = 0;
    let mealFat = 0;

    for (const ing of meal.ingredients) {
      // Ensure values are numbers
      ing.calories = Number(ing.calories) || 0;
      ing.protein = Number(ing.protein) || 0;
      ing.carbs = Number(ing.carbs) || 0;
      ing.fats = Number(ing.fats) || 0;
      ing.weightGrams = Number(ing.weightGrams) || 0;

      mealCal += ing.calories;
      mealPro += ing.protein;
      mealCarb += ing.carbs;
      mealFat += ing.fats;
    }

    // Force perfect mathematical match on meal totals
    meal.totalCalories = mealCal;
    meal.totalProtein = mealPro;
    meal.totalCarbs = mealCarb;
    meal.totalFats = mealFat;

    planCal += mealCal;
    planPro += mealPro;
    planCarb += mealCarb;
    planFat += mealFat;
  }

  // Force perfect mathematical match on daily target totals
  plan.targetCalories = planCal;
  plan.targetProtein = planPro;
  plan.targetCarbs = planCarb;
  plan.targetFats = planFat;
}


