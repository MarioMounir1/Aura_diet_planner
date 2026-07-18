// ============================================================
//  lib/screens/generate_screen.dart
//  Aura Diet Planner — 3-state Generate Screen
//  States: input → loading (shimmer) → result (plan dashboard)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/diet_plan.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/macro_chip.dart';
import '../widgets/macro_ring.dart';
import '../widgets/meal_card.dart';
import '../widgets/shimmer_box.dart';

// ── Screen state machine ───────────────────────────────────────────
enum _ScreenState { input, loading, result }

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _heightCtrl = TextEditingController(text: '188');
  final _weightCtrl = TextEditingController(text: '84');
  final _focusCtrl  = TextEditingController(
      text: 'High-performance training, powerbuilding recovery');
  final _inputCtrl  = TextEditingController();

  String?      _selectedType;
  _ScreenState _state  = _ScreenState.input;
  String?      _error;
  DietPlan?    _plan;
  bool         _saving = false;

  final List<(String, String)> _planTypes = const [
    ('Auto-detect',      ''),
    ('High Protein Cut', 'HIGH_PROTEIN_CUT'),
    ('Bulk',             'BULK'),
    ('Keto',             'KETO'),
    ('Carnivore',        'CARNIVORE'),
    ('Custom',           'CUSTOM'),
  ];

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _focusCtrl.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  // ── Trigger generation ─────────────────────────────────────────
  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _state = _ScreenState.loading; _error = null; });

    try {
      final plan = await ApiService.instance.generatePlan(
        heightCm:      double.parse(_heightCtrl.text.trim()),
        weightKg:      double.parse(_weightCtrl.text.trim()),
        focus:         _focusCtrl.text.trim(),
        input:         _inputCtrl.text.trim(),
        preferredType: _selectedType,
      );
      if (mounted) setState(() { _plan = plan; _state = _ScreenState.result; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _state = _ScreenState.input; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _state = _ScreenState.input; });
    }
  }

  // ── Reset to input form ────────────────────────────────────────
  void _reset() => setState(() {
        _state = _ScreenState.input;
        _plan  = null;
        _error = null;
      });

  // ── Save plan ──────────────────────────────────────────────────
  Future<void> _savePlan() async {
    if (_plan == null) return;
    setState(() => _saving = true);
    try {
      await ApiService.instance.savePlan(_plan!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Plan saved.'),
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: switch (_state) {
        _ScreenState.input   => _buildInputView(),
        _ScreenState.loading => _buildLoadingView(),
        _ScreenState.result  => _buildResultView(),
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  STATE 1 — Input form
  // ══════════════════════════════════════════════════════════════
  Widget _buildInputView() {
    return CustomScrollView(
      key: const ValueKey('input'),
      slivers: [

        // ── Hero header ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            decoration: const BoxDecoration(gradient: AuraGradients.heroBg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EngineBadge(),
                const SizedBox(height: 16),
                Text(
                  'Tactical Nutrition.\nEngineered for\nPerformance.',
                  style:
                      AuraText.display(size: 30, weight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  'Describe your diet style or goal — the engine generates a precision-optimized full-day plan.',
                  style: AuraText.body(size: 13),
                ),
              ],
            ),
          ),
        ),

        // ── Error banner ───────────────────────────────────────
        if (_error != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _ErrorBanner(message: _error!),
            ),
          ),

        // ── Form ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Profile specs
                  _SectionLabel('PROFILE SPECS'),
                  const SizedBox(height: 12),
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
                  _TrainingFocusCard(ctrl: _focusCtrl),
                  const SizedBox(height: 24),

                  // Plan type — horizontal scrollable chip selector
                  _SectionLabel('PLAN TYPE'),
                  const SizedBox(height: 10),
                  _PlanChipSelector(
                    types: _planTypes,
                    selected: _selectedType,
                    onSelect: (v) =>
                        setState(() => _selectedType = v),
                  ),
                  const SizedBox(height: 24),

                  // Narrative query input
                  _SectionLabel('DESCRIBE YOUR GOAL'),
                  const SizedBox(height: 10),
                  _NarrativeInput(ctrl: _inputCtrl),
                  const SizedBox(height: 24),

                  // Generate button
                  _GenerateButton(onTap: _generate),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  STATE 2 — Loading shimmer
  // ══════════════════════════════════════════════════════════════
  Widget _buildLoadingView() {
    return SingleChildScrollView(
      key: const ValueKey('loading'),
      child: const GenerateFormSkeleton(),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  STATE 3 — Active Plan Dashboard
  // ══════════════════════════════════════════════════════════════
  Widget _buildResultView() {
    final plan = _plan!;
    final total = plan.targetProtein + plan.targetCarbs + plan.targetFats;

    return CustomScrollView(
      key: const ValueKey('result'),
      slivers: [

        // ── Dashboard header ───────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            decoration: const BoxDecoration(gradient: AuraGradients.heroBg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + save row
                Row(
                  children: [
                    GestureDetector(
                      onTap: _reset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AuraColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AuraColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_rounded,
                                size: 14,
                                color: AuraColors.textSecondary),
                            const SizedBox(width: 6),
                            Text('New Plan',
                                style: AuraText.label(
                                    size: 11,
                                    color: AuraColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _saving ? null : _savePlan,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AuraColors.orange.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AuraColors.orange.withAlpha(80)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _saving
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: AuraColors.orange))
                                : const Icon(Icons.bookmark_add_rounded,
                                    size: 14,
                                    color: AuraColors.orange),
                            const SizedBox(width: 6),
                            Text(
                              _saving ? 'Saving...' : 'Save Plan',
                              style: AuraText.label(
                                  size: 11,
                                  color: AuraColors.orange),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Plan type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AuraColors.orange.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AuraColors.orange.withAlpha(70)),
                  ),
                  child: Text(
                    plan.type.label,
                    style: AuraText.label(
                            size: 9, color: AuraColors.orange)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 10),

                // Plan name
                Text(
                  plan.name,
                  style: AuraText.display(
                      size: 18, weight: FontWeight.w800),
                ),
                const SizedBox(height: 24),

                // Calorie count-up
                Center(
                  child: CalorieDisplay(calories: plan.targetCalories),
                ),
                const SizedBox(height: 28),

                // Macro rings row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MacroRing(
                      label: 'Protein',
                      value: plan.targetProtein,
                      total: total,
                      color: const Color(0xFFFF7B00), // Volt Orange
                    ),
                    MacroRing(
                      label: 'Carbs',
                      value: plan.targetCarbs,
                      total: total,
                      color: const Color(0xFFFF9D42), // Cyber Amber
                    ),
                    MacroRing(
                      label: 'Fats',
                      value: plan.targetFats,
                      total: total,
                      color: const Color(0xFF8B949E), // Slate
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),

        // ── Meal breakdown ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: _SectionLabel('MEAL BREAKDOWN'),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => Padding(
              padding: EdgeInsets.fromLTRB(
                  20, i == 0 ? 0 : 10, 20,
                  i == plan.meals.length - 1 ? 40 : 0),
              child: MealCard(meal: plan.meals[i]),
            ),
            childCount: plan.meals.length,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  COMPONENTS
// ══════════════════════════════════════════════════════════════

class _EngineBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AuraColors.orange.withAlpha(20),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AuraColors.orange.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AuraColors.orange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'VOLCANIC-NUTRITION-ENGINE v1.0',
              style: AuraText.label(size: 9, color: AuraColors.orange),
            ),
          ],
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AuraText.label(
            size: 10, color: AuraColors.orange, letterSpacing: 2.0),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AuraColors.error.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AuraColors.error.withAlpha(80)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AuraColors.error, size: 15),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style:
                      AuraText.mono(size: 11, color: AuraColors.error)),
            ),
          ],
        ),
      );
}

class _NumericField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String unit;
  const _NumericField(
      {required this.ctrl, required this.label, required this.unit});

  @override
  Widget build(BuildContext context) => Container(
        decoration: glassCard(radius: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AuraText.label(
                  size: 9,
                  color: AuraColors.textMuted,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ctrl,
                    style: AuraText.display(
                        size: 26,
                        weight: FontWeight.w900,
                        color: AuraColors.textPrimary),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d.]'))
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
                  padding: const EdgeInsets.only(bottom: 3),
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

class _TrainingFocusCard extends StatelessWidget {
  final TextEditingController ctrl;
  const _TrainingFocusCard({required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
        decoration: glassCard(radius: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.track_changes_rounded,
                    size: 12, color: AuraColors.orange),
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
                hintText: 'powerbuilding, endurance, fat loss...',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ],
        ),
      );
}

// ── Horizontal scrollable plan chip selector with glow ─────────────
class _PlanChipSelector extends StatelessWidget {
  final List<(String, String)> types;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _PlanChipSelector({
    required this.types,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.asMap().entries.map((e) {
          final (label, value) = e.value;
          final isLast = e.key == types.length - 1;
          final active = selected == value ||
              (selected == null && value == '');

          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: _PlanChip(
              label: label,
              active: active,
              onTap: () => onSelect(value.isEmpty ? null : value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PlanChip extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _PlanChip(
      {required this.label,
      required this.active,
      required this.onTap});

  @override
  State<_PlanChip> createState() => _PlanChipState();
}

class _PlanChipState extends State<_PlanChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _glow =
        Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (_, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            gradient: widget.active ? AuraGradients.brand : null,
            color: widget.active ? null : AuraColors.bgCard,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.active
                  ? AuraColors.orange
                  : AuraColors.border,
              width: widget.active ? 1.5 : 1,
            ),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: AuraColors.orange
                          .withAlpha((80 * _glow.value).round()),
                      blurRadius: 14 * _glow.value,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: AuraText.label(
              size: 12,
              color:
                  widget.active ? Colors.black : AuraColors.textSecondary,
              letterSpacing: 0.4,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// ── Narrative query input with orange border ───────────────────────
class _NarrativeInput extends StatefulWidget {
  final TextEditingController ctrl;
  const _NarrativeInput({required this.ctrl});

  @override
  State<_NarrativeInput> createState() => _NarrativeInputState();
}

class _NarrativeInputState extends State<_NarrativeInput> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AuraColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _focused
                ? AuraColors.orange
                : AuraColors.amber.withAlpha(80),
            width: _focused ? 1.5 : 1.0,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: AuraColors.orange.withAlpha(40),
                    blurRadius: 12,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: TextFormField(
          controller: widget.ctrl,
          style:
              AuraText.body(size: 14, color: AuraColors.textPrimary),
          maxLines: 5,
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: 'to gain muscles and lose fat',
            contentPadding: EdgeInsets.all(16),
            fillColor: Colors.transparent,
            filled: false,
          ),
          validator: (v) =>
              (v == null || v.trim().length < 5)
                  ? 'Describe your goal (min 5 chars)'
                  : null,
        ),
      ),
    );
  }
}

// ── Generate button — full-width, flash_on icon, gradient ─────────
class _GenerateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GenerateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7B00), Color(0xFFFF9D42)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF7B00).withAlpha(90),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flash_on,
                color: Colors.black, size: 22),
            const SizedBox(width: 10),
            Text(
              'Generate Plan',
              style: AuraText.body(size: 16, color: Colors.black)
                  .copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
