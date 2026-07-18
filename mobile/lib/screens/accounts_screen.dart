// ============================================================
//  lib/screens/accounts_screen.dart
//  Aura Diet Planner — Account & Engine Configuration
//  Replaces old settings screen — Volcanic Cyberpunk spec
// ============================================================

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  late TextEditingController _urlCtrl;
  bool _saving  = false;
  bool? _status;

  @override
  void initState() {
    super.initState();
    _urlCtrl = TextEditingController(text: ApiService.instance.baseUrl);
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndTest() async {
    setState(() { _saving = true; _status = null; });
    await ApiService.instance.saveBaseUrl(_urlCtrl.text.trim());
    final ok = await ApiService.instance.checkHealth();
    if (mounted) {
      setState(() { _saving = false; _status = ok; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              ok ? 'Engine reachable.' : 'Engine unreachable.'),
          backgroundColor: (ok ? AuraColors.success : AuraColors.error)
              .withAlpha(220),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [

        // ── Account header ──────────────────────────────────────
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: AuraGradients.brand,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.orange.withAlpha(80),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.black, size: 26),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ACCOUNT',
                    style: AuraText.display(
                        size: 18, weight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text('Engine & connection settings',
                    style: AuraText.body(size: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ── Engine Connection card ──────────────────────────────
        _SectionLabel('ENGINE CONNECTION'),
        const SizedBox(height: 10),
        Container(
          decoration: glassCard(radius: 12),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API Base URL',
                style: AuraText.label(
                    size: 10,
                    color: AuraColors.textSecondary,
                    letterSpacing: 1.2),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _urlCtrl,
                style: AuraText.mono(
                    size: 13, color: AuraColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'http://10.0.2.2:3000',
                  prefixIcon: const Icon(Icons.link_rounded,
                      color: AuraColors.textMuted, size: 16),
                  // Status color on border
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _status == null
                          ? AuraColors.orange
                          : (_status! ? AuraColors.success : AuraColors.error),
                      width: 1.5,
                    ),
                  ),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),
              const SizedBox(height: 10),
              // Platform hints
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AuraColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AuraColors.border),
                ),
                child: Column(
                  children: [
                    _HintRow(
                        icon: Icons.phone_android_rounded,
                        label: 'Android Emulator',
                        value: '10.0.2.2:3000'),
                    const SizedBox(height: 6),
                    _HintRow(
                        icon: Icons.wifi_rounded,
                        label: 'Physical Device',
                        value: '192.168.x.x:3000'),
                    const SizedBox(height: 6),
                    _HintRow(
                        icon: Icons.laptop_mac_rounded,
                        label: 'iOS Simulator',
                        value: 'localhost:3000'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveAndTest,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.check_rounded,
                          size: 18, color: Colors.black),
                  label: Text(
                    _saving ? 'Testing...' : 'Save & Test Connection',
                    style: AuraText.body(size: 14, color: Colors.black)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (_status != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      _status!
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: _status!
                          ? AuraColors.success
                          : AuraColors.error,
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _status! ? 'Engine online' : 'Engine unreachable',
                      style: AuraText.body(
                          size: 13,
                          color: _status!
                              ? AuraColors.success
                              : AuraColors.error),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Stack info card ─────────────────────────────────────
        _SectionLabel('SYSTEM STACK'),
        const SizedBox(height: 10),
        Container(
          decoration: glassCard(radius: 12),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _StackRow(label: 'Engine',   value: 'Volcanic-Nutrition-Engine v1.0'),
              const _Divider(),
              _StackRow(label: 'Inference', value: 'Local Ollama (llava)'),
              const _Divider(),
              _StackRow(label: 'Database',  value: 'PostgreSQL · Prisma ORM'),
              const _Divider(),
              _StackRow(label: 'Backend',   value: 'Node.js · Express · TypeScript'),
              const _Divider(),
              _StackRow(label: 'Version',   value: '1.0.0+1'),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Small components ───────────────────────────────────────────────
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

class _HintRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _HintRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 12, color: AuraColors.textMuted),
          const SizedBox(width: 8),
          Text(label,
              style: AuraText.label(
                  size: 10, color: AuraColors.textMuted)),
          const Spacer(),
          Text(value,
              style: AuraText.mono(
                  size: 10, color: AuraColors.textSecondary)),
        ],
      );
}

class _StackRow extends StatelessWidget {
  final String label;
  final String value;
  const _StackRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AuraText.body(
                    size: 13, color: AuraColors.textMuted)),
            Flexible(
              child: Text(value,
                  style: AuraText.mono(
                      size: 11, color: AuraColors.textSecondary),
                  textAlign: TextAlign.right),
            ),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AuraColors.border);
}
