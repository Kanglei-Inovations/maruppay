import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../services/time_service.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  final String targetTime;
  final Color textColor;
  final double fontSize;

  const CountdownTimer({
    super.key,
    required this.targetDate,
    required this.targetTime,
    this.textColor = Colors.white,
    this.fontSize = 28,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  final TimeService _timeService = Get.find<TimeService>();

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _calculateTimeLeft());
  }

  void _calculateTimeLeft() {
    try {
      final timeParts = widget.targetTime.split(':');
      final target = DateTime(
        widget.targetDate.year,
        widget.targetDate.month,
        widget.targetDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      
      // Use synchronized network time instead of phone clock
      final diff = target.difference(_timeService.now);
      
      if (mounted) {
        setState(() => _timeLeft = diff.isNegative ? Duration.zero : diff);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_timeService.isSynced.value) {
        return const Column(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
            ),
            SizedBox(height: 8),
            Text('Syncing Time...', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        );
      }

      if (_timeLeft.inSeconds == 0) {
        return const Text(
          'DRAW IN PROGRESS',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 18),
        );
      }

      final days = _timeLeft.inDays;
      final hours = _timeLeft.inHours % 24;
      final minutes = _timeLeft.inMinutes % 60;
      final seconds = _timeLeft.inSeconds % 60;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _timeBox(days.toString().padLeft(2, '0'), 'DAYS'),
          _timeDivider(),
          _timeBox(hours.toString().padLeft(2, '0'), 'HRS'),
          _timeDivider(),
          _timeBox(minutes.toString().padLeft(2, '0'), 'MIN'),
          _timeDivider(),
          _timeBox(seconds.toString().padLeft(2, '0'), 'SEC'),
        ],
      );
    });
  }

  Widget _timeBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: widget.textColor,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: widget.textColor.withOpacity(0.4),
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _timeDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(color: AppColors.gold, fontSize: widget.fontSize - 4, fontWeight: FontWeight.bold),
      ),
    );
  }
}
