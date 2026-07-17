// ============================================================
//  src/services/nutritionEngine.ts
//  Volcanic-Nutrition-Engine — Core business logic layer
//  Orchestrates Ollama inference + Prisma persistence
// ============================================================

import prisma from "../lib/prismaClient.js";
import { generateDietPlan } from "../lib/ollamaClient.js";
import {
  DietPlan,
  GeneratePlanRequest,
  GeneratePlanResponse,
  SavePlanResponse,
  GetPlansResponse,
  ErrorCode,
} from "../types/index.js";

// ── Generate a plan via Ollama (no DB save) ───────────────────────────────
export async function generatePlan(
  req: GeneratePlanRequest
): Promise<GeneratePlanResponse> {
  const plan = await generateDietPlan(req.input, req.userProfile);

  // Enforce preferred type if provided
  if (req.preferredType) {
    plan.type = req.preferredType;
  }

  return {
    success: true,
    source: "ollama_generated",
    plan,
    generatedAt: new Date().toISOString(),
  };
}

// ── Save a plan to PostgreSQL ─────────────────────────────────────────────
export async function savePlan(
  plan: DietPlan,
  userId?: string
): Promise<SavePlanResponse> {
  const saved = await prisma.dietPlan.create({
    data: {
      ...(userId ? { userId } : {}),
      name: plan.name,
      type: plan.type,
      targetCalories: plan.targetCalories,
      targetProtein: plan.targetProtein,
      targetCarbs: plan.targetCarbs,
      targetFats: plan.targetFats,
      meals: {
        create: plan.meals.map((meal) => ({
          order: meal.order,
          name: meal.name,
          scheduledTime: meal.scheduledTime,
          tacticalIntent: meal.tacticalIntent,
          totalCalories: meal.totalCalories,
          totalProtein: meal.totalProtein,
          totalCarbs: meal.totalCarbs,
          totalFats: meal.totalFats,
          ingredients: {
            create: meal.ingredients.map((ing) => ({
              name: ing.name,
              weightGrams: ing.weightGrams,
              protein: ing.protein,
              carbs: ing.carbs,
              fats: ing.fats,
              calories: ing.calories,
            })),
          },
        })),
      },
    },
  });

  return {
    success: true,
    planId: saved.id,
    savedAt: saved.createdAt.toISOString(),
  };
}

// ── Retrieve all saved plans (with meals + ingredients) ───────────────────
export async function getAllPlans(): Promise<GetPlansResponse> {
  const plans = await prisma.dietPlan.findMany({
    orderBy: { createdAt: "desc" },
    include: {
      meals: {
        orderBy: { order: "asc" },
        include: {
          ingredients: true,
        },
      },
    },
  });

  return {
    success: true,
    plans: plans as unknown as DietPlan[],
    total: plans.length,
  };
}

// ── Retrieve a single plan by ID ──────────────────────────────────────────
export async function getPlanById(planId: string): Promise<DietPlan | null> {
  const plan = await prisma.dietPlan.findUnique({
    where: { id: planId },
    include: {
      meals: {
        orderBy: { order: "asc" },
        include: { ingredients: true },
      },
    },
  });

  return plan as unknown as DietPlan | null;
}

// ── Delete a plan by ID ───────────────────────────────────────────────────
export async function deletePlan(planId: string): Promise<void> {
  const exists = await prisma.dietPlan.findUnique({ where: { id: planId } });
  if (!exists) {
    const err = new Error(`Plan ${planId} not found`) as Error & { code: ErrorCode };
    err.code = ErrorCode.PLAN_NOT_FOUND;
    throw err;
  }
  // Cascade deletes meals + ingredients via Prisma schema
  await prisma.dietPlan.delete({ where: { id: planId } });
}
