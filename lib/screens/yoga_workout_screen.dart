import 'package:flutter/material.dart';
import 'dart:async';
import '../services/health_service.dart';
import '../services//layer_calculator.dart';

class YogaWorkoutScreen extends StatefulWidget {
  final String yogaPose;

  YogaWorkoutScreen({required this.yogaPose});

  @override
  _YogaWorkoutScreenState createState() => _YogaWorkoutScreenState();
}

class _YogaWorkoutScreenState extends State<YogaWorkoutScreen> {
  final healthService = HealthService();
  bool isWorkoutActive = false;
  DateTime? workoutStartTime;
  DateTime? workoutEndTime;
  late Stopwatch stopwatch;
  Timer? timer;
  int elapsedSeconds = 0;
  int steps = 0;
  double distance = 0.0;

  int currentLayer = 0;
  int currentSubLayer = 0;
  int finalRemainder = 0;

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
      steps = 0;
      distance = 0.0;
      currentLayer = 0;
      currentSubLayer = 0;
      finalRemainder = 0;
    });
    stopwatch = Stopwatch()..start();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds = stopwatch.elapsed.inSeconds;
        _updateLayers();
      });
    });
  }

  Future<void> _endWorkoutSession() async {
    setState(() {
      isWorkoutActive = false;
      workoutEndTime = DateTime.now();
    });
    stopwatch.stop();
    timer?.cancel();

    if (workoutStartTime != null && workoutEndTime != null) {
      await healthService.saveWorkoutToHealth(
        workoutStartTime: workoutStartTime!,
        workoutEndTime: workoutEndTime!,
        context: context,
        workoutType: 'yoga',
        steps: steps,
        distance: distance,
      );
    }
  }

  void _updateLayers() {
    List<int> result = LayerCalculator.calculateYogaLayer(elapsedSeconds, widget.yogaPose);

    setState(() {
      currentLayer = result[0];
      currentSubLayer = result[1];
      finalRemainder = result[2];
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    stopwatch.stop();
    super.dispose();
  }

  Widget _buildWorkoutDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Слой: $currentLayer',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Подслой: $currentSubLayer',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Остаток: $finalRemainder%',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          'Время: ${_formatTime(elapsedSeconds)}',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _endWorkoutSession,
          child: Text('Завершить тренировку'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тренировка: ${widget.yogaPose}'),
      ),
      body: Center(
        child: isWorkoutActive
            ? _buildWorkoutDisplay()
            : ElevatedButton(
          onPressed: _startWorkoutSession,
          child: Text('Начать тренировку'),
        ),
      ),
    );
  }
}
