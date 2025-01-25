import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../haven_game.dart';

class RiftlingSprite extends SpriteAnimationComponent with HasGameRef<HavenGame> {
  static const double _animationSpeed = 0.1;
  late final SpriteAnimation walkingAnimation;
  bool isFacingLeft = false;

  RiftlingSprite() : super(
    size: Vector2(32, 32),  // Set initial size based on your sprite sheet
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.images.load('riftling.png');  // Your riftling spritesheet
    final spriteSize = Vector2(32, 32);  // Adjust based on your sprite frame size

    walkingAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 6,         // Adjust based on number of frames in your spritesheet
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