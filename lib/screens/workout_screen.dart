import 'package:flutter/material.dart';
import 'dart:async';
import '../services/health_service.dart';
import '../utils/time_formatter.dart';

class WorkoutScreen extends StatefulWidget {
  final String yogaPose;

  WorkoutScreen({required this.yogaPose});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final healthService = HealthService();
  bool isWorkoutActive = false;
  DateTime? workoutStartTime;
  DateTime? workoutEndTime;
  late Stopwatch stopwatch;
  late Timer timer;
  int elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    healthService.authorizeHealth(context);
  }

  Future<void> _startWorkoutSession() async {
    setState(() {
      isWorkoutActive = true;
      workoutStartTime = DateTime.now();
      elapsedSeconds = 0;
    });
    stopwatch = Stopwatch()..start();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds = stopwatch.elapsed.inSeconds;
      });
    });
  }

  Future<void> _endWorkoutSession() async {
    setState(() {
      isWorkoutActive = false;
      workoutEndTime = DateTime.now();
    });
    stopwatch.stop();
    timer.cancel();

    if (workoutStartTime != null && workoutEndTime != null) {
      await healthService.saveWorkoutToHealth(
        workoutStartTime: workoutStartTime!,
        workoutEndTime: workoutEndTime!,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тренировка: ${widget.yogaPose}'),
      ),
      body: Center(
        child: isWorkoutActive
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Тренировка активна',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Время: ${formatElapsedTime(elapsedSeconds)}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _endWorkoutSession,
                    child: Text('Завершить тренировку'),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: _startWorkoutSession,
                child: Text('Начать тренировку'),
              ),
      ),
    );
  }

  @override
  void dispose() {
    if (timer.isActive) timer.cancel();
    stopwatch.stop();
    super.dispose();
  }
}
