import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'player.dart';
import 'world_manager.dart';
import 'ui_overlay.dart';

class HavenGame extends FlameGame with KeyboardEvents {
  late final Player player;
  late final WorldManager worldManager;
  late final UIOverlay uiOverlay;
  
  // World position tracking
  Vector2 worldPosition = Vector2.zero();
  bool isTransitioning = false;
  double transitionAlpha = 0;
  bool fadeIn = false;
  
  static const transitionDuration = 0.5; // seconds
  
  @override
  Color backgroundColor() => const Color(0xFF0A0A0A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    worldManager = WorldManager();
    add(worldManager);
    
    player = Player()
      ..position = Vector2(
        size.x / 2,
        size.y / 2,
      );
    
    add(player);

    // Initialize UI overlay
    uiOverlay = UIOverlay(worldPosition);
    uiOverlay.addDiscoveredScreen(worldPosition); // Add starting screen
    add(uiOverlay);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!isTransitioning) {
      player.onKeyEvent(event, keysPressed);
    }
    return KeyEventResult.handled;
  }

  void startTransition(Vector2 direction) {
    if (isTransitioning) return;
    
    // Check if the next screen would be within bounds
    final nextPosition = worldPosition + direction;
    if (!worldManager.isValidPosition(nextPosition)) {
      // If not valid, just reset player position away from the boundary
      if (player.position.x < 0) {
        player.position.x = 0;
      } else if (player.position.x > size.x) {
        player.position.x = size.x;
      } else if (player.position.y < 0) {
        player.position.y = 0;
      } else if (player.position.y > size.y) {
        player.position.y = size.y;
      }
      player.stopMovement();
      return;
    }
    
    isTransitioning = true;
    fadeIn = true;
    transitionAlpha = 0;
    player.stopMovement(); // Stop player movement during transition
    
    // Update world position based on direction
    worldPosition = nextPosition;
    worldManager.moveToScreen(worldPosition);
    uiOverlay.updatePosition(worldPosition); // Update UI with new position
    uiOverlay.addDiscoveredScreen(worldPosition); // Add new screen to discovered list
  }

  void resetPlayerPosition(Vector2 newPosition) {
    player.position = newPosition;
    player.stopMovement(); // Ensure player stops after repositioning
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw transition overlay
    if (isTransitioning) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.black.withOpacity(transitionAlpha),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isTransitioning) {
      // Check for screen transitions
      if (player.position.x < 0) {
        startTransition(Vector2(-1, 0));
      } else if (player.position.x > size.x) {
        startTransition(Vector2(1, 0));
      } else if (player.position.y < 0) {
        startTransition(Vector2(0, -1));
      } else if (player.position.y > size.y) {
        startTransition(Vector2(0, 1));
      }
    } else {
      // Handle transition animation
      if (fadeIn) {
        transitionAlpha += dt / transitionDuration;
        if (transitionAlpha >= 1) {
          transitionAlpha = 1;
          fadeIn = false;
          
          // Reset player position based on transition direction
          if (player.position.x < 0) {
            resetPlayerPosition(Vector2(size.x - 50, player.position.y));
          } else if (player.position.x > size.x) {
            resetPlayerPosition(Vector2(50, player.position.y));
          } else if (player.position.y < 0) {
            resetPlayerPosition(Vector2(player.position.x, size.y - 50));
          } else if (player.position.y > size.y) {
            resetPlayerPosition(Vector2(player.position.x, 50));
          }
        }
      } else {
        transitionAlpha -= dt / transitionDuration;
        if (transitionAlpha <= 0) {
          transitionAlpha = 0;
          isTransitioning = false;
        }
      }
    }
  }
} 