// ============================================================
//  src/app.ts
//  Express application factory
//  Volcanic-Nutrition-Engine — Aura Diet Planner
// ============================================================

import express, { Application, Request, Response, NextFunction } from "express";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";
import planRouter from "./routes/plan.js";
import { ErrorResponse } from "./types/index.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname  = path.dirname(__filename);

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

  // ── Static frontend ─────────────────────────────────────────────────
  // Serves the HTML/CSS/JS frontend from the /frontend folder
  app.use(express.static(path.join(__dirname, "..", "frontend")));

  // ── API routes ──────────────────────────────────────────────────────
  app.use("/api/plans", planRouter);

  // ── Health check ────────────────────────────────────────────────────
  app.get("/api/health", (_req: Request, res: Response) => {
    res.json({
      status: "online",
      engine: "Volcanic-Nutrition-Engine",
      version: "1.0.0",
      timestamp: new Date().toISOString(),
    });
  });

  // ── SPA fallback — serve index.html for any unmatched GET ───────────
  app.get("*", (_req: Request, res: Response) => {
    res.sendFile(path.join(__dirname, "..", "frontend", "index.html"));
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
