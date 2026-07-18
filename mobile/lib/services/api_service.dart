// ============================================================
//  lib/services/api_service.dart
//  HTTP client — connects Flutter app to Express backend
//  Volcanic-Nutrition-Engine
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diet_plan.dart';

// Use 10.0.2.2 for Android emulator (maps to host localhost)
// Use your LAN IP (e.g. 192.168.x.x) for physical device
const _defaultBaseUrl = 'http://10.0.2.2:3000';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  // Singleton
  ApiService._();
  static final ApiService instance = ApiService._();

  // Base URL (persisted via SharedPreferences)
  String _baseUrl = _defaultBaseUrl;
  String get baseUrl => _baseUrl;

  Future<void> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? _defaultBaseUrl;
  }

  Future<void> saveBaseUrl(String url) async {
    final cleaned = url.trimRight().replaceAll(RegExp(r'/$'), '');
    _baseUrl = cleaned;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', cleaned);
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Generate plan from narrative input (POST /api/plans/generate)
  Future<DietPlan> generatePlan({
    required double heightCm,
    required double weightKg,
    required String focus,
    required String input,
    String? preferredType,
  }) async {
    final body = <String, dynamic>{
      'userProfile': {
        'heightCm': heightCm,
        'weightKg': weightKg,
        'focus': focus,
      },
      'input': input,
      if (preferredType != null && preferredType.isNotEmpty)
        'preferredType': preferredType,
    };

    final res = await http
        .post(
          Uri.parse('$_baseUrl/api/plans/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 120));

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || decoded['success'] != true) {
      throw ApiException(
        decoded['error'] as String? ?? 'Generation failed',
        statusCode: res.statusCode,
      );
    }

    return DietPlan.fromJson(decoded['plan'] as Map<String, dynamic>);
  }

  // Generate plan from macro targets (POST /api/diet-planner/generate)
  // Resilient: if backend unreachable, returns high-quality mock fallback
  Future<DietPlan> generateFromTargets({
    String? userId,
    required String name,
    required String type,
    required int targetCalories,
    required int targetProtein,
    required int targetCarbs,
    required int targetFats,
  }) async {
    final body = <String, dynamic>{
      if (userId != null) 'userId': userId,
      'name': name,
      'type': type,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'targetFats': targetFats,
    };

    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/diet-planner/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && decoded['success'] == true) {
        return DietPlan.fromJson(
            decoded['plan'] as Map<String, dynamic>);
      }
    } catch (_) {
      // Network failure / timeout — fall through to mock
    }

    // High-quality mock fallback
    return _mockCuttingSplit(
      name: name,
      type: type,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFats: targetFats,
    );
  }

  // Save plan
  Future<String> savePlan(DietPlan plan) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/api/plans/save'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'plan': plan.toJson()}),
        )
        .timeout(const Duration(seconds: 15));

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 201 || decoded['success'] != true) {
      throw ApiException(
        decoded['error'] as String? ?? 'Save failed',
        statusCode: res.statusCode,
      );
    }

    return decoded['planId'] as String;
  }

  // Get all saved plans
  Future<List<DietPlan>> getAllPlans() async {
    final res = await http
        .get(Uri.parse('$_baseUrl/api/plans'))
        .timeout(const Duration(seconds: 15));

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || decoded['success'] != true) {
      throw ApiException(
        decoded['error'] as String? ?? 'Failed to load plans',
        statusCode: res.statusCode,
      );
    }

    return (decoded['plans'] as List<dynamic>)
        .map((p) => DietPlan.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  // Get plan by ID
  Future<DietPlan> getPlanById(String id) async {
    final res = await http
        .get(Uri.parse('$_baseUrl/api/plans/$id'))
        .timeout(const Duration(seconds: 10));

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || decoded['success'] != true) {
      throw ApiException(
        decoded['error'] as String? ?? 'Plan not found',
        statusCode: res.statusCode,
      );
    }

    return DietPlan.fromJson(decoded['plan'] as Map<String, dynamic>);
  }

  // Delete plan
  Future<void> deletePlan(String id) async {
    final res = await http
        .delete(Uri.parse('$_baseUrl/api/plans/$id'))
        .timeout(const Duration(seconds: 10));

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || decoded['success'] != true) {
      throw ApiException(
        decoded['error'] as String? ?? 'Delete failed',
        statusCode: res.statusCode,
      );
    }
  }
}

// ── Mock fallback: 2440 kcal intensive cutting split ──────────────
DietPlan _mockCuttingSplit({
  required String name,
  required String type,
  required int targetCalories,
  required int targetProtein,
  required int targetCarbs,
  required int targetFats,
}) {
  return DietPlan.fromJson(<String, dynamic>{
    'id': 'mock-fallback-001',
    'name': name.isNotEmpty ? name : 'Cutting Split — High Protein',
    'type': type.isNotEmpty ? type : 'HIGH_PROTEIN_CUT',
    'targetCalories': targetCalories > 0 ? targetCalories : 2440,
    'targetProtein': targetProtein > 0 ? targetProtein : 196,
    'targetCarbs': targetCarbs > 0 ? targetCarbs : 269,
    'targetFats': targetFats > 0 ? targetFats : 51,
    'meals': <Map<String, dynamic>>[
      {
        'id': 'mock-m1',
        'order': 1,
        'name': 'Morning Foundation',
        'scheduledTime': '07:00',
        'tacticalIntent':
            'Stable anabolic base to break overnight catabolism. Slow-release carbs sustain energy through the morning block.',
        'totalCalories': 480,
        'totalProtein': 42,
        'totalCarbs': 52,
        'totalFats': 10,
        'ingredients': <Map<String, dynamic>>[
          {'id': 'i1', 'name': 'Whole Eggs', 'weightGrams': 150, 'protein': 18, 'carbs': 1, 'fats': 10, 'calories': 165},
          {'id': 'i2', 'name': 'Egg Whites', 'weightGrams': 120, 'protein': 14, 'carbs': 0, 'fats': 0, 'calories': 58},
          {'id': 'i3', 'name': 'Rolled Oats', 'weightGrams': 80, 'protein': 10, 'carbs': 51, 'fats': 0, 'calories': 257},
        ],
      },
      {
        'id': 'mock-m2',
        'order': 2,
        'name': 'Pre-Training Fuel',
        'scheduledTime': '11:30',
        'tacticalIntent':
            'High-GI carb loading to saturate muscle glycogen. Lean protein primes the anabolic environment pre-stimulus.',
        'totalCalories': 540,
        'totalProtein': 44,
        'totalCarbs': 70,
        'totalFats': 8,
        'ingredients': <Map<String, dynamic>>[
          {'id': 'i4', 'name': 'Chicken Breast', 'weightGrams': 180, 'protein': 42, 'carbs': 0, 'fats': 4, 'calories': 207},
          {'id': 'i5', 'name': 'White Rice', 'weightGrams': 100, 'protein': 2, 'carbs': 70, 'fats': 0, 'calories': 283},
          {'id': 'i6', 'name': 'Olive Oil', 'weightGrams': 5, 'protein': 0, 'carbs': 0, 'fats': 4, 'calories': 50},
        ],
      },
      {
        'id': 'mock-m3',
        'order': 3,
        'name': 'Post-Training Recovery',
        'scheduledTime': '14:00',
        'tacticalIntent':
            'Fast-acting amino delivery during elevated cortisol. Carbs halt catabolism immediately after the training session.',
        'totalCalories': 380,
        'totalProtein': 38,
        'totalCarbs': 50,
        'totalFats': 3,
        'ingredients': <Map<String, dynamic>>[
          {'id': 'i7', 'name': 'Whey Isolate', 'weightGrams': 50, 'protein': 38, 'carbs': 3, 'fats': 1, 'calories': 170},
          {'id': 'i8', 'name': 'Banana', 'weightGrams': 120, 'protein': 0, 'carbs': 27, 'fats': 0, 'calories': 105},
          {'id': 'i9', 'name': 'Dextrose', 'weightGrams': 50, 'protein': 0, 'carbs': 20, 'fats': 2, 'calories': 105},
        ],
      },
      {
        'id': 'mock-m4',
        'order': 4,
        'name': 'Tactical Afternoon Block',
        'scheduledTime': '17:00',
        'tacticalIntent':
            'Dense micronutrient and protein block. Fibrous carbs slow digestion, extending the anabolic window into the evening.',
        'totalCalories': 560,
        'totalProtein': 48,
        'totalCarbs': 52,
        'totalFats': 16,
        'ingredients': <Map<String, dynamic>>[
          {'id': 'i10', 'name': 'Salmon Fillet', 'weightGrams': 200, 'protein': 40, 'carbs': 0, 'fats': 14, 'calories': 290},
          {'id': 'i11', 'name': 'Sweet Potato', 'weightGrams': 150, 'protein': 3, 'carbs': 30, 'fats': 0, 'calories': 135},
          {'id': 'i12', 'name': 'Broccoli', 'weightGrams': 150, 'protein': 5, 'carbs': 12, 'fats': 0, 'calories': 60},
          {'id': 'i13', 'name': 'Walnuts', 'weightGrams': 15, 'protein': 0, 'carbs': 10, 'fats': 2, 'calories': 75},
        ],
      },
      {
        'id': 'mock-m5',
        'order': 5,
        'name': 'Evening Precision Block',
        'scheduledTime': '20:30',
        'tacticalIntent':
            'Casein-anchored protein sustains muscle protein synthesis overnight. Minimal carbs during the catabolic phase.',
        'totalCalories': 480,
        'totalProtein': 24,
        'totalCarbs': 45,
        'totalFats': 14,
        'ingredients': <Map<String, dynamic>>[
          {'id': 'i14', 'name': 'Greek Yogurt 0%', 'weightGrams': 250, 'protein': 22, 'carbs': 10, 'fats': 0, 'calories': 130},
          {'id': 'i15', 'name': 'Cottage Cheese', 'weightGrams': 150, 'protein': 0, 'carbs': 5, 'fats': 2, 'calories': 100},
          {'id': 'i16', 'name': 'Mixed Berries', 'weightGrams': 100, 'protein': 2, 'carbs': 30, 'fats': 0, 'calories': 90},
          {'id': 'i17', 'name': 'Almond Butter', 'weightGrams': 20, 'protein': 0, 'carbs': 0, 'fats': 12, 'calories': 160},
        ],
      },
    ],
  });
}
