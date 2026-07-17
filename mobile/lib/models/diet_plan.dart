// ============================================================
//  lib/models/diet_plan.dart
//  Top-level diet plan — root domain model
// ============================================================

import 'meal.dart';

enum PlanType { KETO, CARNIVORE, HIGH_PROTEIN_CUT, BULK, CUSTOM }

extension PlanTypeLabel on PlanType {
  String get label => switch (this) {
        PlanType.KETO             => 'KETO',
        PlanType.CARNIVORE        => 'CARNIVORE',
        PlanType.HIGH_PROTEIN_CUT => 'HIGH PROTEIN CUT',
        PlanType.BULK             => 'BULK',
        PlanType.CUSTOM           => 'CUSTOM',
      };

  static PlanType fromString(String s) => PlanType.values.firstWhere(
        (e) => e.name == s,
        orElse: () => PlanType.CUSTOM,
      );
}

class DietPlan {
  final String? id;
  final String name;
  final PlanType type;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFats;
  final List<Meal> meals;
  final DateTime? createdAt;

  const DietPlan({
    this.id,
    required this.name,
    required this.type,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFats,
    required this.meals,
    this.createdAt,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) => DietPlan(
        id: json['id'] as String?,
        name: json['name'] as String,
        type: PlanTypeLabel.fromString(json['type'] as String),
        targetCalories: (json['targetCalories'] as num).toInt(),
        targetProtein: (json['targetProtein'] as num).toInt(),
        targetCarbs: (json['targetCarbs'] as num).toInt(),
        targetFats: (json['targetFats'] as num).toInt(),
        meals: (json['meals'] as List<dynamic>)
            .map((m) => Meal.fromJson(m as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order)),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'type': type.name,
        'targetCalories': targetCalories,
        'targetProtein': targetProtein,
        'targetCarbs': targetCarbs,
        'targetFats': targetFats,
        'meals': meals.map((m) => m.toJson()).toList(),
      };
}
