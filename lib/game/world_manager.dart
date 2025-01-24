import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class WorldScreen extends Component {
  final Vector2 coordinates;
  final List<Rect> obstacles;
  final Random random = Random();
  final int screenType;
  final Vector2 gameSize;

  WorldScreen(this.coordinates, this.gameSize) : 
    obstacles = [],
    screenType = _determineScreenType(coordinates) {
    _generateScreenContent();
  }

  static int _determineScreenType(Vector2 coordinates) {
    // Starting area
    if (coordinates.x == 0 && coordinates.y == 2) return 0;
    
    // Left section (0,0 to 0,4) - Ruins/Starting zone
    if (coordinates.x == 0) return 1;
    
    // Middle section (1,0 to 1,4) - Danger zone
    if (coordinates.x == 1) return 2;
    
    // Right section (2,0 to 2,4) - Final area
    return 3;
  }

  void _generateScreenContent() {
    switch (screenType) {
      case 0: // Starting area
        _generateStartingArea();
        break;
      case 1: // Ruins/Starting zone
        _generateRuinsArea();
        break;
      case 2: // Danger zone
        _generateDangerArea();
        break;
      case 3: // Final area
        _generateFinalArea();
        break;
    }
  }

  void _generateStartingArea() {
    // Minimal obstacles, safe area
    obstacles.add(Rect.fromLTWH(100, 100, 40, 40));
    obstacles.add(Rect.fromLTWH(700, 500, 40, 40));
  }

  void _generateRuinsArea() {
    // Scattered ruins and debris
    for (int i = 0; i < 4; i++) {
      obstacles.add(
        Rect.fromLTWH(
          50 + random.nextDouble() * 700,
          50 + random.nextDouble() * 500,
          60 + random.nextDouble() * 40,
          60 + random.nextDouble() * 40,
        ),
      );
    }
  }

  void _generateDangerArea() {
    // More dense obstacles
    for (int i = 0; i < 6; i++) {
      obstacles.add(
        Rect.fromLTWH(
          50 + random.nextDouble() * 700,
          50 + random.nextDouble() * 500,
          30 + random.nextDouble() * 50,
          30 + random.nextDouble() * 50,
        ),
      );
    }
  }

  void _generateFinalArea() {
    // Complex obstacle patterns
    for (int i = 0; i < 5; i++) {
      final centerX = 50 + random.nextDouble() * 700;
      final centerY = 50 + random.nextDouble() * 500;
      
      obstacles.add(
        Rect.fromLTWH(
          centerX,
          centerY,
          40 + random.nextDouble() * 30,
          40 + random.nextDouble() * 30,
        ),
      );
      
      // Add smaller obstacles around the main one
      obstacles.add(
        Rect.fromLTWH(
          centerX + 50,
          centerY + 50,
          20,
          20,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw base ground color based on screen type
    final groundPaint = Paint()
      ..style = PaintingStyle.fill;
    
    switch (screenType) {
      case 0: // Starting area
        groundPaint.color = const Color(0xFF1A1A1A);
        break;
      case 1: // Ruins
        groundPaint.color = const Color(0xFF1A1A1A).withGreen(30);
        break;
      case 2: // Danger zone
        groundPaint.color = const Color(0xFF1A1A1A).withRed(40);
        break;
      case 3: // Final area
        groundPaint.color = const Color(0xFF1A1A1A).withBlue(40);
        break;
    }
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameSize.x, gameSize.y),
      groundPaint,
    );

    // Draw obstacles
    final Paint obstaclePaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..style = PaintingStyle.fill;

    for (final obstacle in obstacles) {
      canvas.drawRect(obstacle, obstaclePaint);
    }

    // Draw decorative elements
    final Paint decorPaint = Paint()
      ..color = const Color(0xFF3D3D3D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Add unique decorations based on screen type
    switch (screenType) {
      case 0: // Starting area - minimal decoration
        _drawStartingAreaDecorations(canvas, decorPaint);
        break;
      case 1: // Ruins - broken lines and debris
        _drawRuinsDecorations(canvas, decorPaint);
        break;
      case 2: // Danger zone - sharp patterns
        _drawDangerZoneDecorations(canvas, decorPaint);
        break;
      case 3: // Final area - complex patterns
        _drawFinalAreaDecorations(canvas, decorPaint);
        break;
    }
  }

  void _drawStartingAreaDecorations(Canvas canvas, Paint paint) {
    for (int i = 0; i < 2; i++) {
      final startX = random.nextDouble() * gameSize.x;
      final startY = random.nextDouble() * gameSize.y;
      canvas.drawCircle(Offset(startX, startY), 30, paint);
    }
  }

  void _drawRuinsDecorations(Canvas canvas, Paint paint) {
    for (int i = 0; i < 5; i++) {
      final startX = random.nextDouble() * gameSize.x;
      final startY = random.nextDouble() * gameSize.y;
      final path = Path()
        ..moveTo(startX, startY)
        ..lineTo(startX + 30, startY + 30)
        ..lineTo(startX + 60, startY);
      canvas.drawPath(path, paint);
    }
  }

  void _drawDangerZoneDecorations(Canvas canvas, Paint paint) {
    for (int i = 0; i < 4; i++) {
      final startX = random.nextDouble() * gameSize.x;
      final startY = random.nextDouble() * gameSize.y;
      final path = Path()
        ..moveTo(startX, startY)
        ..lineTo(startX + 40, startY - 40)
        ..lineTo(startX + 80, startY);
      canvas.drawPath(path, paint);
    }
  }

  void _drawFinalAreaDecorations(Canvas canvas, Paint paint) {
    for (int i = 0; i < 6; i++) {
      final centerX = random.nextDouble() * gameSize.x;
      final centerY = random.nextDouble() * gameSize.y;
      canvas.drawCircle(Offset(centerX, centerY), 20, paint);
      canvas.drawCircle(Offset(centerX, centerY), 30, paint);
    }
  }
}

class WorldManager extends Component with HasGameRef {
  final Map<String, WorldScreen> screens = {};
  Vector2 currentCoordinates = Vector2.zero();
  
  // World boundaries for 3x5 layout
  static const int worldWidth = 3;
  static const int worldHeight = 5;
  static const int worldMinX = 0;
  static const int worldMaxX = worldWidth - 1;
  static const int worldMinY = 0;
  static const int worldMaxY = worldHeight - 1;

  @override
  Future<void> onLoad() async {
    // Initialize with starting position at (0,2) - middle of the left edge
    currentCoordinates = Vector2(0, 2);
    _getOrCreateScreen(currentCoordinates);
  }

  WorldScreen _getOrCreateScreen(Vector2 coordinates) {
    final key = '${coordinates.x},${coordinates.y}';
    if (!screens.containsKey(key)) {
      screens[key] = WorldScreen(coordinates, gameRef.size);
      add(screens[key]!); // Add the screen as a child component
    }
    return screens[key]!;
  }

  bool isValidPosition(Vector2 coordinates) {
    return coordinates.x >= worldMinX && 
           coordinates.x <= worldMaxX && 
           coordinates.y >= worldMinY && 
           coordinates.y <= worldMaxY;
  }

  void moveToScreen(Vector2 newCoordinates) {
    if (isValidPosition(newCoordinates)) {
      currentCoordinates = newCoordinates;
      _getOrCreateScreen(currentCoordinates);
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw world boundary indicators if at the edge
    final Paint boundaryPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    if (currentCoordinates.x == worldMinX) {
      canvas.drawLine(
        const Offset(0, 0),
        Offset(0, gameRef.size.y),
        boundaryPaint
      );
    }
    if (currentCoordinates.x == worldMaxX) {
      canvas.drawLine(
        Offset(gameRef.size.x, 0),
        Offset(gameRef.size.x, gameRef.size.y),
        boundaryPaint
      );
    }
    if (currentCoordinates.y == worldMinY) {
      canvas.drawLine(
        const Offset(0, 0),
        Offset(gameRef.size.x, 0),
        boundaryPaint
      );
    }
    if (currentCoordinates.y == worldMaxY) {
      canvas.drawLine(
        Offset(0, gameRef.size.y),
        Offset(gameRef.size.x, gameRef.size.y),
        boundaryPaint
      );
    }
  }
} 