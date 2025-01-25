import 'package:flame/components.dart';
import '../components/memory_fragment.dart';
import '../components/memory_dialog.dart';

class MemoryManager extends Component with HasGameRef {
  final Set<int> collectedFragments = {};
  MemoryDialog? activeDialog;
  bool hasCollectedAllFragments = false;
  
  final List<Map<String, dynamic>> fragmentData = [
    {
      'id': 1,
      'sender': 'Dr. Elias Winters - Personal Log',
      'message': '''Project Eclipse was meant to be our salvation. The dimensional barriers were weakening, and we needed a way to protect ourselves. The Eclipse Bubble technology was revolutionary - a personal shield that could stabilize local space-time.

But something went wrong. The initial tests were successful, too successful. We thought we could expand the field, create safe zones for entire populations. We were blind to the consequences.

Kael, if you're reading this, know that everything I did was to protect you. The Eclipse Bubble prototype was calibrated to your DNA for a reason.''',
      'position': Vector2(400, 300),
      'screen': Vector2(0, 2),
      'story_order': 1
    },
    {
      'id': 2,
      'sender': 'Research Terminal - Incident Report',
      'message': '''CRITICAL INCIDENT REPORT - The Fracture Event
Date: [REDACTED]
Time: 03:42 AM

The containment field collapsed during the full-scale test. Multiple breaches detected across all sectors. Reality itself seems to be unraveling at the edges. The Riftlings - that's what the research team is calling them - they're coming through the tears.

Emergency Protocol Delta is in effect. All non-essential personnel have been evacuated. Dr. Winters has locked himself in the main lab. He claims he can fix this, but the readings are off the charts.''',
      'position': Vector2(200, 200),
      'screen': Vector2(2, 1),
      'story_order': 2
    },
    {
      'id': 3,
      'sender': 'Dr. Sarah Chen - Video Log',
      'message': '''The Riftlings are evolving faster than we could have predicted. They're not just random manifestations anymore - they're learning, adapting. Each breach makes them stronger.

Elias's theory was right. The Eclipse Bubble doesn't just protect against them; it can repel them back through the tears. But the power requirements... God help us, the human body was never meant to channel this much energy.

I've seen what it did to the test subjects. Elias, what have you done to your son?''',
      'position': Vector2(500, 400),
      'screen': Vector2(1, 3),
      'story_order': 3
    },
    {
      'id': 4,
      'sender': 'Security Override Terminal',
      'message': '''SECURITY ALERT - Level 5 Clearance Required
Time Stamp: [CORRUPTED]

Multiple unauthorized access attempts detected in the main reactor control room. Security footage shows Dr. Winters accessing restricted protocols. He's overriding the safety measures.

WARNING: Dimensional stability at 15% and falling.
WARNING: Anomalous energy signatures detected in the cryo-chamber wing.
WARNING: Project Eclipse containment protocols have been manually disabled.''',
      'position': Vector2(300, 300),
      'screen': Vector2(2, 3),
      'story_order': 4
    },
    {
      'id': 5,
      'sender': 'Dr. Elias Winters - Final Recording',
      'message': '''Kael, my son, this is my final message. The truth is, the Fracture wasn't an accident. I caused it. I had to. What we discovered on the other side... there are things worse than the Riftlings out there.

The Eclipse Bubble wasn't just meant to protect - it's a key. Your DNA, combined with the technology, can seal the breaches permanently. But the cost... I'm so sorry. I couldn't bear to do it myself. That's why I put you in cryo-sleep.

The choice is yours now. The final protocol is ready in the central chamber.''',
      'position': Vector2(400, 200),
      'screen': Vector2(0, 4),
      'story_order': 5
    },
    {
      'id': 6,
      'sender': 'Encrypted Final Protocol',
      'message': '''PROTOCOL OMEGA
Status: ARMED
Location: Central Chamber

Warning: Activation of Protocol Omega will initiate a complete dimensional reset. The Eclipse Bubble carrier will serve as the anchor point for reality stabilization.

Survival probability for anchor subject: 12%
Dimensional stability restoration: 98%

All fragments collected. The Central Chamber has been unlocked. Proceed to coordinates (2,4) to initiate Protocol Omega.''',
      'position': Vector2(200, 400),
      'screen': Vector2(1, 1),
      'story_order': 6
    }
  ];

  void spawnFragmentsForScreen(String screenCoord) {
    // Parse the screen coordinates
    final coords = screenCoord.split(',');
    final screenPos = Vector2(
      double.parse(coords[0]),
      double.parse(coords[1])
    );
    
    // Remove any existing fragments first
    final existingFragments = children.whereType<MemoryFragment>().toList();
    for (final fragment in existingFragments) {
      fragment.removeFromParent();
    }
    
    // Find and spawn fragments for this screen
    final fragments = fragmentData.where((data) => 
      data['screen'].x == screenPos.x && 
      data['screen'].y == screenPos.y
    );
    
    for (final fragmentInfo in fragments) {
      final fragment = MemoryFragment(
        position: fragmentInfo['position'],
        fragmentId: fragmentInfo['id'],
        message: fragmentInfo['message'],
        sender: fragmentInfo['sender'],
      );
      // Set collected state if previously collected
      fragment.isCollected = collectedFragments.contains(fragmentInfo['id']);
      gameRef.add(fragment);
    }
  }

  void collectFragment(MemoryFragment fragment) {
    // Check if this is the next fragment in sequence
    int nextExpectedId = collectedFragments.length + 1;
    if (fragment.fragmentId != nextExpectedId) {
      // If trying to collect out of order, show a hint dialog
      hideDialog();
      activeDialog = MemoryDialog(
        message: 'This memory is locked. Find Memory Fragment #$nextExpectedId first.',
        sender: 'System',
      );
      gameRef.add(activeDialog!);
      return;
    }

    if (collectedFragments.contains(fragment.fragmentId)) {
      // If already collected, just show the message again
      hideDialog();
      activeDialog = MemoryDialog(
        message: fragment.message,
        sender: fragment.sender,
      );
      gameRef.add(activeDialog!);
      return;
    }
    
    collectedFragments.add(fragment.fragmentId);
    fragment.isCollected = true;
    
    // Remove existing dialog if any
    hideDialog();
    
    // Show new dialog
    activeDialog = MemoryDialog(
      message: fragment.message,
      sender: fragment.sender,
    );
    gameRef.add(activeDialog!);

    // Check if all fragments are collected
    if (collectedCount == totalFragments && !hasCollectedAllFragments) {
      hasCollectedAllFragments = true;
      // The UI will be updated to show the final destination
    }
  }

  void hideDialog() {
    if (activeDialog != null) {
      activeDialog!.removeFromParent();
      activeDialog = null;
    }
  }

  bool hasCollectedFragment(int fragmentId) {
    return collectedFragments.contains(fragmentId);
  }

  int get totalFragments => fragmentData.length;
  int get collectedCount => collectedFragments.length;

  // Get the story order of a fragment regardless of collection order
  int getStoryOrder(int fragmentId) {
    final fragment = fragmentData.firstWhere((f) => f['id'] == fragmentId);
    return fragment['story_order'];
  }

  void reset() {
    collectedFragments.clear();
    hasCollectedAllFragments = false;
    hideDialog();
  }
} 