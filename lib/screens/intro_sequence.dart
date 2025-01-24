import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/haven_game.dart';

class IntroSequence extends StatefulWidget {
  const IntroSequence({super.key});

  @override
  State<IntroSequence> createState() => _IntroSequenceState();
}

class _IntroSequenceState extends State<IntroSequence> {
  int _currentDialogue = 0;
  final List<Map<String, String>> _dialogues = [
    {
      "text": "System: Cryo-pod deactivation sequence initiated...",
      "subtext": "Status: Vital signs stabilizing",
    },
    {
      "text": "Warning: External environment compromised",
      "subtext": "Atmospheric anomalies detected",
    },
    {
      "text": "Holographic Message Detected...",
      "subtext": "Playing recording...",
    },
    {
      "text": "Dr. Elias Winters: Kael, if you're hearing this, you've finally awakened.",
      "subtext": "The world... it's not what you remember.",
    },
    {
      "text": "Dr. Elias Winters: I've left you the Eclipse Bubble. It will protect you.",
      "subtext": "Find me. There's so much to explain.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          if (_currentDialogue < _dialogues.length - 1) {
            setState(() {
              _currentDialogue++;
            });
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => GameWidget(
                  game: HavenGame(),
                ),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.blue[900]!.withOpacity(0.1),
                Colors.black,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Terminal-style text display
                Container(
                  width: 600,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    border: Border.all(
                      color: Colors.blue[700]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _dialogues[_currentDialogue]["text"]!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontFamily: 'monospace',
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _dialogues[_currentDialogue]["subtext"]!,
                        style: TextStyle(
                          color: Colors.green[200],
                          fontSize: 18,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Click to continue indicator
                Text(
                  'Click to continue...',
                  style: TextStyle(
                    color: Colors.blue[400],
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 