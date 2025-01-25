import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../haven_game.dart';
import '../player.dart';
import 'health_bar.dart';

class RadiationZone extends Component with HasGameRef<HavenGame> {
  final Rect bounds;
  static const double glowIntensity = 0.3;
  static const double pulseSpeed = 2.0;
  double _pulsePhase = 0.0;

  RadiationZone({required this.bounds});

  @override
  void update(double dt) {
    super.update(dt);
    
    // Update pulse animation
    _pulsePhase = (_pulsePhase + dt * pulseSpeed) % (2 * math.pi);
    
    // Check if player is in radiation zone
    final playerBounds = Rect.fromCenter(
      center: gameRef.player.position.toOffset(),
      width: 30,
      height: 30,
    );
    
    if (bounds.overlaps(playerBounds)) {
      // Get the player component
      final player = gameRef.player;
      
      // Only damage if shield is not active or if in cooldown
      if (!player.isShieldActive) {
        gameRef.healthBar.damage(HealthBar.drainRate * dt);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Calculate pulse opacity
    final pulseOpacity = 0.3 + (math.sin(_pulsePhase) + 1) * 0.1;

    // Draw outer glow
    canvas.drawRect(
      bounds.inflate(4),
      Paint()
        ..color = Colors.red.withOpacity(glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
    );

    // Draw main radiation zone
    canvas.drawRect(
      bounds,
      Paint()
        ..color = Colors.red.withOpacity(pulseOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Draw radiation pattern
    final patternPaint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw hazard pattern lines
    const spacing = 20.0;
    for (var x = bounds.left - bounds.width; x < bounds.right + bounds.width; x += spacing) {
      canvas.drawLine(
        Offset(x + (_pulsePhase * 5) % spacing, bounds.top),
        Offset(x + bounds.width + (_pulsePhase * 5) % spacing, bounds.bottom),
        patternPaint,
      );
    }
  }
} 