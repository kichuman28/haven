import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MemoryDialog extends Component with HasGameRef {
  final String message;
  final String sender;
  bool isVisible = true;
  double opacity = 0.0;
  double _time = 0.0;
  static const double fadeSpeed = 2.0;

  MemoryDialog({
    required this.message,
    required this.sender,
  });

  @override
  void update(double dt) {
    if (isVisible && opacity < 1.0) {
      opacity = (opacity + dt * fadeSpeed).clamp(0.0, 1.0);
    } else if (!isVisible && opacity > 0.0) {
      opacity = (opacity - dt * fadeSpeed).clamp(0.0, 1.0);
    }
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0) return;

    final recorder = ui.PictureRecorder();
    final Canvas recordingCanvas = Canvas(recorder);
    final size = gameRef.size;

    // Draw semi-transparent background
    recordingCanvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.black.withOpacity(0.7 * opacity),
    );

    // Calculate dialog size based on content
    final dialogWidth = size.x * 0.7;
    
    // Pre-calculate text height
    final messageTextPainter = TextPainter(
      text: TextSpan(
        text: message,
        style: TextStyle(
          color: Colors.white.withOpacity(opacity),
          fontSize: 18,
          height: 1.5,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: null,
      textAlign: TextAlign.left,
    );
    messageTextPainter.layout(maxWidth: dialogWidth - 40);
    
    // Calculate total height needed
    final dialogHeight = messageTextPainter.height + 120; // Extra space for sender and continue text
    
    final dialogX = (size.x - dialogWidth) / 2;
    final dialogY = (size.y - dialogHeight) / 2;

    // Draw glow effect
    final glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    
    recordingCanvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(dialogX - 10, dialogY - 10, dialogWidth + 20, dialogHeight + 20),
        const Radius.circular(20),
      ),
      glowPaint,
    );

    // Draw main dialog box
    final boxPaint = Paint()
      ..color = const Color(0xFF1A1A1A).withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = Colors.blue[700]!.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dialogRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(dialogX, dialogY, dialogWidth, dialogHeight),
      const Radius.circular(15),
    );

    recordingCanvas.drawRRect(dialogRect, boxPaint);
    recordingCanvas.drawRRect(dialogRect, borderPaint);

    // Draw sender text
    final senderTextPainter = TextPainter(
      text: TextSpan(
        text: sender,
        style: TextStyle(
          color: Colors.blue[400]!.withOpacity(opacity),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    senderTextPainter.layout();
    senderTextPainter.paint(
      recordingCanvas,
      Offset(dialogX + 20, dialogY + 20),
    );

    // Draw message text (reuse the pre-calculated painter)
    messageTextPainter.paint(
      recordingCanvas,
      Offset(dialogX + 20, dialogY + 60),
    );

    // Draw "Click to continue" text with blinking effect
    final blinkValue = ((_time * 2) % 1.0);
    final continueTextPainter = TextPainter(
      text: TextSpan(
        text: 'Press SPACE to continue...',
        style: TextStyle(
          color: Colors.blue[300]!.withOpacity(opacity * blinkValue),
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    continueTextPainter.layout();
    continueTextPainter.paint(
      recordingCanvas,
      Offset(
        dialogX + dialogWidth - continueTextPainter.width - 20,
        dialogY + dialogHeight - continueTextPainter.height - 20,
      ),
    );

    final picture = recorder.endRecording();
    canvas.drawPicture(picture);
  }
} 