import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'components/player_sprite.dart';

class Player extends PositionComponent with CollisionCallbacks {
  late final PlayerSprite _sprite;
  
  Player() : super(size: Vector2(60, 75), anchor: Anchor.center) {
    _sprite = PlayerSprite();
  }

  // Movement speed in pixels per second
  final double _speed = 300.0;
  final Vector2 _velocity = Vector2.zero();
  bool _hasInput = false;
  
  // Bubble protection mechanics
  static const double maxBubbleDuration = 10.0; // seconds
  static const double bubbleCooldown = 15.0; // seconds
  double _bubbleTimeRemaining = maxBubbleDuration;
  double _cooldownTimeRemaining = 0.0;
  bool _isCoolingDown = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add sprite and center it
    add(_sprite);
    _sprite.position = size / 2;
    
    // Add hitbox for collision detection
    add(CircleHitbox()
      ..radius = 30
      ..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_hasInput) {
      position += _velocity * dt;
      _sprite.updateDirection(_velocity);
    }

    // Update bubble protection timer only when shield is active (space held)
    if (isShieldActive && !_isCoolingDown && _bubbleTimeRemaining > 0) {
      _bubbleTimeRemaining -= dt;
      if (_bubbleTimeRemaining <= 0) {
        _bubbleTimeRemaining = 0;
        _isCoolingDown = true;
        _cooldownTimeRemaining = bubbleCooldown;
      }
    }

    // Update cooldown timer
    if (_isCoolingDown) {
      _cooldownTimeRemaining -= dt;
      if (_cooldownTimeRemaining <= 0) {
        _isCoolingDown = false;
        _bubbleTimeRemaining = maxBubbleDuration;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    
    // Draw shield if active
    if (isShieldActive && !_isCoolingDown && _bubbleTimeRemaining > 0) {
      final Paint shieldPaint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.x/2, size.y/2), 45, shieldPaint);
      
      final Paint shieldBorderPaint = Paint()
        ..color = Colors.blue.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(size.x/2, size.y/2), 45, shieldBorderPaint);
    }

    // Always draw the bubble timer when there's time remaining
    if (_bubbleTimeRemaining > 0) {
      final Paint timerPaint = Paint()
        ..color = (isShieldActive && !_isCoolingDown) ? Colors.blue : Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      final double timerAngle = (_bubbleTimeRemaining / maxBubbleDuration) * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.x/2, size.y/2), radius: 50),
        -1.57079633, // Start from top (-90 degrees)
        timerAngle,
        false,
        timerPaint,
      );
    }

    // Draw cooldown indicator if cooling down
    if (_isCoolingDown) {
      final Paint cooldownPaint = Paint()
        ..color = Colors.red.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      final double cooldownAngle = (_cooldownTimeRemaining / bubbleCooldown) * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.x/2, size.y/2), radius: 55),
        -1.57079633,
        cooldownAngle,
        false,
        cooldownPaint,
      );
    }
    
    canvas.restore();
  }

  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _velocity.setZero();
    _hasInput = false;

    // Handle movement based on pressed keys
    if (keysPressed.contains(LogicalKeyboardKey.keyW) || 
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      _velocity.y = -_speed;
      _hasInput = true;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) || 
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      _velocity.y = _speed;
      _hasInput = true;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA) || 
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _velocity.x = -_speed;
      _hasInput = true;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) || 
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _velocity.x = _speed;
      _hasInput = true;
    }

    // Normalize diagonal movement
    if (_hasInput && _velocity.length > _speed) {
      _velocity.normalize();
      _velocity.scale(_speed);
    }

    return true;
  }

  void stopMovement() {
    _velocity.setZero();
    _hasInput = false;
  }

  // Check if shield is currently active (space held and has time remaining)
  bool get isShieldActive => 
    parent != null && 
    (parent as dynamic).isShieldActive && 
    !_isCoolingDown && 
    _bubbleTimeRemaining > 0;
} 