import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../managers/memory_manager.dart';

class EndingSequence extends Component with HasGameRef {
  final MemoryManager memoryManager;
  bool isActive = false;
  double fadeAlpha = 0;
  int currentStep = 0;
  double elapsedTime = 0;
  List<ParticleComponent> particles = [];
  
  static const double particleSize = 5.0;
  static const int maxParticles = 50;
  static const double fadeInDuration = 2.0;
  static const double memoryDisplayDuration = 4.0;
  static const double finalFadeDuration = 3.0;

  EndingSequence(this.memoryManager);

  void start() {
    isActive = true;
    currentStep = 0;
    elapsedTime = 0;
    _spawnParticles();
  }

  void _spawnParticles() {
    final random = math.Random();
    for (int i = 0; i < maxParticles; i++) {
      final particle = ParticleComponent(
        position: Vector2(
          random.nextDouble() * gameRef.size.x,
          random.nextDouble() * gameRef.size.y,
        ),
        size: Vector2.all(particleSize),
      );
      particles.add(particle);
      add(particle);
    }
  }

  @override
  void update(double dt) {
    if (!isActive) return;
    
    elapsedTime += dt;
    
    // Update particle positions
    for (final particle in particles) {
      particle.position.y -= 30 * dt; // Drift upward
      if (particle.position.y < -particleSize) {
        particle.position.y = gameRef.size.y + particleSize;
      }
    }

    // Handle sequence steps
    switch (currentStep) {
      case 0: // Initial fade in
        fadeAlpha = (elapsedTime / fadeInDuration).clamp(0, 1);
        if (elapsedTime >= fadeInDuration) {
          currentStep = 1;
          elapsedTime = 0;
        }
        break;

      case 1: // Display memories
        final memoryIndex = (elapsedTime / memoryDisplayDuration).floor();
        if (memoryIndex >= memoryManager.totalFragments) {
          currentStep = 2;
          elapsedTime = 0;
        }
        break;

      case 2: // Final fade to white
        fadeAlpha = 1 - (elapsedTime / finalFadeDuration).clamp(0, 1);
        if (elapsedTime >= finalFadeDuration) {
          isActive = false;
          // Game can transition to credits or end screen here
        }
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;

    // Draw background overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
      Paint()..color = Colors.black.withOpacity(0.7 * fadeAlpha),
    );

    // Draw particles
    for (final particle in particles) {
      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particleSize,
        Paint()
          ..color = Colors.amber.withOpacity(0.3 * fadeAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    // Draw memory text if in memory display phase
    if (currentStep == 1) {
      final memoryIndex = (elapsedTime / memoryDisplayDuration).floor();
      if (memoryIndex < memoryManager.totalFragments) {
        final memory = memoryManager.fragmentData[memoryIndex];
        _drawMemoryText(canvas, memory['message'], memory['sender']);
      }
    }

    // Draw final fade to white
    if (currentStep == 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
        Paint()..color = Colors.white.withOpacity((elapsedTime / finalFadeDuration).clamp(0, 1)),
      );
    }
  }

  void _drawMemoryText(Canvas canvas, String message, String sender) {
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(fadeAlpha),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    // Draw sender
    final senderPainter = TextPainter(
      text: TextSpan(text: sender, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    senderPainter.layout(maxWidth: gameRef.size.x * 0.8);
    senderPainter.paint(
      canvas,
      Offset(
        (gameRef.size.x - senderPainter.width) / 2,
        gameRef.size.y * 0.3,
      ),
    );

    // Draw message
    final messagePainter = TextPainter(
      text: TextSpan(text: message, style: textStyle.copyWith(fontSize: 16)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    messagePainter.layout(maxWidth: gameRef.size.x * 0.8);
    messagePainter.paint(
      canvas,
      Offset(
        (gameRef.size.x - messagePainter.width) / 2,
        gameRef.size.y * 0.4,
      ),
    );
  }
}

class ParticleComponent extends PositionComponent {
  ParticleComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);
} 