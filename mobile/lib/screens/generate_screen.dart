// ============================================================
//  lib/screens/generate_screen.dart
//  Aura Diet Planner — Tactical Nutrition Generator
//  Volcanic Cyberpunk spec
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/diet_plan.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/macro_chip.dart';
import '../widgets/meal_card.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _heightCtrl  = TextEditingController(text: '188');
  final _weightCtrl  = TextEditingController(text: '84');
  final _focusCtrl   = TextEditingController(
      text: 'High-performance training, powerbuilding recovery');
  final _inputCtrl   = TextEditingController();

  String? _selectedType;
  bool    _loading  = false;
  String? _error;
  DietPlan? _plan;
  bool    _saving   = false;

  final List<(String, String)> _planTypes = const [
    ('Auto-detect',       ''),
    ('High Protein Cut',  'HIGH_PROTEIN_CUT'),
    ('Bulk',              'BULK'),
    ('Keto',              'KETO'),
    ('Carnivore',         'CARNIVORE'),
    ('Custom',            'CUSTOM'),
  ];

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _focusCtrl.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; _plan = null; });
    try {
      final plan = await ApiService.instance.generatePlan(
        heightCm:      double.parse(_heightCtrl.text.trim()),
        weightKg:      double.parse(_weightCtrl.text.trim()),
        focus:         _focusCtrl.text.trim(),
        input:         _inputCtrl.text.trim(),
        preferredType: _selectedType,
      );
      setState(() { _plan = plan; _loading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _savePlan() async {
    if (_plan == null) return;
    setState(() => _saving = true);
    try {
      await ApiService.instance.savePlan(_plan!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Plan saved successfully.'),
            backgroundColor: AuraColors.success.withAlpha(220),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AuraColors.error.withAlpha(220),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [

        // ── High-impact performance header ──────────────────────
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            decoration: const BoxDecoration(
              gradient: AuraGradients.heroBg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Engine badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AuraColors.orange.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AuraColors.orange.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: AuraColors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'VOLCANIC-NUTRITION-ENGINE v1.0',
                        style: AuraText.label(
                            size: 9, color: AuraColors.orange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Main headline — NO "AI" anywhere
                Text(
                  'Tactical Nutrition.\nEngineered for\nPerformance.',
                  style: AuraText.display(size: 30, weight: FontWeight.w900),
                ),
                const SizedBox(height: 10),

                // Sub-headline
                Text(
                  'Describe your diet style or goal — the engine generates a precision-optimized full-day plan.',
                  style: AuraText.body(size: 13),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),

        // ── Profile Specs Summary layer ─────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Section label
                  Text(
                    'PROFILE SPECS',
                    style: AuraText.label(
                        size: 10,
                        color: AuraColors.orange,
                        letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 12),

                  // Height + Weight numeric containers
                  Row(
                    children: [
                      Expanded(
                        child: _NumericField(
                          ctrl: _heightCtrl,
                          label: 'Height',
                          unit: 'cm',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NumericField(
                          ctrl: _weightCtrl,
                          label: 'Weight',
                          unit: 'kg',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Training Focus tracking card
                  _TrainingFocusCard(ctrl: _focusCtrl),
                  const SizedBox(height: 24),

                  // Plan type
                  Text(
                    'PLAN TYPE',
                    style: AuraText.label(
                        size: 10,
                        color: AuraColors.orange,
                        letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 10),
                  _PlanTypeSelector(
                    types: _planTypes,
                    selected: _selectedType,
                    onSelect: (v) =>
                        setState(() => _selectedType = v),
                  ),
                  const SizedBox(height: 20),

                  // Goal input
                  Text(
                    'DESCRIBE YOUR GOAL',
                    style: AuraText.label(
                        size: 10,
                        color: AuraColors.orange,
                        letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _inputCtrl,
                    style: AuraText.body(
                        size: 14, color: AuraColors.textPrimary),
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'e.g. Full powerbuilding bulk day — 3500 kcal, high carb pre-workout, casein before bed',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().length < 5)
                            ? 'Describe your goal (min 5 chars)'
                            : null,
                  ),
                  const SizedBox(height: 20),

                  // Generate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _generate,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.black),
                            )
                          : const Icon(Icons.bolt,
                              size: 20, color: Colors.black),
                      label: Text(
                        _loading
                            ? 'Generating Plan...'
                            : 'Generate Plan',
                        style: AuraText.body(
                                size: 15, color: Colors.black)
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),

                  if (_loading) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Engine processing — may take up to 60s',
                        style: AuraText.body(
                            size: 11, color: AuraColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),

        // ── Error banner ─────────────────────────────────────────
        if (_error != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AuraColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AuraColors.error.withAlpha(80)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AuraColors.error, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_error!,
                          style: AuraText.mono(
                              size: 11, color: AuraColors.error)),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Plan result ──────────────────────────────────────────
        if (_plan != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _PlanOverview(
                plan: _plan!,
                saving: _saving,
                onSave: _savePlan,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'MEAL BREAKDOWN',
                style: AuraText.label(
                    size: 10,
                    color: AuraColors.orange,
                    letterSpacing: 2.0),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: EdgeInsets.fromLTRB(
                    20, i == 0 ? 0 : 10, 20,
                    i == _plan!.meals.length - 1 ? 32 : 0),
                child: MealCard(meal: _plan!.meals[i]),
              ),
              childCount: _plan!.meals.length,
            ),
          ),
        ] else
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Numeric input container ────────────────────────────────────────
class _NumericField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String unit;

  const _NumericField({
    required this.ctrl,
    required this.label,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: glassCard(radius: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AuraText.label(
                size: 9, color: AuraColors.textMuted, letterSpacing: 1.5),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextFormField(
                  controller: ctrl,
                  style: AuraText.display(
                      size: 26, weight: FontWeight.w900,
                      color: AuraColors.textPrimary),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    fillColor: Colors.transparent,
                    filled: false,
                  ),
                  validator: (v) =>
                      double.tryParse(v ?? '') == null ? '?' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit,
                    style: AuraText.label(
                        size: 11, color: AuraColors.orange)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Training Focus tracking card ───────────────────────────────────
class _TrainingFocusCard extends StatelessWidget {
  final TextEditingController ctrl;
  const _TrainingFocusCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AuraColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.track_changes_rounded,
                  size: 13, color: AuraColors.orange),
              const SizedBox(width: 6),
              Text(
                'TRAINING FOCUS',
                style: AuraText.label(
                    size: 9,
                    color: AuraColors.orange,
                    letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            style: AuraText.body(
                size: 13, color: AuraColors.textPrimary),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              fillColor: Colors.transparent,
              filled: false,
              hintText: 'e.g. powerbuilding, endurance, fat loss...',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}

// ── Plan type selector ─────────────────────────────────────────────
class _PlanTypeSelector extends StatelessWidget {
  final List<(String, String)> types;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _PlanTypeSelector({
    required this.types,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: types.map((t) {
          final (label, value) = t;
          final active = selected == value ||
              (selected == null && value == '');
          return GestureDetector(
            onTap: () => onSelect(value.isEmpty ? null : value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: active ? AuraGradients.brand : null,
                color: active ? null : AuraColors.bgCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : AuraColors.border,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AuraColors.orange.withAlpha(100),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: AuraText.label(
                  size: 11,
                  color: active
                      ? Colors.black
                      : AuraColors.textSecondary,
                  letterSpacing: 0.5,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          );
        }).toList(),
      );
}

// ── Plan overview card ─────────────────────────────────────────────
class _PlanOverview extends StatelessWidget {
  final DietPlan plan;
  final bool saving;
  final VoidCallback onSave;

  const _PlanOverview({
    required this.plan,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AuraColors.orange.withAlpha(80)),
          gradient: AuraGradients.card,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AuraColors.orange.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AuraColors.orange.withAlpha(60)),
                  ),
                  child: Text(
                    plan.type.label,
                    style: AuraText.label(
                            size: 9, color: AuraColors.orange)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AuraColors.orange))
                      : const Icon(Icons.bookmark_add_outlined,
                          size: 16, color: AuraColors.orange),
                  label: Text(
                    saving ? 'Saving...' : 'Save Plan',
                    style: AuraText.label(
                        size: 11, color: AuraColors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(plan.name,
                style: AuraText.display(
                    size: 16, weight: FontWeight.w800)),
            const SizedBox(height: 16),
            MacroRow(
              calories: plan.targetCalories,
              protein: plan.targetProtein,
              carbs: plan.targetCarbs,
              fats: plan.targetFats,
              large: true,
            ),
          ],
        ),
      );
}
