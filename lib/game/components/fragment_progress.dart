import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../managers/memory_manager.dart';

class FragmentProgress extends Component with HasGameRef {
  final MemoryManager memoryManager;
  static const double orbSize = 30.0;
  static const double spacing = 10.0;
  static const double topMargin = 20.0;

  FragmentProgress(this.memoryManager);

  @override
  void render(Canvas canvas) {
    final totalOrbs = memoryManager.totalFragments;
    final collected = memoryManager.collectedFragments;
    
    // Calculate starting position to center the orbs
    final totalWidth = (orbSize * totalOrbs) + (spacing * (totalOrbs - 1));
    final startX = (gameRef.size.x - totalWidth) / 2;

    for (int i = 0; i < totalOrbs; i++) {
      final orbX = startX + (i * (orbSize + spacing));
      final isCollected = collected.contains(i + 1);
      
      // Draw outer circle (border)
      canvas.drawCircle(
        Offset(orbX + orbSize/2, topMargin + orbSize/2),
        orbSize/2,
        Paint()
          ..color = isCollected ? Colors.amber : Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Draw number
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: isCollected ? Colors.amber : Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          orbX + (orbSize - textPainter.width) / 2,
          topMargin + (orbSize - textPainter.height) / 2,
        ),
      );

      // Draw glow for collected orbs
      if (isCollected) {
        canvas.drawCircle(
          Offset(orbX + orbSize/2, topMargin + orbSize/2),
          orbSize/2,
          Paint()
            ..color = Colors.amber.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
    }
  }
} 