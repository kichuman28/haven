import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/extensions.dart';
import '../haven_game.dart';
import '../player.dart';
import 'werewolf_sprite.dart';
import 'dart:math' as math;

class WerewolfEnemy extends PositionComponent with CollisionCallbacks, HasGameRef<HavenGame> {
  static const double werewolfSize = 96.0;  // Match sprite size
  static const double speed = 150.0;  // Faster than Riftlings
  static const double damagePerSecond = 40.0;  // More damage than Riftlings
  static const double health = 3.0;  // Takes 3 hits to defeat
  
  bool isActive = true;
  late Vector2 velocity;
  bool isCollidingWithPlayer = false;
  late final WerewolfSprite _sprite;
  double currentHealth = health;
  
  WerewolfEnemy({required Vector2 position}) : super(
    position: position,
    size: Vector2.all(werewolfSize),
  ) {
    _sprite = WerewolfSprite();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add sprite
    add(_sprite);
    _sprite.position = size / 2;
    
    // Add circular hitbox for collision detection
    add(CircleHitbox()
      ..radius = werewolfSize / 2
      ..position = size / 2
      ..anchor = Anchor.center);
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
    final direction = toPlayer.normalized();
    
    // Update velocity and position
    velocity = direction * speed;
    position += velocity * dt;
    
    // Update sprite direction
    _sprite.updateDirection(velocity);
    
    // Deal damage if colliding with player
    if (isCollidingWithPlayer && !gameRef.isShieldActive) {
      gameRef.healthBar.damage(damagePerSecond * dt);
    }
  }

  void takeDamage() {
    currentHealth -= 1.0;
    if (currentHealth <= 0) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Player) {
      if (gameRef.isShieldActive) {
        // Take damage when hit by shield
        takeDamage();
      } else {
        isCollidingWithPlayer = true;
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    
    if (other is Player) {
      isCollidingWithPlayer = false;
    }
  }
} 