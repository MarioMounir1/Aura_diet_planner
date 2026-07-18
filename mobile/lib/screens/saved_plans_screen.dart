// ============================================================
//  lib/screens/saved_plans_screen.dart
//  Saved plans list — fetch, view, delete from PostgreSQL
// ============================================================

import 'package:flutter/material.dart';
import '../models/diet_plan.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/macro_chip.dart';
import 'plan_detail_screen.dart';

class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({super.key});

  @override
  State<SavedPlansScreen> createState() => _SavedPlansScreenState();
}

class _SavedPlansScreenState extends State<SavedPlansScreen> {
  List<DietPlan> _plans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() { _loading = true; _error = null; });
    try {
      final plans = await ApiService.instance.getAllPlans();
      if (mounted) setState(() { _plans = plans; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _openPlan(DietPlan plan) async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PlanDetailScreen(plan: plan),
      ),
    );
    // Refresh if a plan was deleted from detail screen
    if (deleted == true && mounted) await _loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadPlans,
      color: AuraColors.orange,
      backgroundColor: AuraColors.bgCard,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saved Plans',
                            style: AuraText.display(
                                size: 26, weight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                          _loading
                              ? 'Loading...'
                              : '${_plans.length} plan${_plans.length != 1 ? 's' : ''} stored',
                          style: AuraText.body(size: 13),
                        ),
                      ],
                    ),
                  ),
                  // Refresh button
                  GestureDetector(
                    onTap: _loadPlans,
                    child: Container(
                      width: 40, height: 40,
                      decoration: glassCard(radius: 12),
                      child: const Icon(Icons.refresh_rounded,
                          color: AuraColors.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Loading state ───────────────────────────────────────
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AuraColors.orange,
                      strokeWidth: 2.5,
                    ),
                    SizedBox(height: 16),
                    Text('Fetching plans...',
                        style: TextStyle(color: AuraColors.textMuted)),
                  ],
                ),
              ),
            )

          // ── Error state ─────────────────────────────────────────
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          color: AuraColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load plans',
                        style: AuraText.display(
                            size: 18, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: AuraText.body(
                            size: 12, color: AuraColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadPlans,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            )

          // ── Empty state ─────────────────────────────────────────
          else if (_plans.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) =>
                            AuraGradients.brand.createShader(b),
                        child: const Icon(Icons.bookmark_border_rounded,
                            size: 64, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No saved plans yet',
                        style: AuraText.display(
                            size: 20, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Generate a plan in the Generate tab\nand tap "Save Plan" to store it here.',
                        style: AuraText.body(size: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )

          // ── Plans list ──────────────────────────────────────────
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final plan = _plans[i];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      i == 0 ? 0 : 10,
                      20,
                      i == _plans.length - 1 ? 32 : 0,
                    ),
                    child: _PlanListItem(
                      plan: plan,
                      onTap: () => _openPlan(plan),
                    ),
                  );
                },
                childCount: _plans.length,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Plan list item card ─────────────────────────────────────────
class _PlanListItem extends StatelessWidget {
  final DietPlan plan;
  final VoidCallback onTap;

  const _PlanListItem({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: glassCard(radius: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card top ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Plan type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AuraColors.orange.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AuraColors.orange.withAlpha(60)),
                        ),
                        child: Text(
                          plan.type.label,
                          style: AuraText.mono(
                                  size: 9, color: AuraColors.orange)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Spacer(),
                      // Date
                      if (plan.createdAt != null)
                        Text(
                          _shortDate(plan.createdAt!),
                          style: AuraText.mono(
                              size: 10, color: AuraColors.textMuted),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded,
                          color: AuraColors.textMuted, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan.name,
                    style: AuraText.display(
                        size: 16, weight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.meals.length} meals',
                    style: AuraText.body(
                        size: 12, color: AuraColors.textMuted),
                  ),
                ],
              ),
            ),

            // ── Macro strip ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: MacroRow(
                calories: plan.targetCalories,
                protein:  plan.targetProtein,
                carbs:    plan.targetCarbs,
                fats:     plan.targetFats,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
