import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../haven_game.dart';

class ShooterSprite extends SpriteAnimationComponent with HasGameRef<HavenGame> {
  static const double _animationSpeed = 0.1;
  late final SpriteAnimation shootingAnimation;
  bool isFacingLeft = false;

  ShooterSprite() : super(
    size: Vector2(40, 40),  // Match the enemy size
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    final spriteSheet = await gameRef.images.load('shooter.png');
    final spriteSize = Vector2(spriteSheet.width.toDouble() / 6, spriteSheet.height.toDouble());  // 6 frames

    shootingAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 6,         // 6 frames
        stepTime: _animationSpeed,
        textureSize: spriteSize,
      ),
    );

    playing = true;
    animation = shootingAnimation;
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