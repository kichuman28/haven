import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'player.dart';
import 'environment.dart';

class HavenGame extends FlameGame with KeyboardEvents {
  late final Player player;
  late final PostApocalypticEnvironment environment;

  @override
  Color backgroundColor() => const Color(0xFF0A0A0A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    environment = PostApocalypticEnvironment();
    add(environment);
    
    player = Player()
      ..position = Vector2(
        size.x / 2,
        size.y / 2,
      );
    
    add(player);
  }
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    player.onKeyEvent(event, keysPressed);
    return KeyEventResult.handled;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Game update logic will go here
  }
} 