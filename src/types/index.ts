// ============================================================
//  src/types/index.ts
//  Shared TypeScript types, DTOs, and domain models
//  Volcanic-Nutrition-Engine — Aura Diet Planner
// ============================================================

// ── Enums ─────────────────────────────────────────────────────────────────

export type PlanType =
  | "KETO"
  | "CARNIVORE"
  | "HIGH_PROTEIN_CUT"
  | "BULK"
  | "CUSTOM";

// ── Domain models (mirror Prisma output shapes) ───────────────────────────

export interface Ingredient {
  id?: string;
  name: string;
  weightGrams: number;
  protein: number;
  carbs: number;
  fats: number;
  calories: number;
}

export interface Meal {
  id?: string;
  order: number;
  name: string;
  scheduledTime: string;
  tacticalIntent: string;
  totalCalories: number;
  totalProtein: number;
  totalCarbs: number;
  totalFats: number;
  ingredients: Ingredient[];
}

export interface DietPlan {
  id?: string;
  name: string;
  type: PlanType;
  targetCalories: number;
  targetProtein: number;
  targetCarbs: number;
  targetFats: number;
  meals: Meal[];
}

export interface UserProfile {
  heightCm: number;
  weightKg: number;
  focus: string;
}

// ── Request DTOs ──────────────────────────────────────────────────────────

export interface GeneratePlanRequest {
  userProfile: UserProfile;
  /** Free-text description of the diet style, goals, or a meal to analyse */
  input: string;
  /** Optional preferred plan type; Ollama will decide if omitted */
  preferredType?: PlanType;
}

export interface SavePlanRequest {
  plan: DietPlan;
  userId?: string;
}

// ── Response DTOs ─────────────────────────────────────────────────────────

export interface GeneratePlanResponse {
  success: boolean;
  source: "ollama_generated";
  plan: DietPlan;
  generatedAt: string;
}

export interface SavePlanResponse {
  success: boolean;
  planId: string;
  savedAt: string;
}

export interface GetPlansResponse {
  success: boolean;
  plans: DietPlan[];
  total: number;
}

// ── Error ─────────────────────────────────────────────────────────────────

export interface ErrorResponse {
  success: false;
  error: string;
  code?: ErrorCode;
  timestamp: string;
}

export enum ErrorCode {
  VALIDATION_ERROR = "VALIDATION_ERROR",
  OLLAMA_ERROR = "OLLAMA_ERROR",
  DATABASE_ERROR = "DATABASE_ERROR",
  PLAN_NOT_FOUND = "PLAN_NOT_FOUND",
  MATH_INTEGRITY_FAILED = "MATH_INTEGRITY_FAILED",
}
