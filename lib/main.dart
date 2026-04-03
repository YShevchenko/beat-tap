import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(const BeatTapApp());

class BeatTapApp extends StatelessWidget {
  const BeatTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beat Tap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.purple.shade700,
          secondary: Colors.pinkAccent,
        ),
      ),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 120, color: Colors.purple.shade700),
            const SizedBox(height: 24),
            const Text(
              'Beat Tap',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap the circles in rhythm!',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
                backgroundColor: Colors.purple.shade700,
              ),
              child: const Text('PLAY', style: TextStyle(fontSize: 28)),
            ),
          ],
        ),
      ),
    );
  }
}

class Note {
  double y;
  final int lane;  // 0, 1, 2 (three lanes)
  bool tapped;
  final Color color;

  Note({
    required this.y,
    required this.lane,
    this.tapped = false,
    required this.color,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final List<Note> notes = [];
  final Random random = Random();
  int score = 0;
  int combo = 0;
  int maxCombo = 0;
  bool gameOver = false;
  double noteSpeed = 2.0;

  late AnimationController _controller;
  Timer? spawnTimer;

  final double targetY = 500.0;  // Where notes should be tapped
  final double missY = 600.0;    // If note passes this, it's a miss

  final List<Color> noteColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    )..repeat();

    _controller.addListener(_updateNotes);

    // Spawn notes periodically
    spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!gameOver) {
        _spawnNote();
      }
    });
  }

  void _spawnNote() {
    setState(() {
      final lane = random.nextInt(3);
      notes.add(Note(
        y: -50,
        lane: lane,
        color: noteColors[lane],
      ));
    });
  }

  void _updateNotes() {
    setState(() {
      for (var note in notes) {
        if (!note.tapped) {
          note.y += noteSpeed;
        }
      }

      // Remove notes that are off screen
      notes.removeWhere((note) => note.y > MediaQuery.of(context).size.height);

      // Check for missed notes
      for (var note in notes) {
        if (!note.tapped && note.y > missY) {
          note.tapped = true; // Mark as processed
          combo = 0; // Break combo on miss
        }
      }
    });
  }

  void _tapLane(int lane) {
    if (gameOver) return;

    // Find nearest note in this lane
    Note? nearestNote;
    double minDistance = double.infinity;

    for (var note in notes) {
      if (note.lane == lane && !note.tapped) {
        final distance = (note.y - targetY).abs();
        if (distance < minDistance && distance < 100) {  // Tap tolerance
          minDistance = distance;
          nearestNote = note;
        }
      }
    }

    if (nearestNote != null) {
      // Hit!
      setState(() {
        nearestNote!.tapped = true;
        combo++;
        maxCombo = max(maxCombo, combo);

        // Score based on accuracy
        if (minDistance < 30) {
          score += 100 * combo; // Perfect
          HapticFeedback.heavyImpact();
        } else if (minDistance < 60) {
          score += 50 * combo; // Good
          HapticFeedback.mediumImpact();
        } else {
          score += 25 * combo; // OK
          HapticFeedback.lightImpact();
        }
      });

      // Remove tapped note
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          notes.remove(nearestNote);
        });
      });
    } else {
      // Miss
      setState(() {
        combo = 0;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final laneWidth = screenWidth / 3;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade900,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Score: $score'),
            Text('Combo: x$combo'),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Lanes
          Row(
            children: [
              for (int i = 0; i < 3; i++)
                Container(
                  width: laneWidth,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Target line
          Positioned(
            top: targetY,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: Colors.white.withOpacity(0.5),
            ),
          ),

          // Notes
          ...notes.map((note) {
            if (note.tapped) return const SizedBox.shrink();

            return Positioned(
              left: note.lane * laneWidth + (laneWidth - 60) / 2,
              top: note.y,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: note.color,
                  boxShadow: [
                    BoxShadow(
                      color: note.color.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          // Tap areas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _tapLane(i),
                      child: Container(
                        height: 150,
                        color: Colors.transparent,
                        child: Icon(
                          Icons.touch_app,
                          size: 48,
                          color: noteColors[i].withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
