// ============================================================
//  src/app.ts
//  Express application factory
//  Volcanic-Nutrition-Engine — Aura Diet Planner
// ============================================================

import express, { Application, Request, Response, NextFunction } from "express";
import cors from "cors";
import planRouter from "./routes/plan";
import dietPlannerRouter from "./routes/dietPlanner";
import { ErrorResponse } from "./types/index";


export function createApp(): Application {
  const app = express();

  // ── CORS ────────────────────────────────────────────────────────────
  app.use(
    cors({
      origin: process.env.ALLOWED_ORIGIN ?? "*",
      methods: ["GET", "POST", "DELETE"],
      allowedHeaders: ["Content-Type"],
    })
  );

  // ── Body parsing ────────────────────────────────────────────────────
  app.use(express.json({ limit: "2mb" }));

  // ── API routes ──────────────────────────────────────────────────────
  app.use("/api/plans", planRouter);
  app.use("/api/diet-planner", dietPlannerRouter);

  // ── Health check ────────────────────────────────────────────────────
  app.get("/api/health", (_req: Request, res: Response) => {
    res.json({
      status: "online",
      engine: "Volcanic-Nutrition-Engine",
      version: "1.0.0",
      timestamp: new Date().toISOString(),
    });
  });

  // ── Global error handler ────────────────────────────────────────────
  app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
    console.error("[GlobalError]", err.message);
    const body: ErrorResponse = {
      success: false,
      error: err.message ?? "Internal server error",
      timestamp: new Date().toISOString(),
    };
    res.status(500).json(body);
  });

  return app;
}
