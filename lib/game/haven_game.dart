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
import 'components/ranged_enemy.dart';
import 'components/tutorial_hint.dart';
import 'components/memory_dialog.dart';
import 'components/health_orb.dart';
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

    // Add tutorial hint in starting screen
    if (worldPosition == Vector2.zero()) {
      final random = math.Random();
      final hintPosition = Vector2(
        100 + random.nextDouble() * (size.x - 200),
        100 + random.nextDouble() * (size.y - 200),
      );
      add(TutorialHint(position: hintPosition));
    }

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

    // Spawn health orb for the current screen
    spawnHealthOrbForScreen();
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
    children.whereType<RangedEnemy>().forEach((component) => component.removeFromParent());
    children.whereType<HealthOrb>().forEach((component) => component.removeFromParent());
    
    // Reset player position
    player.position = Vector2(size.x / 2, size.y / 2);
    player.stopMovement();
    
    // Reset health
    healthBar.resetHealth();
    
    // Reset end screen
    endScreen.hide();
    
    // Update UI overlay with new position
    uiOverlay.updatePosition(worldPosition);
    worldManager.moveToScreen(worldPosition);
    
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

    // Spawn health orb for the starting screen
    spawnHealthOrbForScreen();
  }

  void spawnEnemiesForScreen() {
    // Remove any existing enemies
    children.whereType<RiftlingEnemy>().forEach((enemy) => enemy.removeFromParent());
    children.whereType<WerewolfEnemy>().forEach((enemy) => enemy.removeFromParent());
    children.whereType<RangedEnemy>().forEach((enemy) => enemy.removeFromParent());

    // Check if this is a radiation zone screen
    bool isRadiationScreen = (worldPosition.x == 2 && worldPosition.y == 1) ||  // Fragment #2
                            (worldPosition.x == 2 && worldPosition.y == 3) ||  // Fragment #4
                            (worldPosition.x == 1 && worldPosition.y == 1);    // Fragment #6

    // Check if this is a screen that should have ranged enemies instead of werewolves
    bool isRangedEnemyScreen = (worldPosition.x == 2 && worldPosition.y == 0) ||  // (2,0)
                              (worldPosition.x == 1 && worldPosition.y == 2) ||  // (1,2)
                              (worldPosition.x == 1 && worldPosition.y == 4);    // (1,4)

    // Check if this is a screen that should not have any enemies
    bool isNoEnemyScreen = worldPosition == Vector2(2, 4) ||  // End room
                          worldPosition == Vector2.zero();   // Starting screen

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
    } else if (isRangedEnemyScreen) {
      // Spawn Ranged enemies in specific screens
      for (int i = 0; i < 2; i++) {  // Spawn 2 ranged enemies per screen
        final rangedEnemy = RangedEnemy(
          position: Vector2(
            50 + random.nextDouble() * (size.x - 100),
            50 + random.nextDouble() * (size.y - 100),
          ),
        );
        add(rangedEnemy);
      }
    } else if (!isRadiationScreen && !isRangedEnemyScreen && !isNoEnemyScreen) {  // Only spawn werewolves in remaining screens
      // Spawn Werewolves in remaining screens
      for (int i = 0; i < 2; i++) {
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

  void spawnHealthOrbForScreen() {
    // Remove any existing health orbs
    children.whereType<HealthOrb>().forEach((orb) => orb.removeFromParent());

    // Check if this is a screen that should have a health orb
    bool isHealthOrbScreen = (worldPosition.x == 2 && worldPosition.y == 4) ||  // End room
                            (worldPosition.x == 0 && worldPosition.y == 2) ||  // Starting area
                            (worldPosition.x == 2 && worldPosition.y == 2) ||  // Middle of right section
                            (worldPosition.x == 0 && worldPosition.y == 4) ||  // (0,4)
                            (worldPosition.x == 2 && worldPosition.y == 0) ||  // (2,0)
                            (worldPosition.x == 1 && worldPosition.y == 1) ||  // (1,1)
                            (worldPosition.x == 1 && worldPosition.y == 3) ||  // New: (1,3)
                            (worldPosition.x == 2 && worldPosition.y == 3);    // New: (2,3)

    if (isHealthOrbScreen) {
      final random = math.Random();
      final healthOrb = HealthOrb(
        position: Vector2(
          100 + random.nextDouble() * (size.x - 200),
          100 + random.nextDouble() * (size.y - 200),
        ),
      );
      add(healthOrb);
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
    
    // Remove existing components
    children.whereType<RadiationZone>().forEach((zone) => zone.removeFromParent());
    children.whereType<RiftlingEnemy>().forEach((enemy) => enemy.removeFromParent());
    children.whereType<WerewolfEnemy>().forEach((enemy) => enemy.removeFromParent());
    children.whereType<RangedEnemy>().forEach((enemy) => enemy.removeFromParent());
    children.whereType<TutorialHint>().forEach((hint) => hint.removeFromParent());
    children.whereType<HealthOrb>().forEach((orb) => orb.removeFromParent());
    
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

    // Add tutorial hint if moving back to starting screen
    if (worldPosition == Vector2.zero()) {
      final random = math.Random();
      final hintPosition = Vector2(
        100 + random.nextDouble() * (size.x - 200),
        100 + random.nextDouble() * (size.y - 200),
      );
      add(TutorialHint(position: hintPosition));
    }

    // Spawn enemies for the new screen
    spawnEnemiesForScreen();

    // Spawn health orb for the new screen
    spawnHealthOrbForScreen();
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

  void showTutorialInstructions(List<String> instructions) {
    // Remove any existing dialog
    if (memoryManager.activeDialog != null) {
      memoryManager.hideDialog();
    }
    
    // Format instructions with proper spacing
    final formattedInstructions = instructions.map((instruction) => '  $instruction').join('\n\n');
    
    // Create and show new dialog with proper sizing
    memoryManager.activeDialog = MemoryDialog(
      message: formattedInstructions,
      sender: "Tutorial",
    );
    add(memoryManager.activeDialog!);
  }

  // Add method to show instructions dialog
  void showInstructions(List<String> instructions) {
    // Create a styled text for instructions
    final TextSpan instructionText = TextSpan(
      children: [
        for (var instruction in instructions)
          TextSpan(
            text: "• $instruction\n",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
      ],
    );

    // Create text painter to calculate height
    final textPainter = TextPainter(
      text: instructionText,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    textPainter.layout(maxWidth: size.x * 0.8);

    // Add an overlay component to show the instructions
    final instructionBox = InstructionOverlay(
      size: Vector2(size.x * 0.8, textPainter.height + 40),
      position: Vector2(size.x * 0.1, size.y * 0.1),
      text: instructionText,
    );
    add(instructionBox);
  }
}

class InstructionOverlay extends PositionComponent with KeyboardHandler {
  final TextSpan text;
  bool isVisible = true;

  InstructionOverlay({
    required Vector2 position,
    required Vector2 size,
    required this.text,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;

    // Draw background
    final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(
      bgRect,
      Paint()
        ..color = Colors.black.withOpacity(0.9)
        ..style = PaintingStyle.fill,
    );

    // Draw border
    canvas.drawRect(
      bgRect,
      Paint()
        ..color = Colors.blue.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw text
    final textPainter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    textPainter.layout(maxWidth: size.x - 40);
    textPainter.paint(canvas, Offset(20, 20));

    // Draw "Press SPACE to continue" at the bottom
    final continueText = TextPainter(
      text: const TextSpan(
        text: "Press SPACE to continue",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    continueText.layout();
    continueText.paint(
      canvas,
      Offset(size.x - continueText.width - 20, size.y - continueText.height - 10),
    );
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && 
        event.logicalKey == LogicalKeyboardKey.space && 
        isVisible) {
      removeFromParent();
      return true;
    }
    return false;
  }
} 