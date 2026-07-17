// ============================================================
//  lib/screens/generate_screen.dart
//  AI diet plan generator — form + results view
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
  final _formKey = GlobalKey<FormState>();
  final _heightCtrl = TextEditingController(text: '188');
  final _weightCtrl = TextEditingController(text: '84');
  final _focusCtrl  = TextEditingController(
      text: 'High-performance training, powerbuilding recovery');
  final _inputCtrl  = TextEditingController();

  String? _selectedType;
  bool _loading = false;
  String? _error;
  DietPlan? _plan;
  bool _saving = false;

  final List<(String, String)> _planTypes = const [
    ('Auto-detect', ''),
    ('High Protein Cut', 'HIGH_PROTEIN_CUT'),
    ('Bulk', 'BULK'),
    ('Keto', 'KETO'),
    ('Carnivore', 'CARNIVORE'),
    ('Custom', 'CUSTOM'),
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
        heightCm: double.parse(_heightCtrl.text.trim()),
        weightKg: double.parse(_weightCtrl.text.trim()),
        focus: _focusCtrl.text.trim(),
        input: _inputCtrl.text.trim(),
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
            content: const Text('✅ Plan saved successfully!'),
            backgroundColor: AuraColors.success.withAlpha(220),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.message}'),
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
        // ── Hero header ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AuraColors.orange.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AuraColors.orange.withAlpha(60)),
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
                        style: AuraText.mono(
                            size: 9, color: AuraColors.orange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Tactical Nutrition.\nEngineered for\nPerformance.',
                  style: AuraText.display(size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'Describe your diet style or goal — the AI engine\ngenerates a precision-optimized full-day plan.',
                  style: AuraText.body(size: 13),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // ── Form card ───────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Container(
                decoration: glassCard(radius: 20),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Profile',
                        style: AuraText.label(color: AuraColors.textSecondary)),
                    const SizedBox(height: 12),

                    // Height + Weight row
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            ctrl: _heightCtrl,
                            label: 'Height (cm)',
                            hint: '188',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNumberField(
                            ctrl: _weightCtrl,
                            label: 'Weight (kg)',
                            hint: '84',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Training focus
                    _buildTextField(
                      ctrl: _focusCtrl,
                      label: 'Training Focus',
                      hint: 'High-performance training, powerbuilding...',
                    ),
                    const SizedBox(height: 20),

                    // Plan type selector
                    Text('Plan Type',
                        style: AuraText.label(color: AuraColors.textSecondary)),
                    const SizedBox(height: 10),
                    _PlanTypeSelector(
                      types: _planTypes,
                      selected: _selectedType,
                      onSelect: (v) => setState(() => _selectedType = v),
                    ),
                    const SizedBox(height: 20),

                    // User input
                    _buildTextField(
                      ctrl: _inputCtrl,
                      label: 'Describe your goal or meal',
                      hint:
                          'e.g. Generate a full powerbuilding bulk day — 3500 kcal, high carb pre-workout, casein before bed',
                      maxLines: 4,
                      validator: (v) =>
                          (v == null || v.trim().length < 5)
                              ? 'Please describe your goal (min 5 chars)'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _generate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: _loading
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white))
                            : const Icon(Icons.bolt_rounded, size: 20),
                        label: Text(
                          _loading ? 'Generating Plan...' : 'Generate Plan',
                          style: AuraText.body(size: 16, color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    if (_loading) ...[
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          'Ollama is thinking… this may take up to 60s',
                          style: AuraText.body(
                              size: 12, color: AuraColors.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Error ────────────────────────────────────────────────
        if (_error != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AuraColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AuraColors.error.withAlpha(80)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AuraColors.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_error!,
                          style: AuraText.mono(
                              size: 12, color: AuraColors.error)),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Plan results ─────────────────────────────────────────
        if (_plan != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _PlanOverviewCard(
                plan: _plan!,
                saving: _saving,
                onSave: _savePlan,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text('Meal Breakdown',
                  style: AuraText.label(color: AuraColors.textSecondary)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: EdgeInsets.fromLTRB(
                    20, i == 0 ? 10 : 8, 20, i == _plan!.meals.length - 1 ? 32 : 0),
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

  // ── Field builders ─────────────────────────────────────────────
  Widget _buildNumberField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
  }) =>
      TextFormField(
        controller: ctrl,
        style: AuraText.mono(size: 14),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: (v) =>
            (v == null || double.tryParse(v) == null) ? 'Enter a valid number' : null,
      );

  Widget _buildTextField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        style: AuraText.body(size: 14, color: AuraColors.textPrimary),
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: validator ??
            (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      );
}

// ── Plan type chip selector ─────────────────────────────────────
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
          final isSelected = selected == value ||
              (selected == null && value == '');
          return GestureDetector(
            onTap: () => onSelect(value.isEmpty ? null : value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AuraGradients.brand : null,
                color: isSelected ? null : AuraColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AuraColors.border,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AuraColors.pink.withAlpha(80),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: AuraText.label(
                  size: 12,
                  color: isSelected
                      ? Colors.white
                      : AuraColors.textSecondary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }).toList(),
      );
}

// ── Plan overview card ──────────────────────────────────────────
class _PlanOverviewCard extends StatelessWidget {
  final DietPlan plan;
  final bool saving;
  final VoidCallback onSave;

  const _PlanOverviewCard({
    required this.plan,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AuraColors.pink.withAlpha(60)),
          gradient: AuraGradients.card,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Plan type badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AuraColors.orange.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AuraColors.orange.withAlpha(60)),
                  ),
                  child: Text(
                    plan.type.label,
                    style: AuraText.mono(
                        size: 10, color: AuraColors.orange)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                // Save button
                TextButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AuraColors.pink))
                      : const Icon(Icons.bookmark_add_outlined,
                          size: 16, color: AuraColors.pink),
                  label: Text(
                    saving ? 'Saving...' : 'Save Plan',
                    style: AuraText.label(
                        size: 12, color: AuraColors.pink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(plan.name,
                style: AuraText.display(size: 18, weight: FontWeight.w800)),
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
