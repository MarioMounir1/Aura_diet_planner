// ============================================================
//  lib/widgets/macro_ring.dart
//  Circular macro metric ring — CustomPainter with glow arc
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MacroRing extends StatefulWidget {
  final String label;
  final int value;
  /// Total across all macros — used to calculate the arc fill ratio
  final int total;
  final Color color;
  final String unit;

  const MacroRing({
    super.key,
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    this.unit = 'g',
  });

  @override
  State<MacroRing> createState() => _MacroRingState();
}

class _MacroRingState extends State<MacroRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.total > 0
        ? (widget.value / widget.total).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => CustomPaint(
            size: const Size(88, 88),
            painter: _RingPainter(
              progress: ratio * _anim.value,
              color: widget.color,
            ),
            child: SizedBox(
              width: 88,
              height: 88,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.value}',
                      style: AuraText.display(
                        size: 20,
                        weight: FontWeight.w900,
                        color: widget.color,
                      ),
                    ),
                    Text(
                      widget.unit,
                      style: AuraText.label(
                        size: 9,
                        color: widget.color.withAlpha(150),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label.toUpperCase(),
          style: AuraText.label(
            size: 9,
            color: AuraColors.textMuted,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

// ── Ring painter ───────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 9;
    const strokeWidth = 7.5;
    const startAngle = -pi / 2;

    // Track ring (background)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * pi,
      false,
      Paint()
        ..color = color.withAlpha(28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;

    final sweep = 2 * pi * progress;

    // Outer glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      Paint()
        ..color = color.withAlpha(55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Main arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // End cap dot
    final endX =
        center.dx + radius * cos(startAngle + sweep);
    final endY =
        center.dy + radius * sin(startAngle + sweep);
    canvas.drawCircle(
      Offset(endX, endY),
      strokeWidth / 2 - 0.5,
      Paint()..color = Colors.white.withAlpha(220),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Calorie display card ───────────────────────────────────────────
class CalorieDisplay extends StatefulWidget {
  final int calories;

  const CalorieDisplay({super.key, required this.calories});

  @override
  State<CalorieDisplay> createState() => _CalorieDisplayState();
}

class _CalorieDisplayState extends State<CalorieDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<int> _countAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _countAnim = IntTween(begin: 0, end: widget.calories).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _countAnim,
      builder: (_, __) => Column(
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [AuraColors.orange, AuraColors.amber],
            ).createShader(b),
            child: Text(
              '${_countAnim.value}',
              style: AuraText.display(size: 52, weight: FontWeight.w900)
                  .copyWith(color: Colors.white),
            ),
          ),
          Text(
            'KCAL TARGET',
            style: AuraText.label(
                size: 10,
                color: AuraColors.textMuted,
                letterSpacing: 2.5),
          ),
        ],
      ),
    );
  }
}
