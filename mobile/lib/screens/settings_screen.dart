// ============================================================
//  lib/screens/settings_screen.dart
//  API base URL configuration screen
// ============================================================

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlCtrl;
  bool _saving = false;
  bool? _lastCheck;

  @override
  void initState() {
    super.initState();
    _urlCtrl =
        TextEditingController(text: ApiService.instance.baseUrl);
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() { _saving = true; _lastCheck = null; });
    await ApiService.instance.saveBaseUrl(_urlCtrl.text.trim());
    final ok = await ApiService.instance.checkHealth();
    if (mounted) {
      setState(() { _saving = false; _lastCheck = ok; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '✅ Engine is reachable!' : '❌ Could not reach the engine.'),
          backgroundColor: ok ? AuraColors.success.withAlpha(200) : AuraColors.error.withAlpha(200),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Section header ──────────────────────────────────────
        Text('Engine Connection', style: AuraText.display(size: 20)),
        const SizedBox(height: 4),
        Text(
          'Set the base URL of the Volcanic-Nutrition-Engine backend.',
          style: AuraText.body(size: 13),
        ),
        const SizedBox(height: 24),

        // ── URL field ───────────────────────────────────────────
        Container(
          decoration: glassCard(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('API Base URL', style: AuraText.label()),
              const SizedBox(height: 10),
              TextField(
                controller: _urlCtrl,
                style: AuraText.mono(size: 13),
                decoration: const InputDecoration(
                  hintText: 'http://10.0.2.2:3000',
                  prefixIcon: Icon(Icons.link_rounded,
                      color: AuraColors.textMuted, size: 18),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),
              const SizedBox(height: 8),
              Text(
                '• Android emulator → 10.0.2.2:3000\n'
                '• Physical device  → your LAN IP:3000\n'
                '• iOS simulator    → localhost:3000',
                style: AuraText.label(size: 11, color: AuraColors.textMuted),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(_saving ? 'Checking...' : 'Save & Test Connection'),
                ),
              ),
              if (_lastCheck != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      _lastCheck! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: _lastCheck! ? AuraColors.success : AuraColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _lastCheck! ? 'Engine online' : 'Engine unreachable',
                      style: AuraText.body(
                          size: 13,
                          color: _lastCheck! ? AuraColors.success : AuraColors.error),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── App info ────────────────────────────────────────────
        Container(
          decoration: glassCard(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About', style: AuraText.label()),
              const SizedBox(height: 12),
              _InfoRow('Engine', 'Volcanic-Nutrition-Engine v1.0'),
              _InfoRow('AI Model', 'Local Ollama (llama3)'),
              _InfoRow('Database', 'PostgreSQL + Prisma'),
              _InfoRow('Version', '1.0.0+1'),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AuraText.body(size: 13, color: AuraColors.textMuted)),
            Text(value,
                style: AuraText.mono(size: 12, color: AuraColors.textSecondary)),
          ],
        ),
      );
}
