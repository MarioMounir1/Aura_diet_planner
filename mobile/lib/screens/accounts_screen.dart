// ============================================================
//  lib/screens/accounts_screen.dart
//  Aura Diet Planner — Account Dashboard
//  Shows user profile, stats, and sign-out
// ============================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (_, __) {
        final user = AuthService.instance.user;

        // Not logged in — shouldn't normally happen (handled in main)
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AuraColors.orange),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),

            // ── Profile card ──────────────────────────────────
            _ProfileCard(user: user),
            const SizedBox(height: 24),

            // ── Account details ───────────────────────────────
            _SectionLabel('ACCOUNT DETAILS'),
            const SizedBox(height: 10),
            _DetailsCard(user: user),
            const SizedBox(height: 24),

            // ── Provider badge ────────────────────────────────
            _SectionLabel('CONNECTED WITH'),
            const SizedBox(height: 10),
            _ProviderCard(provider: user.provider),
            const SizedBox(height: 24),

            // ── Stack info ────────────────────────────────────
            _SectionLabel('SYSTEM STACK'),
            const SizedBox(height: 10),
            _StackCard(),
            const SizedBox(height: 32),

            // ── Sign out ──────────────────────────────────────
            _SignOutButton(),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }
}

// ── Profile hero card ──────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final AuraUser user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AuraGradients.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.orange.withAlpha(60)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          _Avatar(user: user, size: 64),
          const SizedBox(width: 18),
          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AuraColors.orange.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: AuraColors.orange.withAlpha(60)),
                  ),
                  child: Text(
                    'AURA MEMBER',
                    style: AuraText.label(
                        size: 8, color: AuraColors.orange,
                        letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.name,
                  style: AuraText.display(
                      size: 18, weight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: AuraText.body(
                      size: 12, color: AuraColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Account details card ───────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final AuraUser user;
  const _DetailsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: glassCard(radius: 12),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Display Name',
            value: user.name,
          ),
          const Divider(height: 1, color: AuraColors.border),
          _DetailRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          const Divider(height: 1, color: AuraColors.border),
          _DetailRow(
            icon: Icons.fingerprint_rounded,
            label: 'User ID',
            value: user.id.length > 20
                ? '${user.id.substring(0, 18)}...'
                : user.id,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AuraColors.textMuted),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: AuraText.label(
                      size: 9,
                      color: AuraColors.textMuted,
                      letterSpacing: 1.2)),
              const SizedBox(height: 3),
              Text(value,
                  style: AuraText.body(
                      size: 13, color: AuraColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Provider card ──────────────────────────────────────────────────
class _ProviderCard extends StatelessWidget {
  final String provider;
  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final String providerLabel;
    final Widget providerIcon;
    final Color providerBg;

    if (provider == 'google') {
      providerLabel = 'Google';
      providerIcon = const Icon(Icons.g_mobiledata_rounded, color: Color(0xFF4285F4), size: 28);
      providerBg = Colors.white;
    } else if (provider == 'apple') {
      providerLabel = 'Apple';
      providerIcon = const Icon(Icons.apple_rounded, color: Colors.white, size: 22);
      providerBg = Colors.black;
    } else {
      providerLabel = 'Email';
      providerIcon = const Icon(Icons.email_rounded, color: AuraColors.orange, size: 20);
      providerBg = AuraColors.bgCard;
    }

    return Container(
      decoration: glassCard(radius: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: providerBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AuraColors.border),
            ),
            child: Center(
              child: providerIcon,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                providerLabel,
                style: AuraText.body(
                    size: 15, color: AuraColors.textPrimary)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'Account linked and verified',
                style:
                    AuraText.body(size: 11, color: AuraColors.success),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AuraColors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
              border:
                  Border.all(color: AuraColors.success.withAlpha(80)),
            ),
            child: Text(
              'ACTIVE',
              style: AuraText.label(
                  size: 9, color: AuraColors.success,
                  letterSpacing: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ── System stack card ──────────────────────────────────────────────
class _StackCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: glassCard(radius: 12),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: const [
          _StackRow(label: 'Engine',    value: 'Volcanic-Nutrition-Engine v1.0'),
          Divider(height: 1, color: AuraColors.border),
          _StackRow(label: 'Inference', value: 'Local Ollama (llava)'),
          Divider(height: 1, color: AuraColors.border),
          _StackRow(label: 'Database',  value: 'PostgreSQL · Prisma ORM'),
          Divider(height: 1, color: AuraColors.border),
          _StackRow(label: 'Version',   value: '1.0.0+1'),
        ],
      ),
    );
  }
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

// ── Sign out button ────────────────────────────────────────────────
class _SignOutButton extends StatefulWidget {
  @override
  State<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<_SignOutButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              await AuthService.instance.signOut();
              // Home navigates to login automatically via ListenableBuilder
            },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AuraColors.error.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AuraColors.error.withAlpha(80)),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AuraColors.error))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.logout_rounded,
                        color: AuraColors.error, size: 18),
                    const SizedBox(width: 8),
                    Text('Sign Out',
                        style: AuraText.body(
                                size: 15, color: AuraColors.error)
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Avatar widget (network or initials fallback) ───────────────────
class _Avatar extends StatelessWidget {
  final AuraUser user;
  final double size;
  const _Avatar({required this.user, required this.size});

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AuraGradients.brand,
        boxShadow: [
          BoxShadow(
            color: AuraColors.orange.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: photoUrl != null && photoUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                photoUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Initials(user: user, size: size),
              ),
            )
          : _Initials(user: user, size: size),
    );
  }
}

class _Initials extends StatelessWidget {
  final AuraUser user;
  final double size;
  const _Initials({required this.user, required this.size});

  String get _initials {
    final parts = user.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A';
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          _initials,
          style: AuraText.display(
              size: size * 0.36,
              weight: FontWeight.w900,
              color: Colors.black),
        ),
      );
}

// ── Section label ──────────────────────────────────────────────────
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
