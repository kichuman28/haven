import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../haven_game.dart';
import '../player.dart';

class Projectile extends PositionComponent with CollisionCallbacks, HasGameRef<HavenGame> {
  static const double projectileSize = 8.0;
  static const double projectileSpeed = 300.0;
  static const double damage = 10.0;
  final Vector2 direction;
  bool isActive = true;

  Projectile({
    required Vector2 position,
    required this.direction,
  }) : super(
    position: position,
    size: Vector2.all(projectileSize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox()
      ..radius = projectileSize / 2
      ..collisionType = CollisionType.passive);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;

    // Move projectile
    position += direction * projectileSpeed * dt;

    // Remove if off screen
    if (position.x < 0 || position.x > gameRef.size.x ||
        position.y < 0 || position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw projectile glow
    canvas.drawCircle(
      Offset.zero,
      projectileSize,
      Paint()
        ..color = Colors.purple.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Draw projectile core
    canvas.drawCircle(
      Offset.zero,
      projectileSize / 2,
      Paint()
        ..color = Colors.purple
        ..style = PaintingStyle.fill,
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Player) {
      if (gameRef.isShieldActive) {
        // Projectile is destroyed by shield
        removeFromParent();
      } else {
        // Deal damage to player and remove projectile
        gameRef.healthBar.damage(damage);
        removeFromParent();
      }
    }
  }
} 