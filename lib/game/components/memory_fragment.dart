import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MemoryFragment extends PositionComponent {
  final int fragmentId;
  final String message;
  final String sender;
  bool isCollected = false;
  late final Effect _pulseEffect;
  late final Effect _rotationEffect;

  MemoryFragment({
    required Vector2 position,
    required this.fragmentId,
    required this.message,
    required this.sender,
  }) : super(
    position: position,
    size: Vector2.all(80),
    anchor: Anchor.center,
  ) {
    _pulseEffect = SequenceEffect([
      ScaleEffect.to(
        Vector2.all(1.2),
        EffectController(duration: 1.5),
      ),
      ScaleEffect.to(
        Vector2.all(0.8),
        EffectController(duration: 1.5),
      ),
    ], infinite: true);

    _rotationEffect = RotateEffect.by(
      2 * math.pi,
      EffectController(duration: 8.0, infinite: true),
    );
  }

  @override
  Future<void> onLoad() async {
    add(_pulseEffect);
    add(_rotationEffect);
  }

  @override
  void render(Canvas canvas) {
    final color = isCollected ? Colors.grey : Colors.amber;
    final glowOpacity = isCollected ? 0.15 : 0.3;
    final energyOpacity = isCollected ? 0.4 : 1.0;

    // Draw outer glow
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(glowOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      35,
      glowPaint,
    );

    // Draw main orb
    final Paint orbPaint = Paint()
      ..color = color.withOpacity(energyOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      25,
      orbPaint,
    );

    // Draw inner glow
    final Paint innerGlowPaint = Paint()
      ..color = Colors.white.withOpacity(isCollected ? 0.4 : 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      15,
      innerGlowPaint,
    );

    // Draw energy lines
    final Paint energyPaint = Paint()
      ..color = color.withOpacity(energyOpacity * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw cross pattern
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(angle);
      
      final path = Path()
        ..moveTo(-30, 0)
        ..lineTo(30, 0);
      
      canvas.drawPath(path, energyPaint);
      canvas.restore();
    }

    // Draw number in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: fragmentId.toString(),
        style: TextStyle(
          color: isCollected ? Colors.white.withOpacity(0.5) : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.x / 2 - textPainter.width / 2,
        size.y / 2 - textPainter.height / 2,
      ),
    );
  }
} 