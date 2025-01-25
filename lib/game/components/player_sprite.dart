import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../haven_game.dart';

class PlayerSprite extends SpriteAnimationComponent with HasGameRef<HavenGame> {
  static const double _animationSpeed = 0.1;
  late final SpriteAnimation walkingAnimation;
  bool isFacingLeft = false;

  PlayerSprite() : super(
    size: Vector2(48, 48),  // Increased from 32x32 to 48x48
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.images.load('walk.png');
    final spriteSize = Vector2(32, 32);  // Each frame is 32x32

    walkingAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 6,         // 6 frames
        stepTime: _animationSpeed,
        textureSize: spriteSize,
      ),
    );

    playing = true;
    animation = walkingAnimation;
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