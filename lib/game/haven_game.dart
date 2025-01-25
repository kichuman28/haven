import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'player.dart';
import 'world_manager.dart';
import 'ui_overlay.dart';
import 'managers/memory_manager.dart';
import 'components/memory_fragment.dart';
import 'components/fragment_progress.dart';
import 'components/ending_sequence.dart';
import 'components/end_screen.dart';
import 'components/notes_menu.dart';
import 'components/health_bar.dart';
import 'components/radiation_zone.dart';
import 'components/riftling_enemy.dart';
import 'components/werewolf_enemy.dart';
import 'dart:math' as math;

class HavenGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  late final Player player;
  late final WorldManager worldManager;
  late final UIOverlay uiOverlay;
  late final MemoryManager memoryManager;
  late final FragmentProgress fragmentProgress;
  late final EndingSequence endingSequence;
  late final EndScreen endScreen;
  late final NotesMenu notesMenu;
  late final HealthBar healthBar;
  
  // World position tracking
  Vector2 worldPosition = Vector2.zero();
  bool isTransitioning = false;
  double transitionAlpha = 0;
  bool fadeIn = false;
  bool isEndingActive = false;
  bool isShieldActive = false;
  
  static const transitionDuration = 0.5; // seconds
  
  @override
  Color backgroundColor() => const Color(0xFF0A0A0A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadGame();
  }

  Future<void> loadGame() async {
    // Initialize managers
    worldManager = WorldManager();
    add(worldManager);
    
    memoryManager = MemoryManager();
    add(memoryManager);
    
    // Add fragment progress indicator
    fragmentProgress = FragmentProgress(memoryManager);
    add(fragmentProgress);
    
    // Initialize ending sequence
    endingSequence = EndingSequence(memoryManager);
    add(endingSequence);
    
    // Initialize end screen
    endScreen = EndScreen();
    add(endScreen);
    
    // Initialize notes menu
    notesMenu = NotesMenu(memoryManager);
    add(notesMenu);
    
    // Initialize health bar
    healthBar = HealthBar();
    add(healthBar);
    
    player = Player()
      ..position = Vector2(
        size.x / 2,
        size.y / 2,
      );
    add(player);

    // Initialize UI overlay
    uiOverlay = UIOverlay(worldPosition);
    add(uiOverlay);
    uiOverlay.addDiscoveredScreen(worldPosition);

    // Add radiation zones based on current screen
    if (worldPosition.x == 2 && worldPosition.y == 1) {
      add(RadiationZone(bounds: Rect.fromLTWH(150, 150, 100, 100)));
    } else if (worldPosition.x == 2 && worldPosition.y == 3) {
      add(RadiationZone(bounds: Rect.fromLTWH(250, 250, 100, 100)));
    } else if (worldPosition.x == 1 && worldPosition.y == 1) {
      add(RadiationZone(bounds: Rect.fromLTWH(150, 350, 100, 100)));
    }

    // Spawn enemies for the current screen
    spawnEnemiesForScreen();

    // Spawn initial fragments
    memoryManager.spawnFragmentsForScreen('${worldPosition.x},${worldPosition.y}');
  }

  void resetGame() {
    // Reset game state
    isTransitioning = false;
    isEndingActive = false;
    fadeIn = false;
    transitionAlpha = 0;
    worldPosition = Vector2.zero();
    
    // Reset memory manager state
    memoryManager.reset();
    
    // Remove temporary components
    children.whereType<RadiationZone>().forEach((component) => component.removeFromParent());
    children.whereType<MemoryFragment>().forEach((component) => component.removeFromParent());
    children.whereType<RiftlingEnemy>().forEach((component) => component.removeFromParent());
    children.whereType<WerewolfEnemy>().forEach((component) => component.removeFromParent());
    
    // Reset player position
    player.position = Vector2(size.x / 2, size.y / 2);
    player.stopMovement();
    
    // Reset health
    healthBar.resetHealth();
    
    // Reset end screen
    endScreen.hide();
    
    // Add radiation zones based on current screen
    if (worldPosition.x == 2 && worldPosition.y == 1) {
      add(RadiationZone(bounds: Rect.fromLTWH(150, 150, 100, 100)));
    } else if (worldPosition.x == 2 && worldPosition.y == 3) {
      add(RadiationZone(bounds: Rect.fromLTWH(250, 250, 100, 100)));
    } else if (worldPosition.x == 1 && worldPosition.y == 1) {
      add(RadiationZone(bounds: Rect.fromLTWH(150, 350, 100, 100)));
    }

    // Spawn enemies for the new screen
    spawnEnemiesForScreen();
    
    // Spawn initial fragments
    memoryManager.spawnFragmentsForScreen('${worldPosition.x},${worldPosition.y}');
  }

  void spawnEnemiesForScreen() {
    // Remove any existing enemies
    children.whereType<RiftlingEnemy>().forEach((enemy) => enemy.removeFromParent());
    children.whereType<WerewolfEnemy>().forEach((enemy) => enemy.removeFromParent());

    // Check if this is a radiation zone screen
    bool isRadiationScreen = (worldPosition.x == 2 && worldPosition.y == 1) ||  // Fragment #2
                            (worldPosition.x == 2 && worldPosition.y == 3) ||  // Fragment #4
                            (worldPosition.x == 1 && worldPosition.y == 1);    // Fragment #6

    final random = math.Random();
    
    if (isRadiationScreen) {
      // Spawn Riftlings in radiation zones
      for (int i = 0; i < 3; i++) {
        final riftling = RiftlingEnemy(
          position: Vector2(
            50 + random.nextDouble() * (size.x - 100),
            50 + random.nextDouble() * (size.y - 100),
          ),
        );
        add(riftling);
      }
    } else if (!isRadiationScreen && worldPosition != Vector2(2, 4) && worldPosition != Vector2.zero()) {  // Don't spawn in ending room or starting screen
      // Spawn Werewolves in non-radiation zones
      for (int i = 0; i < 2; i++) {  // Spawn fewer werewolves as they're tougher
        final werewolf = WerewolfEnemy(
          position: Vector2(
            50 + random.nextDouble() * (size.x - 100),
            50 + random.nextDouble() * (size.y - 100),
          ),
        );
        add(werewolf);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isEndingActive) {
      if (!endingSequence.isActive && !endScreen.isVisible) {
        endScreen.show();
      }
      return;
    }
    
    // Check for player death
    if (healthBar.isDead && !endScreen.isVisible) {
      isEndingActive = true;
      player.stopMovement();
      endScreen.show();
      return;
    }
    
    if (!isTransitioning) {
      // Check if player has reached the end point with all fragments
      if (worldPosition.x == 2 && worldPosition.y == 4 && 
          memoryManager.hasCollectedAllFragments) {
        _startEndingSequence();
        return;
      }

      // Check for fragment collection
      final fragments = children.whereType<MemoryFragment>();
      for (final fragment in fragments) {
        if (!fragment.isCollected && 
            player.position.distanceTo(fragment.position) < 30) {
          memoryManager.collectFragment(fragment);
        }
      }

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
          // Spawn fragments for new screen only after transition is complete
          memoryManager.spawnFragmentsForScreen('${worldPosition.x},${worldPosition.y}');
        }
      }
    }
  }

  void _startEndingSequence() {
    isEndingActive = true;
    player.stopMovement();
    endingSequence.start();
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Update shield state for both key down and up events
    isShieldActive = keysPressed.contains(LogicalKeyboardKey.space);

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyN) {
        notesMenu.toggleVisibility();
        return KeyEventResult.handled;
      }
      
      // If notes menu is visible, let it handle keyboard events first
      if (notesMenu.isVisible) {
        if (notesMenu.onKeyEvent(event, keysPressed)) {
          return KeyEventResult.handled;
        }
      }
      
      if (event.logicalKey == LogicalKeyboardKey.space && 
          memoryManager.activeDialog != null) {
        memoryManager.hideDialog();
        return KeyEventResult.handled;
      }
    }
    
    // Only allow player movement if notes menu is not visible
    if (!isTransitioning && !isEndingActive && !notesMenu.isVisible) {
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
    player.stopMovement();
    
    // Remove all existing fragments before transition
    final existingFragments = children.whereType<MemoryFragment>().toList();
    for (final fragment in existingFragments) {
      fragment.removeFromParent();
    }
    
    // Remove existing radiation zones and Riftlings
    children.whereType<RadiationZone>().forEach((zone) => zone.removeFromParent());
    children.whereType<RiftlingEnemy>().forEach((enemy) => enemy.removeFromParent());
    children.whereType<WerewolfEnemy>().forEach((enemy) => enemy.removeFromParent());
    
    // Update world position based on direction
    worldPosition = nextPosition;
    worldManager.moveToScreen(worldPosition);
    uiOverlay.updatePosition(worldPosition);
    uiOverlay.addDiscoveredScreen(worldPosition);

    // Add radiation zones based on current screen
    if (worldPosition.x == 2 && worldPosition.y == 1) {
      add(RadiationZone(bounds: Rect.fromLTWH(150, 150, 100, 100)));
    } else if (worldPosition.x == 2 && worldPosition.y == 3) {
      add(RadiationZone(bounds: Rect.fromLTWH(250, 250, 100, 100)));
    } else if (worldPosition.x == 1 && worldPosition.y == 1) {
      add(RadiationZone(bounds: Rect.fromLTWH(150, 350, 100, 100)));
    }

    // Spawn enemies for the new screen
    spawnEnemiesForScreen();
  }

  void resetPlayerPosition(Vector2 newPosition) {
    player.position = newPosition;
    player.stopMovement();
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
} 