import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../haven_game.dart';

class EndScreen extends Component with HasGameRef<HavenGame>, TapCallbacks {
  bool isVisible = false;
  double alpha = 0;
  static const double fadeInDuration = 2.0;
  double elapsedTime = 0;

  void show() {
    isVisible = true;
    elapsedTime = 0;
    alpha = 0;
  }

  @override
  void update(double dt) {
    if (!isVisible) return;

    if (elapsedTime < fadeInDuration) {
      elapsedTime += dt;
      alpha = (elapsedTime / fadeInDuration).clamp(0, 1);
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (!isVisible || alpha < 1) return true;

    final buttonRect = _getPlayAgainButtonRect();
    if (buttonRect.contains(event.canvasPosition.toOffset())) {
      gameRef.resetGame();
    }
    return true;
  }

  Rect _getPlayAgainButtonRect() {
    final buttonWidth = gameRef.size.x * 0.3;
    final buttonHeight = 50.0;
    return Rect.fromCenter(
      center: Offset(
        gameRef.size.x / 2,
        gameRef.size.y * 0.7,
      ),
      width: buttonWidth,
      height: buttonHeight,
    );
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;

    // Draw dark overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
      Paint()..color = Colors.black.withOpacity(0.9 * alpha),
    );

    // Draw title
    final titleStyle = TextStyle(
      color: Colors.white.withOpacity(alpha),
      fontSize: 64,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.blue.withOpacity(0.5),
          blurRadius: 20,
        ),
      ],
    );

    final titlePainter = TextPainter(
      text: TextSpan(text: 'GAME OVER', style: titleStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(
        (gameRef.size.x - titlePainter.width) / 2,
        gameRef.size.y * 0.3,
      ),
    );

    // Draw subtitle
    final subtitleStyle = TextStyle(
      color: Colors.white.withOpacity(alpha * 0.7),
      fontSize: 24,
      fontWeight: FontWeight.w300,
    );

    final subtitlePainter = TextPainter(
      text: TextSpan(
        text: 'The story continues...',
        style: subtitleStyle,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    subtitlePainter.layout();
    subtitlePainter.paint(
      canvas,
      Offset(
        (gameRef.size.x - subtitlePainter.width) / 2,
        gameRef.size.y * 0.45,
      ),
    );

    // Draw play again button
    final buttonRect = _getPlayAgainButtonRect();
    final buttonRRect = RRect.fromRectAndRadius(
      buttonRect,
      const Radius.circular(25),
    );

    // Button glow
    canvas.drawRRect(
      buttonRRect.inflate(4),
      Paint()
        ..color = Colors.blue.withOpacity(0.3 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
    );

    // Button background
    canvas.drawRRect(
      buttonRRect,
      Paint()
        ..color = Colors.blue.withOpacity(0.2 * alpha)
        ..style = PaintingStyle.fill,
    );

    // Button border
    canvas.drawRRect(
      buttonRRect,
      Paint()
        ..color = Colors.blue.withOpacity(0.8 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Button text
    final buttonStyle = TextStyle(
      color: Colors.white.withOpacity(alpha),
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    final buttonTextPainter = TextPainter(
      text: TextSpan(text: 'PLAY AGAIN', style: buttonStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    buttonTextPainter.layout();
    buttonTextPainter.paint(
      canvas,
      Offset(
        buttonRect.center.dx - buttonTextPainter.width / 2,
        buttonRect.center.dy - buttonTextPainter.height / 2,
      ),
    );
  }
} 