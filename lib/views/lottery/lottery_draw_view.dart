import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/lottery_controller.dart';
import '../../models/draw_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/countdown_timer.dart';
import 'package:intl/intl.dart';

class LotteryDrawView extends StatefulWidget {
  final String drawId;
  final String groupId;

  const LotteryDrawView({Key? key, required this.drawId, required this.groupId}) : super(key: key);

  @override
  State<LotteryDrawView> createState() => _LotteryDrawViewState();
}

class _LotteryDrawViewState extends State<LotteryDrawView> with TickerProviderStateMixin {
  final LotteryController controller = Get.put(LotteryController());

  // Animation Controllers for Realistic Interaction
  late AnimationController leftHandController;
  late AnimationController rightHandController;
  late AnimationController shakeController;

  // Visual Assets
  final String handAsset = "assets/pickup.png";
  final String cardAsset = "assets/show.png";

  // Dynamic positions for items in pots (for that "filled" look)
  List<Offset> namePositions = [];
  List<Offset> gemPositions = [];
  List<double> itemRotations = [];

  @override
  void initState() {
    super.initState();
    _initializePositions();
    controller.initializeDrawSequence(widget.drawId, widget.groupId);

    // Update visual items when members are loaded from Firestore
    once(controller.activeMembers, (_) {
      if (mounted) setState(() => _initializePositions());
    });

    leftHandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    rightHandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Listen to status changes to trigger local animations
    ever(controller.currentDraw, (draw) {
      if (draw != null) {
        _handleAnimationSequence(draw.status);
      }
    });
  }

  void _initializePositions() {
    final rand = Random();
    // Pre-generate random positions for 10 items in each pot to make it look full
    namePositions = List.generate(10, (_) => Offset(rand.nextDouble() * 100 + 30, rand.nextDouble() * 60 + 80));
    gemPositions = List.generate(10, (_) => Offset(rand.nextDouble() * 100 + 30, rand.nextDouble() * 60 + 80));
    itemRotations = List.generate(10, (_) => rand.nextDouble() * 2 * pi);
  }

  void _handleAnimationSequence(DrawStatus status) async {
    switch (status) {
      case DrawStatus.pot_shaking:
        shakeController.repeat(reverse: true);
        leftHandController.reverse();
        rightHandController.reverse();
        break;
      case DrawStatus.selecting_name:
        shakeController.stop();
        await leftHandController.forward();
        await Future.delayed(const Duration(milliseconds: 500));
        await leftHandController.reverse();
        break;
      case DrawStatus.selecting_gem:
        shakeController.stop();
        await rightHandController.forward();
        await Future.delayed(const Duration(milliseconds: 500));
        await rightHandController.reverse();
        break;
      case DrawStatus.picking_both:
        shakeController.stop();
        // Run both animations in parallel
        leftHandController.forward();
        rightHandController.forward();
        await Future.delayed(const Duration(milliseconds: 1500));
        leftHandController.reverse();
        rightHandController.reverse();
        break;
      case DrawStatus.winner_reveal:
      case DrawStatus.completed:
        shakeController.stop();
        leftHandController.reverse();
        rightHandController.reverse();
        break;
      default:
        shakeController.stop();
        break;
    }
  }

  @override
  void dispose() {
    leftHandController.dispose();
    rightHandController.dispose();
    shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('KANGLEI LIVE DRAW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: Obx(() {
          final draw = controller.currentDraw.value;
          if (draw == null) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

          return Stack(
            alignment: Alignment.center,
            children: [
              // Background Sparkles
              if (draw.status == DrawStatus.winner_reveal)
                Positioned.fill(
                  child: Center(
                    child: const Icon(Icons.star, color: AppColors.gold, size: 300)
                        .animate()
                        .fadeOut(duration: const Duration(seconds: 2)),
                  ),
                ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  if (draw.status == DrawStatus.scheduled) ...[
                    CountdownTimer(
                      targetDate: draw.scheduledAt,
                      targetTime: DateFormat('HH:mm').format(draw.scheduledAt),
                      fontSize: 32,
                    ),
                    const SizedBox(height: 30),
                  ],
                  _buildStatusBadge(draw.status, draw.currentStep),
                  const SizedBox(height: 40),
                  
                  // THE TWO GLASS POTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildGlassPot(
                        title: "NAMES", 
                        icon: Icons.person, 
                        color: Colors.blueAccent,
                        value: draw.currentName, // Use currentName
                        isGem: false,
                        status: draw.status,
                        controller: leftHandController,
                        itemPositions: namePositions,
                      ),
                      _buildGlassPot(
                        title: "GEMS", 
                        icon: Icons.diamond, 
                        color: Colors.pinkAccent,
                        value: draw.currentGem, // Use currentGem
                        isGem: true,
                        status: draw.status,
                        controller: rightHandController,
                        itemPositions: gemPositions,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  
                  if (draw.status == DrawStatus.winner_reveal || draw.status == DrawStatus.completed)
                    _buildWinnerReveal(draw)
                  else
                    _buildRealtimeSyncLabel(),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatusBadge(DrawStatus status, int step) {
    String label = '';
    switch (status) {
      case DrawStatus.scheduled: label = 'WAITING FOR START'; break;
      case DrawStatus.starting: label = 'DRAW STARTING...'; break;
      case DrawStatus.pot_shaking: label = 'SHAKING POTS'; break;
      case DrawStatus.selecting_name: label = 'PICKING NAME...'; break;
      case DrawStatus.selecting_gem: label = 'PICKING GEM...'; break;
      case DrawStatus.picking_both: label = 'PICKING BOTH...'; break;
      case DrawStatus.winner_reveal: label = 'WINNER FOUND!'; break;
      case DrawStatus.completed: label = 'DRAW COMPLETED'; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.gold, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2),
      ),
    ).animate(key: ValueKey(status)).scale(duration: const Duration(milliseconds: 400)).fadeIn();
  }

  Widget _buildGlassPot({
    required String title, 
    required IconData icon, 
    required Color color,
    String? value,
    required bool isGem,
    required DrawStatus status,
    required AnimationController controller,
    required List<Offset> itemPositions,
  }) {
    return SizedBox(
      width: 170,
      height: 380,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // GLASS POT
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
                      Container(
                        width: 160,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
                          ),
                          border: Border.all(color: Colors.white24, width: 2),
                          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
                        ),
                      ),
                      // Interior Items
                      ...List.generate(itemPositions.length, (index) {
                        return Positioned(
                          left: itemPositions[index].dx,
                          top: itemPositions[index].dy,
                          child: Transform.rotate(
                            angle: itemRotations[index],
                            child: isGem
                                ? Opacity(opacity: 0.3, child: Image.asset("assets/gems.png", width: 24))
                                : Container(
                                    width: 24,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Center(child: Text("✉", style: TextStyle(fontSize: 8, color: Colors.white54))),
                                  ),
                          ),
                        );
                      }),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: Colors.white10, size: 50),
                            const SizedBox(height: 4),
                            Text(title, style: TextStyle(color: color.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // HAND + CARD ANIMATION
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final double handOpacity = controller.value > 0.2 ? 1.0 : (controller.value / 0.2).clamp(0.0, 1.0);
              final double cardOpacity = (1.0 - (controller.value / 0.3)).clamp(0.0, 1.0);
              
              // Only show the card if we are in the correct status and have a value
              bool showThisPotItem = false;
              if (isGem) {
                showThisPotItem = (status == DrawStatus.selecting_gem || status == DrawStatus.picking_both || status == DrawStatus.winner_reveal || status == DrawStatus.completed) && value != null;
              } else {
                showThisPotItem = (status == DrawStatus.selecting_name || status == DrawStatus.picking_both || status == DrawStatus.winner_reveal || status == DrawStatus.completed) && value != null;
              }

              return Positioned(
                top: 10 + (160 * controller.value),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // THE RESULT CARD
                    if (showThisPotItem)
                      Opacity(
                        opacity: cardOpacity,
                        child: Transform.scale(
                          scale: 1.2 - (controller.value * 0.2),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(cardAsset, width: 140),
                              Positioned(
                                top: 40,
                                child: isGem 
                                  ? (value!.contains('/') ? Image.asset(value, width: 40, height: 40) : Image.asset("assets/ruby.png", width: 40))
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                                      child: Text(value!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // THE HAND
                    Opacity(
                      opacity: handOpacity,
                      child: Image.asset(handAsset, width: 110, fit: BoxFit.contain),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildWinnerReveal(DrawModel draw) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.5), blurRadius: 40)],
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_outlined, color: Colors.white, size: 60),
          const SizedBox(height: 16),
          const Text('OFFICIAL WINNER', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            draw.winnerName ?? 'UNKNOWN',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '₹${draw.poolAmount}',
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    ).animate().scale(duration: const Duration(seconds: 1), curve: Curves.elasticOut).fadeIn();
  }

  Widget _buildRealtimeSyncLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.sync, color: AppColors.primary, size: 14),
        const SizedBox(width: 8),
        const Text('REALTIME SYNCHRONIZED', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: const Duration(seconds: 1));
  }
}
