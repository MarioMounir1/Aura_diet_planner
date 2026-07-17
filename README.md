# 🔥 Aura Diet Planner — Volcanic-Nutrition-Engine

> Elite AI-powered tactical nutrition platform. Generate mathematically precise, physiologically optimized diet plans via a local Ollama model — no cloud, no API keys, full privacy.

---

## Tech Stack

| Layer      | Technology                        |
|------------|-----------------------------------|
| Backend    | Node.js · Express · TypeScript    |
| AI Engine  | Ollama (local LLM)                |
| Database   | PostgreSQL · Prisma ORM           |
| Frontend   | Vanilla HTML · CSS · JavaScript   |

---

## Prerequisites

- [Node.js](https://nodejs.org/) v18+
- [PostgreSQL](https://www.postgresql.org/) v14+
- [Ollama](https://ollama.com/) installed and running locally

---

## Quick Start

### 1. Clone & install dependencies

```bash
cd d:\Aura_diet_planner
npm install
```

### 2. Pull your Ollama model

```bash
ollama pull llama3
```

> You can use any model that supports JSON output mode (e.g. `mistral`, `llama3`, `gemma2`).

### 3. Configure environment

```bash
copy .env.example .env
```

Edit `.env` with your values:

```env
PORT=3000
DATABASE_URL="postgresql://USER:PASSWORD@localhost:5432/aura_diet_planner"
OLLAMA_BASE_URL="http://localhost:11434"
OLLAMA_MODEL="llama3"
ALLOWED_ORIGIN="http://localhost:5500"
```

### 4. Set up the database

```bash
# Create the database first in psql:
# CREATE DATABASE aura_diet_planner;

npm run prisma:generate
npm run prisma:migrate
```

### 5. Run the development server

```bash
npm run dev
```

Open your browser at → **http://localhost:3000**

---

## API Reference

| Method   | Endpoint              | Description                          |
|----------|-----------------------|--------------------------------------|
| `POST`   | `/api/plans/generate` | Generate a plan via Ollama           |
| `POST`   | `/api/plans/save`     | Save a generated plan to PostgreSQL  |
| `GET`    | `/api/plans`          | Get all saved plans                  |
| `GET`    | `/api/plans/:id`      | Get a single plan by UUID            |
| `DELETE` | `/api/plans/:id`      | Delete a plan (cascades meals/ingrs) |
| `GET`    | `/api/health`         | Engine health check                  |

### Generate Plan — Request Body

```json
{
  "userProfile": {
    "heightCm": 188,
    "weightKg": 84,
    "focus": "High-performance training, powerbuilding recovery"
  },
  "input": "Generate a full powerbuilding bulk day — 3500 kcal, high carb pre-workout, casein before bed",
  "preferredType": "BULK"
}
```

---

## Project Structure

```
aura-diet-planner/
├── prisma/
│   └── schema.prisma          # PostgreSQL schema (UserProfile → DietPlan → Meal → Ingredient)
├── src/
│   ├── types/
│   │   └── index.ts           # Shared TypeScript DTOs and domain models
│   ├── lib/
│   │   ├── ollamaClient.ts    # Ollama inference + math integrity validator
│   │   └── prismaClient.ts    # Singleton Prisma client
│   ├── services/
│   │   └── nutritionEngine.ts # Core business logic (generate, save, fetch, delete)
│   ├── routes/
│   │   └── plan.ts            # Express API router
│   ├── app.ts                 # Express app factory
│   └── server.ts              # HTTP server entry point
├── frontend/
│   ├── index.html             # UI shell
│   ├── style.css              # Dark glassmorphism design system
│   └── app.js                 # Frontend logic
├── .env.example
├── package.json
└── tsconfig.json
```

---

## Mathematical Integrity

The engine enforces **zero-tolerance macro math** at two levels:

1. **Ingredient → Meal**: Sum of all ingredient macros must match `totalCalories / totalProtein / totalCarbs / totalFats` (±2 tolerance)
2. **Meal → Plan**: Sum of all meal totals must match root `targetCalories / targetProtein / targetCarbs / targetFats` (±5 tolerance)

If Ollama returns a plan that fails either check, the API returns a `MATH_INTEGRITY_FAILED` error and the plan is discarded.

---

## Plan Types

| Type               | Description                                      |
|--------------------|--------------------------------------------------|
| `HIGH_PROTEIN_CUT` | Caloric deficit · High protein · Low carb        |
| `BULK`             | Caloric surplus · High carb · Performance focus  |
| `KETO`             | Very low carb · High fat · Ketogenic             |
| `CARNIVORE`        | Animal products only · Zero carb                 |
| `CUSTOM`           | AI-decided based on your input                   |

---

## License

MIT © Aura Fitness Ecosystem
