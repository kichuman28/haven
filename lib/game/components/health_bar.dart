import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../haven_game.dart';

class HealthBar extends Component with HasGameRef<HavenGame> {
  static const double barWidth = 200.0;
  static const double barHeight = 20.0;
  static const double padding = 20.0;
  
  double _health = 100.0;
  double _displayHealth = 100.0; // For smooth animation
  static const double drainRate = 35.0; // Health loss per second in radiation
  
  double get health => _health;
  
  void damage(double amount) {
    _health = (_health - amount).clamp(0.0, 100.0);
  }
  
  void heal(double amount) {
    _health = (_health + amount).clamp(0.0, 100.0);
  }
  
  bool get isDead => _health <= 0;

  @override
  void update(double dt) {
    // Smoothly animate health bar
    if (_displayHealth != _health) {
      final change = dt * 100;
      if (_displayHealth > _health) {
        _displayHealth = (_displayHealth - change).clamp(_health, 100.0);
      } else {
        _displayHealth = (_displayHealth + change).clamp(0.0, _health);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final baseOffset = Vector2(
      gameRef.size.x - barWidth - padding,
      gameRef.size.y - barHeight - padding
    );
    
    // Draw background (dark bar)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          baseOffset.x,
          baseOffset.y,
          barWidth,
          barHeight,
        ),
        const Radius.circular(barHeight / 2),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );

    // Draw health bar background glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          baseOffset.x,
          baseOffset.y,
          barWidth,
          barHeight,
        ),
        const Radius.circular(barHeight / 2),
      ),
      Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Calculate health width
    final healthWidth = (barWidth * _displayHealth / 100).clamp(0.0, barWidth);

    // Draw health bar with gradient
    if (healthWidth > 0) {
      final healthRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          baseOffset.x,
          baseOffset.y,
          healthWidth,
          barHeight,
        ),
        const Radius.circular(barHeight / 2),
      );

      // Draw main health bar
      canvas.drawRRect(
        healthRect,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.red.shade900,
              Colors.red.shade600,
              Colors.red.shade400,
            ],
          ).createShader(healthRect.outerRect),
      );

      // Add inner glow
      canvas.drawRRect(
        healthRect,
        Paint()
          ..color = Colors.red.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 2)
          ..style = PaintingStyle.fill,
      );

      // Add highlight
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            baseOffset.x,
            baseOffset.y,
            healthWidth,
            barHeight / 2,
          ),
          const Radius.circular(barHeight / 2),
        ),
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.fill,
      );
    }

    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          baseOffset.x,
          baseOffset.y,
          barWidth,
          barHeight,
        ),
        const Radius.circular(barHeight / 2),
      ),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
} 