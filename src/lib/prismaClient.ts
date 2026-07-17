// ============================================================
//  src/lib/prismaClient.ts
//  Singleton Prisma client instance
//  Prevents multiple DB connection pools in dev (hot-reload safe)
// ============================================================

import { PrismaClient } from "@prisma/client";

declare global {
  // Allow a global prisma instance in development to survive hot reloads
  // eslint-disable-next-line no-var
  var __prisma: PrismaClient | undefined;
}

const prisma: PrismaClient =
  global.__prisma ??
  new PrismaClient({
    log:
      process.env.NODE_ENV === "development"
        ? ["query", "info", "warn", "error"]
        : ["error"],
  });

if (process.env.NODE_ENV !== "production") {
  global.__prisma = prisma;
}

export default prisma;
