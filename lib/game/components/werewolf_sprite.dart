import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../haven_game.dart';

class WerewolfSprite extends SpriteAnimationComponent with HasGameRef<HavenGame> {
  static const double _animationSpeed = 0.08;  // Faster animation for more aggressive feel
  late final SpriteAnimation runningAnimation;
  bool isFacingLeft = false;

  WerewolfSprite() : super(
    size: Vector2(96, 76),  // Each frame is 96x76 (576/6 = 96 width)
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.images.load('werewolf.png');
    final spriteSize = Vector2(96, 76);  // Original frame size

    runningAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 6,         // 6 frames
        stepTime: _animationSpeed,
        textureSize: spriteSize,
      ),
    );

    playing = true;
    animation = runningAnimation;
  }

  void updateDirection(Vector2 velocity) {
    if (velocity.x != 0) {
      // Flip the sprite based on movement direction
      if (velocity.x < 0 && !isFacingLeft) {
        isFacingLeft = true;
        transform.scale.x = -1;
      } else if (velocity.x > 0 && isFacingLeft) {
        isFacingLeft = false;
        transform.scale.x = 1;
      }
    }
  }
} 