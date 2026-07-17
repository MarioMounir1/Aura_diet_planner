// ============================================================
//  src/server.ts
//  HTTP server entry point
//  Boots Express app, connects Prisma, starts listening
// ============================================================

import "dotenv/config";
import { createApp } from "./app.js";
import prisma from "./lib/prismaClient.js";

const PORT = parseInt(process.env.PORT ?? "3000", 10);

async function bootstrap(): Promise<void> {
  // ── Verify DB connection ─────────────────────────────────────────
  try {
    await prisma.$connect();
    console.log("✅ [Prisma] Connected to PostgreSQL");
  } catch (err) {
    console.error("❌ [Prisma] Failed to connect to database:", err);
    process.exit(1);
  }

  // ── Start HTTP server ────────────────────────────────────────────
  const app = createApp();

  app.listen(PORT, () => {
    console.log(`
╔══════════════════════════════════════════════════════╗
║        🔥 VOLCANIC-NUTRITION-ENGINE ONLINE 🔥        ║
║       Aura Diet Planner — API Server v1.0.0          ║
╠══════════════════════════════════════════════════════╣
║  Local:    http://localhost:${PORT}                      ║
║  Health:   http://localhost:${PORT}/api/health           ║
║  Plans:    http://localhost:${PORT}/api/plans            ║
╚══════════════════════════════════════════════════════╝
    `);
  });

  // ── Graceful shutdown ────────────────────────────────────────────
  const shutdown = async (signal: string) => {
    console.log(`\n[${signal}] Shutting down gracefully...`);
    await prisma.$disconnect();
    console.log("✅ [Prisma] Disconnected. Goodbye.");
    process.exit(0);
  };

  process.on("SIGINT",  () => shutdown("SIGINT"));
  process.on("SIGTERM", () => shutdown("SIGTERM"));
}

bootstrap().catch((err) => {
  console.error("Fatal bootstrap error:", err);
  process.exit(1);
});
