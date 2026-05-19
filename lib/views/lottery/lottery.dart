import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class LotteryVisualPage extends StatefulWidget {
  const LotteryVisualPage({super.key});

  @override
  State<LotteryVisualPage> createState() =>
      _LotteryVisualPageState();
}

class _LotteryVisualPageState
    extends State<LotteryVisualPage>
    with TickerProviderStateMixin {

  final List<String> names = [
    "Aftab", "Rahul", "John", "Aman", "Ritik",
    "Karan", "Sahil", "Rohan", "Vikash", "Imran",
  ];

  final List<String> luckyPapers = [
    "assets/gems.png", "assets/gems.png", "assets/gems.png",
    "assets/gems.png", "assets/gems.png", "assets/gems.png",
    "assets/gems.png", "assets/gems.png", "assets/gems.png",
    "assets/ruby.png",
  ];

  // Store dynamic positions for items in pots
  List<Offset> namePositions = [];
  List<Offset> luckyPositions = [];
  List<double> itemRotations = [];

  String currentName = "?";
  String currentLucky = "";
  String winner = "";

  bool isRunning = false;

  late AnimationController leftHandController;
  late AnimationController rightHandController;
  late AnimationController shakeController;

  @override
  void initState() {
    super.initState();
    _initializePositions();

    leftHandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    rightHandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  void _initializePositions() {
    final rand = Random();
    namePositions = List.generate(names.length, (_) => Offset(rand.nextDouble() * 100 + 30, rand.nextDouble() * 60 + 80));
    luckyPositions = List.generate(luckyPapers.length, (_) => Offset(rand.nextDouble() * 100 + 30, rand.nextDouble() * 60 + 80));
    itemRotations = List.generate(max(names.length, luckyPapers.length), (_) => rand.nextDouble() * 2 * pi);
  }

  void _scramblePositions() {
    final rand = Random();
    setState(() {
      for (int i = 0; i < namePositions.length; i++) {
        namePositions[i] = Offset(rand.nextDouble() * 100 + 30, rand.nextDouble() * 60 + 80);
      }
      for (int i = 0; i < luckyPositions.length; i++) {
        luckyPositions[i] = Offset(rand.nextDouble() * 100 + 30, rand.nextDouble() * 60 + 80);
      }
      for (int i = 0; i < itemRotations.length; i++) {
        itemRotations[i] = rand.nextDouble() * 2 * pi;
      }
    });
  }

  @override
  void dispose() {
    leftHandController.dispose();
    rightHandController.dispose();
    shakeController.dispose();
    super.dispose();
  }

  Future<void> startLottery() async {
    if (isRunning) return;

    setState(() {
      isRunning = true;
      winner = "";
      currentName = "?";
      currentLucky = "";
    });

    // INITIAL SCRAMBLE & SHAKE
    for (int i = 0; i < 12; i++) {
      _scramblePositions();
      await shakeController.forward();
      await shakeController.reverse();
    }

    final shuffledNames = List<String>.from(names)..shuffle();
    final shuffledLucky = List<String>.from(luckyPapers)..shuffle();

    for (int i = 0; i < shuffledNames.length; i++) {
      // HAND GO DOWN
      await Future.wait([
        leftHandController.forward(),
        rightHandController.forward(),
      ]);

      setState(() {
        currentName = shuffledNames[i];
        currentLucky = shuffledLucky[i];
      });

      await Future.delayed(const Duration(milliseconds: 400));

      // HAND COME UP
      await Future.wait([
        leftHandController.reverse(),
        rightHandController.reverse(),
      ]);

      await Future.delayed(const Duration(milliseconds: 800));

      if (shuffledLucky[i] == "assets/ruby.png") {
        setState(() { winner = shuffledNames[i]; });
        break;
      }

      // SMALL SCRAMBLE BETWEEN PICKS
      for (int j = 0; j < 3; j++) {
        _scramblePositions();
        await shakeController.forward();
        await shakeController.reverse();
      }
    }

    setState(() { isRunning = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1E293B), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "MARUP LUCKY DRAW",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  shadows: [Shadow(color: Colors.orange, blurRadius: 15)],
                ),
              ),
              const Text(
                "Realistic Glass Pot Experience",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildPotSection(
                    controller: leftHandController,
                    shakeController: shakeController,
                    title: "NAMES POT",
                    value: currentName,
                    isAsset: false,
                    color: Colors.blueAccent,
                    handAsset: "assets/pickup.png",
                    itemPositions: namePositions,
                  ),
                  _buildPotSection(
                    controller: rightHandController,
                    shakeController: shakeController,
                    title: "LUCKY POT",
                    value: currentLucky,
                    isAsset: true,
                    color: Colors.pinkAccent,
                    handAsset: "assets/pickup.png",
                    itemPositions: luckyPositions,
                  ),
                ],
              ),
              const Spacer(),
              _buildWinnerDisplay(),
              const SizedBox(height: 25),
              _buildStartButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPotSection({
    required AnimationController controller,
    required AnimationController shakeController,
    required String title,
    required String value,
    required bool isAsset,
    required Color color,
    required String handAsset,
    required List<Offset> itemPositions,
  }) {
    return SizedBox(
      width: 180,
      height: 420,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // GLASS POT (Fishbowl style)
          Positioned(
            bottom: 0,
            child: AnimatedBuilder(
              animation: shakeController,
              builder: (context, child) {
                final shake = sin(shakeController.value * pi * 2) * 8;
                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pot Background (Glass effect)
                      Container(
                        width: 170,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(color: Colors.white38, width: 2),
                          boxShadow: [
                            BoxShadow(color: color.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                          ],
                        ),
                      ),
                      // Interior Items
                      ...List.generate(itemPositions.length, (index) {
                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 150),
                          left: itemPositions[index].dx,
                          top: itemPositions[index].dy,
                          child: Transform.rotate(
                            angle: itemRotations[index],
                            child: isAsset
                                ? Image.asset(luckyPapers[index], width: 28, height: 28)
                                : Container(
                                    width: 32,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                                    ),
                                    child: const Center(child: Text("✉", style: TextStyle(fontSize: 10))),
                                  ),
                          ),
                        );
                      }),
                      // Pot Rim & Reflections
                      Container(
                        width: 170,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white10, width: 10),
                        ),
                      ),
                      // Title
                      Positioned(
                        top: 40,
                        child: Text(
                          title,
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // HAND + PICKED ITEM
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              // Calculate opacities for smooth transition
              // Hand fades out when very close to the top (value < 0.15)
              final double handOpacity = controller.value > 0.15 ? 1.0 : (controller.value / 0.15).clamp(0.0, 1.0);
              // Card fades in as hand fades out
              final double cardOpacity = (1.0 - (controller.value / 0.25)).clamp(0.0, 1.0);
              
              final bool hasValue = value != "" && value != "?";

              return Positioned(
                top: 20 + (160 * controller.value),
                child: Transform.rotate(
                  angle: controller.value * 0.15,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // THE RESULT CARD (show.png)
                      if (hasValue)
                        Opacity(
                          opacity: cardOpacity,
                          child: Transform.scale(
                            scale: 1.0 + (0.2 * (1.0 - controller.value)), // Slight zoom in as it reveals
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset("assets/show.png", width: 140),
                                Positioned(
                                  top: 40,
                                  child: isAsset
                                      ? Image.asset(value, width: 42, height: 42)
                                      : Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
                                          ),
                                          child: Text(
                                            value,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // THE HAND (pickup.png)
                      Opacity(
                        opacity: handOpacity,
                        child: Image.asset(
                          handAsset,
                          width: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerDisplay() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: winner.isEmpty ? Colors.white.withOpacity(0.05) : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: winner.isEmpty ? Colors.white12 : Colors.greenAccent, width: 2),
        boxShadow: winner.isEmpty ? [] : [BoxShadow(color: Colors.greenAccent.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
      ),
      child: Center(
        child: winner.isEmpty
            ? const Text("Drawing papers...", style: TextStyle(color: Colors.white, fontSize: 18))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🎉 WINNER 🎉", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 12),
                  Text(winner, style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            elevation: 10,
            shadowColor: Colors.orange.withOpacity(0.5),
          ),
          onPressed: startLottery,
          child: Text(
            isRunning ? "DRAWING..." : "START DRAW",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }
}