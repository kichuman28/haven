import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../haven_game.dart';
import '../player.dart';

class HealthOrb extends PositionComponent with CollisionCallbacks, HasGameRef<HavenGame> {
  static const double orbSize = 30.0;
  static const double healAmount = 50.0; // Amount of health to restore
  bool isCollected = false;
  double glowIntensity = 0.0;
  bool glowIncreasing = true;
  static const double glowSpeed = 2.0;
  static const double maxGlowIntensity = 0.6;

  HealthOrb({required Vector2 position}) : super(
    position: position,
    size: Vector2.all(orbSize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox()
      ..radius = orbSize / 2
      ..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Update glow effect
    if (glowIncreasing) {
      glowIntensity += dt * glowSpeed;
      if (glowIntensity >= maxGlowIntensity) {
        glowIntensity = maxGlowIntensity;
        glowIncreasing = false;
      }
    } else {
      glowIntensity -= dt * glowSpeed;
      if (glowIntensity <= 0) {
        glowIntensity = 0;
        glowIncreasing = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw glow effect
    canvas.drawCircle(
      Offset.zero,
      orbSize / 1.5,
      Paint()
        ..color = Colors.green.withOpacity(glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );

    // Draw orb
    canvas.drawCircle(
      Offset.zero,
      orbSize / 2,
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill,
    );

    // Draw inner highlight
    canvas.drawCircle(
      const Offset(-5, -5),
      orbSize / 6,
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (!isCollected && other is Player && !gameRef.healthBar.isFullHealth) {
      // Heal the player
      gameRef.healthBar.heal(healAmount);
      isCollected = true;
      removeFromParent();
    }
  }
} 