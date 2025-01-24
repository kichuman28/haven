import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class UIOverlay extends Component {
  Vector2 worldPosition;
  final Map<String, dynamic> discoveredScreens;
  static const mapSize = 180.0;  // Increased map size
  static const cellSize = 25.0;  // Slightly larger cells
  static const int worldWidth = 3;
  static const int worldHeight = 5;
  
  UIOverlay(this.worldPosition) : discoveredScreens = {};

  void updatePosition(Vector2 newPosition) {
    worldPosition = newPosition;
  }

  void addDiscoveredScreen(Vector2 coordinates) {
    final key = '${coordinates.x},${coordinates.y}';
    discoveredScreens[key] = true;
  }

  @override
  void render(Canvas canvas) {
    _drawCoordinates(canvas);
    _drawMiniMap(canvas);
  }

  void _drawCoordinates(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'World Position: (${worldPosition.x.toInt()}, ${worldPosition.y.toInt()})',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, const Offset(20, 20));
  }

  void _drawMiniMap(Canvas canvas) {
    final mapStartX = 20.0;
    final mapStartY = 50.0;

    // Draw outer border with gradient
    final outerRect = Rect.fromLTWH(
      mapStartX - 5, 
      mapStartY - 5, 
      worldWidth * cellSize + 10, 
      worldHeight * cellSize + 10
    );
    
    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.blue[700]!,
        Colors.blue[300]!,
      ],
    );

    canvas.drawRect(
      outerRect,
      Paint()..shader = borderGradient.createShader(outerRect),
    );

    // Draw map background
    canvas.drawRect(
      Rect.fromLTWH(mapStartX, mapStartY, worldWidth * cellSize, worldHeight * cellSize),
      Paint()
        ..color = Colors.black.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );

    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw vertical grid lines
    for (int x = 0; x <= worldWidth; x++) {
      canvas.drawLine(
        Offset(mapStartX + x * cellSize, mapStartY),
        Offset(mapStartX + x * cellSize, mapStartY + worldHeight * cellSize),
        gridPaint,
      );
    }

    // Draw horizontal grid lines
    for (int y = 0; y <= worldHeight; y++) {
      canvas.drawLine(
        Offset(mapStartX, mapStartY + y * cellSize),
        Offset(mapStartX + worldWidth * cellSize, mapStartY + y * cellSize),
        gridPaint,
      );
    }

    // Draw discovered screens
    final screenPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final currentPaint = Paint()
      ..color = Colors.blue[500]!
      ..style = PaintingStyle.fill;

    // Draw all screens with different colors based on type
    for (int x = 0; x < worldWidth; x++) {
      for (int y = 0; y < worldHeight; y++) {
        final key = '$x,$y';
        final screenRect = Rect.fromLTWH(
          mapStartX + x * cellSize,
          mapStartY + y * cellSize,
          cellSize,
          cellSize,
        );

        // Different colors for different zones
        if (x == 0) {
          // Starting zone - green tint
          canvas.drawRect(
            screenRect,
            Paint()..color = Colors.green.withOpacity(0.2),
          );
        } else if (x == 1) {
          // Danger zone - red tint
          canvas.drawRect(
            screenRect,
            Paint()..color = Colors.red.withOpacity(0.2),
          );
        } else {
          // Final zone - blue tint
          canvas.drawRect(
            screenRect,
            Paint()..color = Colors.blue.withOpacity(0.2),
          );
        }

        // If discovered, make it more visible
        if (discoveredScreens.containsKey(key)) {
          canvas.drawRect(screenRect, screenPaint);
        }
      }
    }

    // Mark start position (0,0)
    final startRect = Rect.fromLTWH(
      mapStartX,
      mapStartY,
      cellSize,
      cellSize,
    );
    
    // Draw start position with arrow indicator
    canvas.drawRect(
      startRect,
      Paint()..color = Colors.green.withOpacity(0.5),
    );
    
    // Draw "S" text for Start
    final startText = TextPainter(
      text: const TextSpan(
        text: 'S',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    startText.layout();
    startText.paint(
      canvas, 
      Offset(
        mapStartX + (cellSize - startText.width) / 2,
        mapStartY + (cellSize - startText.height) / 2,
      ),
    );

    // Mark end position (2,4)
    final endRect = Rect.fromLTWH(
      mapStartX + (worldWidth - 1) * cellSize,
      mapStartY + (worldHeight - 1) * cellSize,
      cellSize,
      cellSize,
    );
    
    // Draw end position with different style
    canvas.drawRect(
      endRect,
      Paint()..color = Colors.red.withOpacity(0.5),
    );
    
    // Draw "E" text for End
    final endText = TextPainter(
      text: const TextSpan(
        text: 'E',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    endText.layout();
    endText.paint(
      canvas, 
      Offset(
        mapStartX + (worldWidth - 1) * cellSize + (cellSize - endText.width) / 2,
        mapStartY + (worldHeight - 1) * cellSize + (cellSize - endText.height) / 2,
      ),
    );

    // Draw current position
    final currentX = mapStartX + worldPosition.x * cellSize;
    final currentY = mapStartY + worldPosition.y * cellSize;
    
    // Draw glowing effect for current position
    final glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(
      Offset(currentX + cellSize / 2, currentY + cellSize / 2),
      cellSize / 2,
      glowPaint,
    );
    
    canvas.drawRect(
      Rect.fromLTWH(currentX, currentY, cellSize, cellSize),
      currentPaint,
    );

    // Draw legend
    _drawMapLegend(canvas, mapStartX, mapStartY + worldHeight * cellSize + 20);
  }

  void _drawMapLegend(Canvas canvas, double x, double y) {
    final legendSpacing = 25.0;
    final iconSize = 15.0;

    // Current Position
    canvas.drawRect(
      Rect.fromLTWH(x, y, iconSize, iconSize),
      Paint()..color = Colors.blue[500]!,
    );
    _drawLegendText(canvas, 'Current Position', x + 20, y);

    // Start Area
    canvas.drawRect(
      Rect.fromLTWH(x, y + legendSpacing, iconSize, iconSize),
      Paint()..color = Colors.green.withOpacity(0.5),
    );
    _drawLegendText(canvas, 'Start (0,0)', x + 20, y + legendSpacing);

    // End Area
    canvas.drawRect(
      Rect.fromLTWH(x, y + legendSpacing * 2, iconSize, iconSize),
      Paint()..color = Colors.red.withOpacity(0.5),
    );
    _drawLegendText(canvas, 'End (2,4)', x + 20, y + legendSpacing * 2);
  }

  void _drawLegendText(Canvas canvas, String text, double x, double y) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }
} 