// ============================================================
//  lib/widgets/shimmer_box.dart
//  Animated shimmer placeholder — Volcanic Cyberpunk skeleton
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Single shimmer block ───────────────────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [
              Color(0xFF161B22),
              Color(0xFF1F2937),
              Color(0xFF2D333B),
              Color(0xFF1F2937),
              Color(0xFF161B22),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Full form skeleton for loading state ───────────────────────────
class GenerateFormSkeleton extends StatelessWidget {
  const GenerateFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero header skeleton
          const ShimmerBox(height: 28, width: 220, radius: 6),
          const SizedBox(height: 8),
          const ShimmerBox(height: 22, width: 160, radius: 6),
          const SizedBox(height: 6),
          const ShimmerBox(height: 22, width: 130, radius: 6),
          const SizedBox(height: 6),
          const ShimmerBox(height: 14, width: 280, radius: 4),
          const SizedBox(height: 28),

          // Section label
          const ShimmerBox(height: 10, width: 100, radius: 4),
          const SizedBox(height: 12),

          // Height + Weight row
          Row(
            children: const [
              Expanded(child: ShimmerBox(height: 72, radius: 10)),
              SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 72, radius: 10)),
            ],
          ),
          const SizedBox(height: 12),

          // Training focus card
          const ShimmerBox(height: 68, radius: 10),
          const SizedBox(height: 24),

          // Plan type label
          const ShimmerBox(height: 10, width: 80, radius: 4),
          const SizedBox(height: 10),

          // Plan type chips
          Row(
            children: List.generate(
              4,
              (i) => Padding(
                padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                child: ShimmerBox(
                    width: 80 + i * 10.0, height: 34, radius: 6),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Goal input label
          const ShimmerBox(height: 10, width: 120, radius: 4),
          const SizedBox(height: 10),

          // Text area
          const ShimmerBox(height: 110, radius: 10),
          const SizedBox(height: 20),

          // Generate button
          const ShimmerBox(height: 52, radius: 10),
          const SizedBox(height: 12),

          // Processing hint
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AuraColors.orange.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AuraColors.orange.withAlpha(40)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AuraColors.orange.withAlpha(180),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Engine is generating your plan...',
                    style: AuraText.label(
                        size: 11, color: AuraColors.orange),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
