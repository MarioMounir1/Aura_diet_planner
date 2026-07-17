# 🔥 Aura Diet Planner — Volcanic-Nutrition-Engine

> Elite AI-powered tactical nutrition platform. Generate mathematically precise, physiologically optimized diet plans via a local Ollama model — no cloud, no API keys, full privacy.

---

## Tech Stack

| Layer      | Technology                        |
|------------|-----------------------------------|
| Backend    | Node.js · Express · TypeScript    |
| AI Engine  | Ollama (local LLM)                |
| Database   | PostgreSQL · Prisma ORM           |
| Mobile App | Flutter · Dart (Android & iOS)    |

---

## Prerequisites

- [Node.js](https://nodejs.org/) v18+
- [PostgreSQL](https://www.postgresql.org/) v14+
- [Ollama](https://ollama.com/) installed and running locally
- [Flutter](https://flutter.dev/) v3.10+ (with Dart 3+)

---

## Quick Start

### 1. Install backend dependencies

```bash
cd d:\Aura_diet_planner
npm install
```

### 2. Pull your Ollama model

```bash
ollama pull llava
```

> You can use any model that supports JSON output mode (e.g. `mistral`, `llava`, `gemma2`).

### 3. Configure environment

```bash
copy .env.example .env
```

Edit `.env` with your values:

```env
PORT=3000
DATABASE_URL="postgresql://postgres:PASSWORD@localhost:PORT/aura_diet_planner"
OLLAMA_BASE_URL="http://localhost:11434"
OLLAMA_MODEL="llava"
```

### 4. Set up the database

```bash
# Create the DB first in pgAdmin or psql:
# CREATE DATABASE aura_diet_planner;

npm run prisma:generate
npm run prisma:migrate
```

### 5. Start the backend server

```bash
npm run dev
```

Server runs at → **http://localhost:3000**

---

### 6. Run the Flutter mobile app

```bash
cd mobile
flutter pub get
flutter run
```

> **On physical device?** Open the **Settings tab** in the app and set your machine's LAN IP:
> `http://192.168.x.x:3000`
>
> **Android emulator?** Use `http://10.0.2.2:3000` (default — already set)
>
> **iOS simulator?** Use `http://localhost:3000`

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
│
├── prisma/
│   └── schema.prisma              # PostgreSQL schema
│
├── src/                           # Express backend (TypeScript)
│   ├── types/index.ts             # Shared DTOs and domain models
│   ├── lib/
│   │   ├── ollamaClient.ts        # Ollama inference + math integrity validator
│   │   └── prismaClient.ts        # Singleton Prisma client
│   ├── services/
│   │   └── nutritionEngine.ts     # Core business logic
│   ├── routes/
│   │   └── plan.ts                # Express API router
│   ├── app.ts                     # Express app factory
│   └── server.ts                  # HTTP server entry point
│
├── mobile/                        # Flutter mobile app (Dart)
│   └── lib/
│       ├── main.dart              # App entry point
│       ├── theme/
│       │   └── app_theme.dart     # Dark design system
│       ├── models/
│       │   ├── diet_plan.dart     # DietPlan model
│       │   ├── meal.dart          # Meal model
│       │   └── ingredient.dart    # Ingredient model
│       ├── services/
│       │   └── api_service.dart   # HTTP client to backend
│       ├── widgets/
│       │   ├── macro_chip.dart    # Color-coded macro chips
│       │   ├── meal_card.dart     # Expandable meal card
│       │   └── ingredient_row.dart# Ingredient table row
│       └── screens/
│           ├── home_screen.dart        # Nav shell + engine status
│           ├── generate_screen.dart    # AI plan generator
│           ├── plan_detail_screen.dart # Full plan view
│           ├── saved_plans_screen.dart # Saved plans list
│           └── settings_screen.dart    # API URL config
│
├── .env.example
├── package.json
└── tsconfig.json
```

## Mathematical Integrity & Self-Healing

To maximize stability with smaller local models like `llava` (which may occasionally make arithmetic summation errors), the engine implements a **Self-Healing Math Correction** routine:

1. **Ingredient Component Level**: The engine treats the individual generated ingredients as the ground truth.
2. **Meal Summary Alignment**: For every meal, the engine automatically recalculates and overrides the meal's macro totals as the exact mathematical sum of its ingredients' macros.
3. **Daily Plan Alignment**: The daily target macros are recalculated as the exact sum of all meal summaries.

This guarantees **zero-tolerance math consistency** (perfectly aligned sums, zero rounding errors) at both the database and UI layers without throwing validation errors to the user.

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
