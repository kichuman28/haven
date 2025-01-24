import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class UIOverlay extends Component {
  Vector2 worldPosition;
  final Map<String, dynamic> discoveredScreens;
  static const mapSize = 150.0;
  static const cellSize = 20.0;
  
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
    // Draw map background
    final mapRect = Rect.fromLTWH(20, 50, mapSize, mapSize);
    canvas.drawRect(
      mapRect,
      Paint()
        ..color = Colors.black.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );

    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw discovered screens
    final screenPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final currentPaint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Calculate the range of coordinates to show
    final minX = worldPosition.x - 3;
    final maxX = worldPosition.x + 3;
    final minY = worldPosition.y - 3;
    final maxY = worldPosition.y + 3;

    // Draw all discovered screens in range
    for (final key in discoveredScreens.keys) {
      final coords = key.split(',');
      final x = double.parse(coords[0]);
      final y = double.parse(coords[1]);
      
      if (x >= minX && x <= maxX && y >= minY && y <= maxY) {
        final mapX = 20 + (x - minX) * cellSize;
        final mapY = 50 + (y - minY) * cellSize;
        
        canvas.drawRect(
          Rect.fromLTWH(mapX, mapY, cellSize, cellSize),
          screenPaint,
        );
      }
    }

    // Draw current position
    final currentX = 20 + 3 * cellSize;  // Center of the map
    final currentY = 50 + 3 * cellSize;
    canvas.drawRect(
      Rect.fromLTWH(currentX, currentY, cellSize, cellSize),
      currentPaint,
    );

    // Draw map border
    canvas.drawRect(mapRect, gridPaint);

    // Draw map legend
    final legendY = 50 + mapSize + 10;
    canvas.drawRect(
      Rect.fromLTWH(20, legendY, 15, 15),
      currentPaint,
    );
    
    final legendPainter = TextPainter(
      text: const TextSpan(
        text: ' Current Position',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    
    legendPainter.layout();
    legendPainter.paint(canvas, Offset(40, legendY));
  }
} 