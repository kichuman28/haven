import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../haven_game.dart';
import '../player.dart';
import 'riftling_sprite.dart';

class RiftlingEnemy extends PositionComponent with CollisionCallbacks, HasGameRef<HavenGame> {
  static const double riftlingSize = 32.0;
  static const double speed = 100.0;
  static const double damagePerSecond = 20.0;  // Will deal 20 damage per second
  bool isActive = true;
  late Vector2 velocity;
  bool isCollidingWithPlayer = false;
  late final RiftlingSprite _sprite;
  
  RiftlingEnemy({required Vector2 position}) : super(
    position: position,
    size: Vector2.all(riftlingSize),
    anchor: Anchor.center,
  ) {
    _sprite = RiftlingSprite();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add sprite
    add(_sprite);
    _sprite.position = size / 2;
    
    // Add circular hitbox for collision detection
    add(CircleHitbox()
      ..radius = riftlingSize / 2
      ..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;

    // Move towards player
    final playerPos = gameRef.player.position;
    final direction = playerPos - position;
    if (direction.length > 0) {
      direction.normalize();
      velocity = direction * speed;
      position += velocity * dt;
      _sprite.updateDirection(velocity);  // Update sprite direction
    }

    // Deal continuous damage if touching player without shield
    if (isCollidingWithPlayer && !gameRef.isShieldActive) {
      gameRef.healthBar.damage(damagePerSecond * dt);  // Scale damage by time
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (!isActive) return;

    if (other is Player) {
      if (gameRef.isShieldActive) {
        // If shield is active, destroy the Riftling
        isActive = false;
        removeFromParent();
      } else {
        // Start tracking collision with player
        isCollidingWithPlayer = true;
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    
    if (other is Player) {
      // Stop tracking collision with player
      isCollidingWithPlayer = false;
    }
  }
} 