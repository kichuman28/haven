import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../haven_game.dart';
import '../player.dart';
import 'projectile.dart';
import 'shooter_sprite.dart';

class RangedEnemy extends PositionComponent with CollisionCallbacks, HasGameRef<HavenGame> {
  static const double enemySize = 40.0;
  static const double speed = 150.0;  // Slower than the player
  static const double preferredDistance = 250.0;  // Distance it tries to maintain from player
  static const double shootingCooldown = 1.0;  // Time between shots
  static const double minDistanceFromWalls = 50.0;  // Minimum distance from screen edges
  
  bool isActive = true;
  double shootingTimer = 0.0;
  Vector2 velocity = Vector2.zero();
  late final ShooterSprite _sprite;
  
  RangedEnemy({required Vector2 position}) : super(
    position: position,
    size: Vector2.all(enemySize),
    anchor: Anchor.center,
  ) {
    _sprite = ShooterSprite();
  }

  @override
  Future<void> onLoad() async {
    add(CircleHitbox()
      ..radius = enemySize / 2
      ..collisionType = CollisionType.passive);

    // Add sprite
    add(_sprite);
    _sprite.position = size / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;
    
    // Don't update if dialog is active
    if (gameRef.memoryManager.activeDialog != null) return;

    // Get direction to player
    final playerPosition = gameRef.player.position + gameRef.player.size / 2;
    final toPlayer = playerPosition - (position + size / 2);
    final distanceToPlayer = toPlayer.length;
    
    // Calculate movement
    if (distanceToPlayer < preferredDistance * 0.8) {
      // Too close, move away from player
      velocity = -toPlayer.normalized() * speed;
    } else if (distanceToPlayer > preferredDistance * 1.2) {
      // Too far, move closer to player
      velocity = toPlayer.normalized() * speed;
    } else {
      // At good distance, move perpendicular to player
      velocity = Vector2(-toPlayer.y, toPlayer.x).normalized() * speed;
    }
    
    // Avoid screen edges
    if (position.x < minDistanceFromWalls) velocity.x += speed;
    if (position.x > gameRef.size.x - minDistanceFromWalls) velocity.x -= speed;
    if (position.y < minDistanceFromWalls) velocity.y += speed;
    if (position.y > gameRef.size.y - minDistanceFromWalls) velocity.y -= speed;
    
    // Apply movement
    position += velocity * dt;
    
    // Update sprite direction
    _sprite.updateDirection(velocity);
    
    // Handle shooting
    shootingTimer -= dt;
    if (shootingTimer <= 0) {
      shoot(toPlayer.normalized());
      shootingTimer = shootingCooldown;
    }
  }

  void shoot(Vector2 direction) {
    final projectile = Projectile(
      position: position + size / 2,
      direction: direction,
    );
    gameRef.add(projectile);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Player && gameRef.isShieldActive) {
      // Destroyed by shield
      isActive = false;
      removeFromParent();
    }
  }
} 