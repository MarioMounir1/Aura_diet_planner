// ============================================================
//  lib/models/ingredient.dart
//  Single ingredient within a meal
// ============================================================

class Ingredient {
  final String? id;
  final String name;
  final int weightGrams;
  final int protein;
  final int carbs;
  final int fats;
  final int calories;

  const Ingredient({
    this.id,
    required this.name,
    required this.weightGrams,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.calories,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json['id'] as String?,
        name: json['name'] as String,
        weightGrams: (json['weightGrams'] as num).toInt(),
        protein: (json['protein'] as num).toInt(),
        carbs: (json['carbs'] as num).toInt(),
        fats: (json['fats'] as num).toInt(),
        calories: (json['calories'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'weightGrams': weightGrams,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'calories': calories,
      };
}
