// ============================================================
//  lib/models/meal.dart
//  A single meal within a diet plan
// ============================================================

import 'ingredient.dart';

class Meal {
  final String? id;
  final int order;
  final String name;
  final String scheduledTime;
  final String tacticalIntent;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFats;
  final List<Ingredient> ingredients;

  const Meal({
    this.id,
    required this.order,
    required this.name,
    required this.scheduledTime,
    required this.tacticalIntent,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id'] as String?,
        order: (json['order'] as num).toInt(),
        name: json['name'] as String,
        scheduledTime: json['scheduledTime'] as String,
        tacticalIntent: json['tacticalIntent'] as String,
        totalCalories: (json['totalCalories'] as num).toInt(),
        totalProtein: (json['totalProtein'] as num).toInt(),
        totalCarbs: (json['totalCarbs'] as num).toInt(),
        totalFats: (json['totalFats'] as num).toInt(),
        ingredients: (json['ingredients'] as List<dynamic>)
            .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'order': order,
        'name': name,
        'scheduledTime': scheduledTime,
        'tacticalIntent': tacticalIntent,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFats': totalFats,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
      };
}
