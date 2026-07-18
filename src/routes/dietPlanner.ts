// ============================================================
//  src/routes/dietPlanner.ts
//  POST /api/diet-planner/generate
//  Target-driven plan generation — user specifies macro targets,
//  Ollama fills in meals to hit those exact numbers.
// ============================================================

import { Router, Request, Response } from "express";
import { z } from "zod";
import { generateDietPlan } from "../lib/ollamaClient";
import { ErrorCode } from "../types/index";
import { DietPlan } from "../types/index";

const router = Router();

// ── Validation schema ─────────────────────────────────────────────
const DietPlannerSchema = z.object({
  userId:          z.string().optional(),
  name:            z.string().min(1),
  type:            z.enum(["KETO", "CARNIVORE", "HIGH_PROTEIN_CUT", "BULK", "CUSTOM"]),
  targetCalories:  z.number().int().positive(),
  targetProtein:   z.number().int().nonnegative(),
  targetCarbs:     z.number().int().nonnegative(),
  targetFats:      z.number().int().nonnegative(),
});

// ── POST /api/diet-planner/generate ──────────────────────────────
router.post("/generate", async (req: Request, res: Response) => {
  const parsed = DietPlannerSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      success: false,
      error: parsed.error.errors[0].message,
      code:  ErrorCode.VALIDATION_ERROR,
      timestamp: new Date().toISOString(),
    });
  }

  const { name, type, targetCalories, targetProtein, targetCarbs, targetFats } =
    parsed.data;

  // Build a precise prompt from the specified macro targets
  const prompt = `
Generate a complete daily diet plan with the following EXACT macro targets:
- Plan name: "${name}"
- Plan type: ${type}
- Daily target: ${targetCalories} kcal
- Protein: ${targetProtein}g
- Carbohydrates: ${targetCarbs}g
- Fats: ${targetFats}g

Distribute macros across 4-6 structured meals (breakfast, pre-workout, lunch, post-workout, dinner, optional snack).
Each meal should align with training performance timing. Output strict JSON per schema.
  `.trim();

  const userProfile = {
    heightCm: 180,         // Generic profile for macro-targeted generation
    weightKg: 80,
    focus: `${type} — ${targetProtein}g protein / ${targetCarbs}g carbs / ${targetFats}g fats`,
  };

  try {
    const plan: DietPlan = await generateDietPlan(prompt, userProfile);

    // Override root targets with user-specified values (engine fills meals)
    plan.name            = name;
    plan.type            = type as DietPlan["type"];
    plan.targetCalories  = targetCalories;
    plan.targetProtein   = targetProtein;
    plan.targetCarbs     = targetCarbs;
    plan.targetFats      = targetFats;

    return res.status(200).json({ success: true, plan });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Unknown error";
    return res.status(502).json({
      success: false,
      error:   message,
      code:    ErrorCode.OLLAMA_ERROR,
      timestamp: new Date().toISOString(),
    });
  }
});

export default router;
