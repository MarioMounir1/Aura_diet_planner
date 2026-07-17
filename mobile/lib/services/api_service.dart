// ============================================================
//  lib/services/api_service.dart
//  HTTP client — connects Flutter app to Express backend
//  Volcanic-Nutrition-Engine
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diet_plan.dart';

// ── Default base URL — update to your machine's IP when on device ──
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
  // ── Singleton ──────────────────────────────────────────────────
  ApiService._();
  static final ApiService instance = ApiService._();

  // ── Base URL (persisted via SharedPreferences) ─────────────────
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

  // ── Health check ───────────────────────────────────────────────
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

  // ── Generate plan ──────────────────────────────────────────────
  Future<DietPlan> generatePlan({
    required double heightCm,
    required double weightKg,
    required String focus,
    required String input,
    String? preferredType,
  }) async {
    final body = {
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
        .timeout(const Duration(seconds: 120)); // Ollama can be slow

    final json = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || json['success'] != true) {
      throw ApiException(
        json['error'] as String? ?? 'Generation failed',
        statusCode: res.statusCode,
      );
    }

    return DietPlan.fromJson(json['plan'] as Map<String, dynamic>);
  }

  // ── Save plan ──────────────────────────────────────────────────
  Future<String> savePlan(DietPlan plan) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/api/plans/save'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'plan': plan.toJson()}),
        )
        .timeout(const Duration(seconds: 15));

    final json = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 201 || json['success'] != true) {
      throw ApiException(
        json['error'] as String? ?? 'Save failed',
        statusCode: res.statusCode,
      );
    }

    return json['planId'] as String;
  }

  // ── Get all saved plans ────────────────────────────────────────
  Future<List<DietPlan>> getAllPlans() async {
    final res = await http
        .get(Uri.parse('$_baseUrl/api/plans'))
        .timeout(const Duration(seconds: 15));

    final json = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || json['success'] != true) {
      throw ApiException(
        json['error'] as String? ?? 'Failed to load plans',
        statusCode: res.statusCode,
      );
    }

    return (json['plans'] as List<dynamic>)
        .map((p) => DietPlan.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  // ── Get plan by ID ─────────────────────────────────────────────
  Future<DietPlan> getPlanById(String id) async {
    final res = await http
        .get(Uri.parse('$_baseUrl/api/plans/$id'))
        .timeout(const Duration(seconds: 10));

    final json = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || json['success'] != true) {
      throw ApiException(
        json['error'] as String? ?? 'Plan not found',
        statusCode: res.statusCode,
      );
    }

    return DietPlan.fromJson(json['plan'] as Map<String, dynamic>);
  }

  // ── Delete plan ────────────────────────────────────────────────
  Future<void> deletePlan(String id) async {
    final res = await http
        .delete(Uri.parse('$_baseUrl/api/plans/$id'))
        .timeout(const Duration(seconds: 10));

    final json = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || json['success'] != true) {
      throw ApiException(
        json['error'] as String? ?? 'Delete failed',
        statusCode: res.statusCode,
      );
    }
  }
}
