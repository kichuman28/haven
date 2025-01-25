import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent {
  Player() : super(size: Vector2(40, 50));

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
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_hasInput) {
      position += _velocity * dt;
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
    // Save the current canvas state
    canvas.save();
    
    // Move to center of the component
    canvas.translate(size.x / 2, size.y / 2);
    
    // Draw shield if active
    if (isShieldActive && !_isCoolingDown && _bubbleTimeRemaining > 0) {
      final Paint shieldPaint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 30, shieldPaint);
      
      final Paint shieldBorderPaint = Paint()
        ..color = Colors.blue.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset.zero, 30, shieldBorderPaint);
    }

    // Always draw the bubble timer when there's time remaining
    if (_bubbleTimeRemaining > 0) {
      final Paint timerPaint = Paint()
        ..color = (isShieldActive && !_isCoolingDown) ? Colors.blue : Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      final double timerAngle = (_bubbleTimeRemaining / maxBubbleDuration) * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 35),
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
        Rect.fromCircle(center: Offset.zero, radius: 40),
        -1.57079633,
        cooldownAngle,
        false,
        cooldownPaint,
      );
    }
    
    // Draw the head
    final Paint headPaint = Paint()
      ..color = Colors.pink[300]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, -10), 10, headPaint);
    
    // Draw the body
    final Paint bodyPaint = Paint()
      ..color = Colors.blue[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    // Body line
    canvas.drawLine(
      Offset(0, 0),
      Offset(0, 15),
      bodyPaint,
    );
    
    // Arms
    canvas.drawLine(
      Offset(-12, 5),
      Offset(12, 5),
      bodyPaint,
    );
    
    // Legs
    canvas.drawLine(
      Offset(0, 15),
      Offset(-8, 25),
      bodyPaint,
    );
    canvas.drawLine(
      Offset(0, 15),
      Offset(8, 25),
      bodyPaint,
    );
    
    // Restore the canvas state
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