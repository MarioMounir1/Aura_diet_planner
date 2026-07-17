// ============================================================
//  src/routes/plan.ts
//  Express router — Diet Plan API endpoints
//  Volcanic-Nutrition-Engine
// ============================================================

import { Router, Request, Response } from "express";
import { z } from "zod";
import {
  generatePlan,
  savePlan,
  getAllPlans,
  getPlanById,
  deletePlan,
} from "../services/nutritionEngine.js";
import { ErrorCode, GeneratePlanRequest } from "../types/index.js";

const router = Router();

// ── Zod validation schemas ────────────────────────────────────────────────

const UserProfileSchema = z.object({
  heightCm: z.number().positive(),
  weightKg: z.number().positive(),
  focus: z.string().min(3),
});

const GenerateSchema = z.object({
  userProfile: UserProfileSchema,
  input: z.string().min(5, "Input must describe a meal or diet style"),
  preferredType: z
    .enum(["KETO", "CARNIVORE", "HIGH_PROTEIN_CUT", "BULK", "CUSTOM"])
    .optional(),
});

const SaveSchema = z.object({
  plan: z.object({}).passthrough(), // Full plan validated by Ollama + integrity check
  userId: z.string().uuid().optional(),
});

// ── POST /api/plans/generate ──────────────────────────────────────────────
// Generate a new diet plan via Ollama (does NOT save to DB)
router.post("/generate", async (req: Request, res: Response) => {
  const parsed = GenerateSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      success: false,
      error: parsed.error.errors[0].message,
      code: ErrorCode.VALIDATION_ERROR,
      timestamp: new Date().toISOString(),
    });
  }

  try {
    const result = await generatePlan(parsed.data as GeneratePlanRequest);
    return res.status(200).json(result);
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Unknown error";
    const isIntegrity = message.startsWith("MATH_INTEGRITY_FAILED");
    return res.status(502).json({
      success: false,
      error: message,
      code: isIntegrity ? ErrorCode.MATH_INTEGRITY_FAILED : ErrorCode.OLLAMA_ERROR,
      timestamp: new Date().toISOString(),
    });
  }
});

// ── POST /api/plans/save ──────────────────────────────────────────────────
// Persist a generated plan to PostgreSQL
router.post("/save", async (req: Request, res: Response) => {
  const parsed = SaveSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      success: false,
      error: parsed.error.errors[0].message,
      code: ErrorCode.VALIDATION_ERROR,
      timestamp: new Date().toISOString(),
    });
  }

  try {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const result = await savePlan(parsed.data.plan as any, parsed.data.userId);
    return res.status(201).json(result);
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Unknown error";
    return res.status(500).json({
      success: false,
      error: message,
      code: ErrorCode.DATABASE_ERROR,
      timestamp: new Date().toISOString(),
    });
  }
});

// ── GET /api/plans ────────────────────────────────────────────────────────
// Retrieve all saved plans
router.get("/", async (_req: Request, res: Response) => {
  try {
    const result = await getAllPlans();
    return res.status(200).json(result);
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Unknown error";
    return res.status(500).json({
      success: false,
      error: message,
      code: ErrorCode.DATABASE_ERROR,
      timestamp: new Date().toISOString(),
    });
  }
});

// ── GET /api/plans/:id ────────────────────────────────────────────────────
// Retrieve a single plan by UUID
router.get("/:id", async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const plan = await getPlanById(id);
    if (!plan) {
      return res.status(404).json({
        success: false,
        error: `Plan ${id} not found`,
        code: ErrorCode.PLAN_NOT_FOUND,
        timestamp: new Date().toISOString(),
      });
    }
    return res.status(200).json({ success: true, plan });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Unknown error";
    return res.status(500).json({
      success: false,
      error: message,
      code: ErrorCode.DATABASE_ERROR,
      timestamp: new Date().toISOString(),
    });
  }
});

// ── DELETE /api/plans/:id ─────────────────────────────────────────────────
// Delete a plan and cascade-remove its meals + ingredients
router.delete("/:id", async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    await deletePlan(id);
    return res.status(200).json({ success: true, deletedId: id });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Unknown error";
    const isNotFound = message.includes("not found");
    return res.status(isNotFound ? 404 : 500).json({
      success: false,
      error: message,
      code: isNotFound ? ErrorCode.PLAN_NOT_FOUND : ErrorCode.DATABASE_ERROR,
      timestamp: new Date().toISOString(),
    });
  }
});

export default router;
