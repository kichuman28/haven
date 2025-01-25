import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../haven_game.dart';
import '../player.dart';

class TutorialHint extends PositionComponent with CollisionCallbacks, HasGameRef<HavenGame> {
  static const double objectSize = 32.0;
  bool isShowingInstructions = false;
  
  static const List<String> instructions = [
    "Welcome to Haven!",
    "Use WASD or Arrow Keys to move",
    "Hold SPACE to activate your shield bubble",
    "The shield protects you from radiation and enemies",
    "Collect memory fragments to uncover the truth",
    "Press N to view collected memories",
    "Watch your health bar - radiation and enemies can harm you",
    "Good luck on your journey!"
  ];

  TutorialHint({required Vector2 position}) : super(
    position: position,
    size: Vector2.all(objectSize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox()
      ..radius = objectSize / 2
      ..collisionType = CollisionType.passive);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw a glowing question mark
    final Paint glow = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(
      Offset.zero,
      objectSize / 2,
      glow,
    );

    // Draw the main circle
    canvas.drawCircle(
      Offset.zero,
      objectSize / 2,
      Paint()..color = Colors.blue.withOpacity(0.7),
    );

    // Draw the question mark
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
    
    final textSpan = TextSpan(
      text: "?",
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  void showInstructions() {
    if (!isShowingInstructions) {
      isShowingInstructions = true;
      gameRef.showTutorialInstructions(instructions);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Player) {
      showInstructions();
    }
  }

  @override
  void onCollisionEnd(
    PositionComponent other,
  ) {
    super.onCollisionEnd(other);
    
    if (other is Player) {
      isShowingInstructions = false;  // Reset when player moves away
    }
  }
} 