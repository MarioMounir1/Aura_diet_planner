// ============================================================
//  src/lib/ollamaClient.ts
//  Ollama inference client — Volcanic-Nutrition-Engine
//  Sends the system prompt + user input to a local Ollama model
//  and parses the raw JSON diet plan response.
// ============================================================

import Ollama from "ollama";
import { DietPlan, UserProfile } from "../types/index.js";

const OLLAMA_BASE_URL = process.env.OLLAMA_BASE_URL ?? "http://localhost:11434";
const OLLAMA_MODEL    = process.env.OLLAMA_MODEL    ?? "llama3";

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
  const ollama = new Ollama.Ollama({ host: OLLAMA_BASE_URL });

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

  // ── Math integrity check ──────────────────────────────────────────────
  validateMathIntegrity(plan);

  return plan;
}

// ── Macro math validator ──────────────────────────────────────────────────
function validateMathIntegrity(plan: DietPlan): void {
  let sumCal = 0, sumPro = 0, sumCarb = 0, sumFat = 0;

  for (const meal of plan.meals) {
    let mCal = 0, mPro = 0, mCarb = 0, mFat = 0;

    for (const ing of meal.ingredients) {
      mCal  += ing.calories;
      mPro  += ing.protein;
      mCarb += ing.carbs;
      mFat  += ing.fats;
    }

    // Tolerance of ±2 per meal (rounding from Ollama output)
    const tolerance = 2;
    if (
      Math.abs(mCal  - meal.totalCalories) > tolerance ||
      Math.abs(mPro  - meal.totalProtein)  > tolerance ||
      Math.abs(mCarb - meal.totalCarbs)    > tolerance ||
      Math.abs(mFat  - meal.totalFats)     > tolerance
    ) {
      throw new Error(
        `MATH_INTEGRITY_FAILED: Meal "${meal.name}" ingredient sums ` +
        `(cal:${mCal} pro:${mPro} carb:${mCarb} fat:${mFat}) ` +
        `do not match declared totals ` +
        `(cal:${meal.totalCalories} pro:${meal.totalProtein} ` +
        `carb:${meal.totalCarbs} fat:${meal.totalFats}).`
      );
    }

    sumCal  += meal.totalCalories;
    sumPro  += meal.totalProtein;
    sumCarb += meal.totalCarbs;
    sumFat  += meal.totalFats;
  }

  const planTol = 5;
  if (
    Math.abs(sumCal  - plan.targetCalories) > planTol ||
    Math.abs(sumPro  - plan.targetProtein)  > planTol ||
    Math.abs(sumCarb - plan.targetCarbs)    > planTol ||
    Math.abs(sumFat  - plan.targetFats)     > planTol
  ) {
    throw new Error(
      `MATH_INTEGRITY_FAILED: Plan meal totals ` +
      `(cal:${sumCal} pro:${sumPro} carb:${sumCarb} fat:${sumFat}) ` +
      `do not match plan targets ` +
      `(cal:${plan.targetCalories} pro:${plan.targetProtein} ` +
      `carb:${plan.targetCarbs} fat:${plan.targetFats}).`
    );
  }
}
