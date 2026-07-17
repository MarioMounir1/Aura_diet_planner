// ============================================================
//  frontend/app.js
//  Volcanic-Nutrition-Engine — UI logic
//  Connects to Express API, renders plans, manages saved plans
// ============================================================

const API = "/api";

// ── DOM references ────────────────────────────────────────────────
const $ = (id) => document.getElementById(id);

const generateForm    = $("generateForm");
const generateBtn     = $("generateBtn");
const heightInput     = $("heightInput");
const weightInput     = $("weightInput");
const focusInput      = $("focusInput");
const planTypeSelect  = $("planTypeSelect");
const userInput       = $("userInput");

const errorBanner     = $("errorBanner");
const errorMessage    = $("errorMessage");

const resultsSection  = $("resultsSection");
const planTypeBadge   = $("planTypeBadge");
const planName        = $("planName");
const macroCalories   = $("macroCalories");
const macroProtein    = $("macroProtein");
const macroCarbs      = $("macroCarbs");
const macroFats       = $("macroFats");
const mealsGrid       = $("mealsGrid");
const savePlanBtn     = $("savePlanBtn");
const exportJsonBtn   = $("exportJsonBtn");

const savedList       = $("savedList");
const savedEmpty      = $("savedEmpty");
const refreshPlansBtn = $("refreshPlansBtn");

const statusDot       = $("statusDot");
const statusText      = $("statusText");

const mealCardTpl     = $("mealCardTemplate");
const savedRowTpl     = $("savedRowTemplate");

// ── State ─────────────────────────────────────────────────────────
let currentPlan = null;

// ── Health check ──────────────────────────────────────────────────
async function checkHealth() {
  try {
    const res = await fetch(`${API}/health`);
    if (res.ok) {
      statusDot.className  = "status-dot status-dot--online";
      statusText.textContent = "Engine Online";
    } else {
      throw new Error("non-200");
    }
  } catch {
    statusDot.className  = "status-dot status-dot--offline";
    statusText.textContent = "Engine Offline";
  }
}

// ── Error display ─────────────────────────────────────────────────
function showError(msg) {
  errorMessage.textContent = msg;
  errorBanner.hidden = false;
  errorBanner.scrollIntoView({ behavior: "smooth", block: "nearest" });
}

function clearError() {
  errorBanner.hidden = true;
  errorMessage.textContent = "";
}

// ── Loading state ─────────────────────────────────────────────────
function setLoading(loading) {
  generateBtn.classList.toggle("btn--loading", loading);
  generateBtn.disabled = loading;
}

// ── Render plan overview ──────────────────────────────────────────
function renderPlanOverview(plan) {
  planTypeBadge.textContent = plan.type;
  planName.textContent      = plan.name;
  macroCalories.textContent = plan.targetCalories.toLocaleString();
  macroProtein.textContent  = plan.targetProtein;
  macroCarbs.textContent    = plan.targetCarbs;
  macroFats.textContent     = plan.targetFats;
}

// ── Render all meals ──────────────────────────────────────────────
function renderMeals(meals) {
  mealsGrid.innerHTML = "";

  meals
    .slice()
    .sort((a, b) => a.order - b.order)
    .forEach((meal) => {
      const node = mealCardTpl.content.cloneNode(true);

      node.querySelector(".meal-order").textContent = `Meal ${meal.order}`;
      node.querySelector(".meal-time").textContent  = meal.scheduledTime;
      node.querySelector(".meal-name").textContent  = meal.name;
      node.querySelector(".meal-intent").textContent = meal.tacticalIntent;

      node.querySelector(".meal-cal").textContent  = meal.totalCalories;
      node.querySelector(".meal-pro").textContent  = meal.totalProtein + "g";
      node.querySelector(".meal-carb").textContent = meal.totalCarbs + "g";
      node.querySelector(".meal-fat").textContent  = meal.totalFats + "g";

      const tbody = node.querySelector(".ingredients-body");
      meal.ingredients.forEach((ing) => {
        const tr = document.createElement("tr");
        tr.innerHTML = `
          <td>${escHtml(ing.name)}</td>
          <td>${ing.weightGrams}</td>
          <td>${ing.calories}</td>
          <td>${ing.protein}g</td>
          <td>${ing.carbs}g</td>
          <td>${ing.fats}g</td>
        `;
        tbody.appendChild(tr);
      });

      mealsGrid.appendChild(node);
    });
}

// ── Render full plan ──────────────────────────────────────────────
function renderPlan(plan) {
  currentPlan = plan;
  clearError();
  renderPlanOverview(plan);
  renderMeals(plan.meals);
  resultsSection.hidden = false;
  resultsSection.scrollIntoView({ behavior: "smooth", block: "start" });
}

// ── Generate plan ─────────────────────────────────────────────────
generateForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  clearError();

  const height = parseFloat(heightInput.value);
  const weight = parseFloat(weightInput.value);
  const focus  = focusInput.value.trim();
  const input  = userInput.value.trim();

  if (!height || !weight || !focus || !input) {
    showError("Please fill in all fields before generating a plan.");
    return;
  }

  setLoading(true);
  resultsSection.hidden = true;

  try {
    const body = {
      userProfile: { heightCm: height, weightKg: weight, focus },
      input,
    };
    if (planTypeSelect.value) {
      body.preferredType = planTypeSelect.value;
    }

    const res = await fetch(`${API}/plans/generate`, {
      method:  "POST",
      headers: { "Content-Type": "application/json" },
      body:    JSON.stringify(body),
    });

    const data = await res.json();

    if (!res.ok || !data.success) {
      throw new Error(data.error ?? `Server error ${res.status}`);
    }

    renderPlan(data.plan);
  } catch (err) {
    showError(err.message ?? "An unexpected error occurred.");
  } finally {
    setLoading(false);
  }
});

// ── Save plan ─────────────────────────────────────────────────────
savePlanBtn.addEventListener("click", async () => {
  if (!currentPlan) return;

  savePlanBtn.disabled = true;
  const originalText = savePlanBtn.innerHTML;
  savePlanBtn.innerHTML = `
    <span style="display:inline-flex;align-items:center;gap:6px">
      <span style="width:14px;height:14px;border:2px solid rgba(255,255,255,.3);border-top-color:#fff;border-radius:50%;animation:spin .7s linear infinite;display:inline-block"></span>
      Saving...
    </span>`;

  try {
    const res = await fetch(`${API}/plans/save`, {
      method:  "POST",
      headers: { "Content-Type": "application/json" },
      body:    JSON.stringify({ plan: currentPlan }),
    });

    const data = await res.json();
    if (!res.ok || !data.success) throw new Error(data.error ?? "Save failed");

    savePlanBtn.innerHTML = `
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
      Saved!`;
    savePlanBtn.style.color = "var(--clr-success)";

    await loadSavedPlans();

    setTimeout(() => {
      savePlanBtn.innerHTML = originalText;
      savePlanBtn.style.color = "";
      savePlanBtn.disabled = false;
    }, 2500);
  } catch (err) {
    showError(`Save failed: ${err.message}`);
    savePlanBtn.innerHTML = originalText;
    savePlanBtn.disabled = false;
  }
});

// ── Export JSON ───────────────────────────────────────────────────
exportJsonBtn.addEventListener("click", () => {
  if (!currentPlan) return;

  const json = JSON.stringify(currentPlan, null, 2);
  const blob = new Blob([json], { type: "application/json" });
  const url  = URL.createObjectURL(blob);

  const a = document.createElement("a");
  a.href     = url;
  a.download = `${currentPlan.name.replace(/\s+/g, "_")}.json`;
  a.click();
  URL.revokeObjectURL(url);
});

// ── Load saved plans ──────────────────────────────────────────────
async function loadSavedPlans() {
  try {
    const res  = await fetch(`${API}/plans`);
    const data = await res.json();

    if (!res.ok || !data.success) throw new Error(data.error ?? "Failed to load plans");

    renderSavedPlans(data.plans);
  } catch (err) {
    console.warn("Could not load saved plans:", err.message);
  }
}

function renderSavedPlans(plans) {
  savedList.innerHTML = "";

  if (!plans || plans.length === 0) {
    savedList.appendChild(savedEmpty);
    savedEmpty.hidden = false;
    return;
  }

  plans.forEach((plan) => {
    const node = savedRowTpl.content.cloneNode(true);

    node.querySelector(".saved-row__name").textContent = plan.name;
    node.querySelector(".saved-row__meta").textContent =
      `${plan.type} · ${plan.targetCalories} kcal · ${plan.meals?.length ?? 0} meals`;

    // View button
    node.querySelector(".saved-view-btn").addEventListener("click", () => {
      renderPlan(plan);
    });

    // Delete button
    const deleteBtn = node.querySelector(".saved-delete-btn");
    deleteBtn.setAttribute("aria-label", `Delete plan: ${plan.name}`);
    deleteBtn.addEventListener("click", async () => {
      if (!confirm(`Delete "${plan.name}"? This cannot be undone.`)) return;
      await deleteSavedPlan(plan.id);
    });

    savedList.appendChild(node);
  });
}

async function deleteSavedPlan(id) {
  try {
    const res  = await fetch(`${API}/plans/${id}`, { method: "DELETE" });
    const data = await res.json();

    if (!res.ok || !data.success) throw new Error(data.error ?? "Delete failed");

    await loadSavedPlans();
  } catch (err) {
    showError(`Delete failed: ${err.message}`);
  }
}

// ── Refresh button ────────────────────────────────────────────────
refreshPlansBtn.addEventListener("click", () => {
  refreshPlansBtn.disabled = true;
  loadSavedPlans().finally(() => {
    setTimeout(() => { refreshPlansBtn.disabled = false; }, 800);
  });
});

// ── HTML escape helper ────────────────────────────────────────────
function escHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

// ── Init ──────────────────────────────────────────────────────────
(async function init() {
  await checkHealth();
  await loadSavedPlans();

  // Re-check health every 30 seconds
  setInterval(checkHealth, 30_000);
})();
