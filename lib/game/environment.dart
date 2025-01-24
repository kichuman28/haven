import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PostApocalypticEnvironment extends Component with HasGameRef {
  late final List<Rect> debris;
  late final List<Vector2> dustParticles;
  final Random random = Random();
  final Paint groundPaint = Paint()..color = const Color(0xFF1A1A1A);
  final Paint debrisPaint = Paint()..color = const Color(0xFF2D2D2D);
  final Paint crackPaint = Paint()
    ..color = const Color(0xFF3D3D3D)
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;
  final Paint particlePaint = Paint()..color = const Color(0x33666666);

  @override
  Future<void> onLoad() async {
    debris = List.generate(50, (index) {
      final size = random.nextDouble() * 30 + 10;
      return Rect.fromLTWH(
        random.nextDouble() * gameRef.size.x,
        random.nextDouble() * gameRef.size.y,
        size,
        size,
      );
    });

    dustParticles = List.generate(100, (index) => Vector2(
      random.nextDouble() * gameRef.size.x,
      random.nextDouble() * gameRef.size.y,
    ));
  }

  void _drawGround(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
      groundPaint,
    );
  }

  void _drawDebris(Canvas canvas) {
    for (final rect in debris) {
      canvas.drawRect(rect, debrisPaint);
    }
  }

  void _drawCracks(Canvas canvas) {
    final path = Path();
    for (int i = 0; i < 20; i++) {
      final startX = random.nextDouble() * gameRef.size.x;
      final startY = random.nextDouble() * gameRef.size.y;
      path.moveTo(startX, startY);
      
      for (int j = 0; j < 3; j++) {
        path.lineTo(
          startX + (random.nextDouble() - 0.5) * 100,
          startY + (random.nextDouble() - 0.5) * 100,
        );
      }
    }
    canvas.drawPath(path, crackPaint);
  }

  void _drawDustParticles(Canvas canvas) {
    for (final particle in dustParticles) {
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        1.5,
        particlePaint,
      );
      
      // Move particles
      particle.x += (random.nextDouble() - 0.5) * 2;
      particle.y += (random.nextDouble() - 0.5) * 2;
      
      // Wrap around screen
      if (particle.x < 0) particle.x = gameRef.size.x;
      if (particle.x > gameRef.size.x) particle.x = 0;
      if (particle.y < 0) particle.y = gameRef.size.y;
      if (particle.y > gameRef.size.y) particle.y = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    _drawGround(canvas);
    _drawCracks(canvas);
    _drawDebris(canvas);
    _drawDustParticles(canvas);
  }
} 