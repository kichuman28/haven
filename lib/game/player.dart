import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent {
  Player() : super(size: Vector2(50, 50));

  // Movement speed in pixels per second
  final double _speed = 300.0;
  final Vector2 _velocity = Vector2.zero();
  bool _hasInput = false;

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
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = Colors.blue,
    );
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

    if (_hasInput && _velocity.length > _speed) {
      _velocity.normalize();
      _velocity.scale(_speed);
    }

    return true;
  }
} 