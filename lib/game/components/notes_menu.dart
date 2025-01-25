import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../managers/memory_manager.dart';

class NotesMenu extends Component with HasGameRef, KeyboardHandler {
  final MemoryManager memoryManager;
  bool isVisible = false;
  int? selectedFragmentId;
  int selectedIndex = 0;
  static const double iconSize = 40.0;
  static const double menuPadding = 20.0;
  
  NotesMenu(this.memoryManager);

  void toggleVisibility() {
    isVisible = !isVisible;
    if (!isVisible) {
      selectedFragmentId = null;
      selectedIndex = 0;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!isVisible) return false;

    if (event is KeyDownEvent) {
      final collectedNotes = List.generate(memoryManager.totalFragments, (index) => index + 1)
        .where((id) => memoryManager.hasCollectedFragment(id))
        .toList();

      if (selectedFragmentId == null) {
        // Navigation in the list view
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          selectedIndex = (selectedIndex - 1).clamp(0, collectedNotes.length - 1);
          return true;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          selectedIndex = (selectedIndex + 1).clamp(0, collectedNotes.length - 1);
          return true;
        }
        if (event.logicalKey == LogicalKeyboardKey.enter && collectedNotes.isNotEmpty) {
          selectedFragmentId = collectedNotes[selectedIndex];
          return true;
        }
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          isVisible = false;
          return true;
        }
      } else {
        // In full message view
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          selectedFragmentId = null;
          return true;
        }
      }
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    if (isVisible) {
      // First draw the dark overlay
      canvas.drawRect(
        Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
        Paint()
          ..color = Colors.black.withOpacity(0.95)
          ..blendMode = BlendMode.srcOver,
      );

      // Then draw the menu content on top
      if (selectedFragmentId != null) {
        _drawFullMessage(canvas);
      } else {
        _drawMenu(canvas);
      }
    }

    // Always draw the notes icon last so it's on top
    _drawNotesIcon(canvas);
  }

  void _drawNotesIcon(Canvas canvas) {
    final iconPosition = Offset(
      gameRef.size.x - iconSize - menuPadding,
      menuPadding
    );

    // Draw icon background
    canvas.drawCircle(
      iconPosition.translate(iconSize/2, iconSize/2),
      iconSize/2,
      Paint()
        ..color = Colors.blue.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );

    // Draw icon border
    canvas.drawCircle(
      iconPosition.translate(iconSize/2, iconSize/2),
      iconSize/2,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw 'N' text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      iconPosition.translate(
        (iconSize - textPainter.width) / 2,
        (iconSize - textPainter.height) / 2,
      ),
    );
  }

  void _drawMenu(Canvas canvas) {
    final menuWidth = gameRef.size.x * 0.8;
    final menuHeight = gameRef.size.y * 0.8;
    final menuX = (gameRef.size.x - menuWidth) / 2;
    final menuY = (gameRef.size.y - menuHeight) / 2;

    // Draw menu background with glow
    final menuRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(menuX, menuY, menuWidth, menuHeight),
      const Radius.circular(20),
    );

    // Draw menu glow
    canvas.drawRRect(
      menuRect.inflate(4),
      Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
    );

    // Draw menu background
    canvas.drawRRect(
      menuRect,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.fill,
    );

    // Draw menu border
    canvas.drawRRect(
      menuRect,
      Paint()
        ..color = Colors.blue.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw title
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'COLLECTED MEMORIES',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(
        menuX + (menuWidth - titlePainter.width) / 2,
        menuY + 20,
      ),
    );

    // Draw collected notes
    double yOffset = menuY + 80;
    final collectedNotes = List.generate(memoryManager.totalFragments, (index) => index + 1)
      .where((id) => memoryManager.hasCollectedFragment(id))
      .toList();

    for (var i = 0; i < collectedNotes.length; i++) {
      final fragmentId = collectedNotes[i];
      final fragment = memoryManager.fragmentData.firstWhere((f) => f['id'] == fragmentId);
      final isSelected = i == selectedIndex;

      // Draw note container with highlight if selected
      final noteRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(menuX + 20, yOffset, menuWidth - 40, 100),
        const Radius.circular(10),
      );

      canvas.drawRRect(
        noteRect,
        Paint()
          ..color = isSelected ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );

      if (isSelected) {
        canvas.drawRRect(
          noteRect,
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // Draw note title
      final noteTitlePainter = TextPainter(
        text: TextSpan(
          text: 'Memory Fragment #$fragmentId',
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.7),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      noteTitlePainter.layout();
      noteTitlePainter.paint(
        canvas,
        Offset(menuX + 30, yOffset + 10),
      );

      // Draw sender
      final senderPainter = TextPainter(
        text: TextSpan(
          text: fragment['sender'],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      senderPainter.layout();
      senderPainter.paint(
        canvas,
        Offset(menuX + 30, yOffset + 35),
      );

      // Draw preview of message
      final previewText = fragment['message'].toString().split('\n').first;
      final messagePainter = TextPainter(
        text: TextSpan(
          text: previewText.length > 100 
            ? '${previewText.substring(0, 100)}...' 
            : previewText,
          style: TextStyle(
            color: isSelected ? Colors.white70 : Colors.white54,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      messagePainter.layout(maxWidth: menuWidth - 60);
      messagePainter.paint(
        canvas,
        Offset(menuX + 30, yOffset + 60),
      );

      yOffset += 120;
    }

    // Draw navigation instructions
    final instructionsPainter = TextPainter(
      text: const TextSpan(
        text: '↑↓ Navigate | Enter to Read | Esc to Close',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    instructionsPainter.layout();
    instructionsPainter.paint(
      canvas,
      Offset(
        menuX + (menuWidth - instructionsPainter.width) / 2,
        menuY + menuHeight - 30,
      ),
    );
  }

  void _drawFullMessage(Canvas canvas) {
    final menuWidth = gameRef.size.x * 0.8;
    final menuHeight = gameRef.size.y * 0.8;
    final menuX = (gameRef.size.x - menuWidth) / 2;
    final menuY = (gameRef.size.y - menuHeight) / 2;

    final fragment = memoryManager.fragmentData.firstWhere((f) => f['id'] == selectedFragmentId);

    // Draw menu background with glow
    final menuRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(menuX, menuY, menuWidth, menuHeight),
      const Radius.circular(20),
    );

    // Draw menu glow
    canvas.drawRRect(
      menuRect.inflate(4),
      Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
    );

    // Draw menu background
    canvas.drawRRect(
      menuRect,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.fill,
    );

    // Draw menu border
    canvas.drawRRect(
      menuRect,
      Paint()
        ..color = Colors.blue.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw fragment title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: 'Memory Fragment #${fragment['id']}',
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(menuX + 30, menuY + 20),
    );

    // Draw sender
    final senderPainter = TextPainter(
      text: TextSpan(
        text: fragment['sender'],
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 18,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    senderPainter.layout();
    senderPainter.paint(
      canvas,
      Offset(menuX + 30, menuY + 60),
    );

    // Draw full message
    final messagePainter = TextPainter(
      text: TextSpan(
        text: fragment['message'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    messagePainter.layout(maxWidth: menuWidth - 60);
    messagePainter.paint(
      canvas,
      Offset(menuX + 30, menuY + 100),
    );

    // Draw back instruction
    final backPainter = TextPainter(
      text: const TextSpan(
        text: 'Press Esc to go back',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    backPainter.layout();
    backPainter.paint(
      canvas,
      Offset(
        menuX + (menuWidth - backPainter.width) / 2,
        menuY + menuHeight - 30,
      ),
    );
  }
} 