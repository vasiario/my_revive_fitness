import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import '../services/health_service.dart';
import '../services//layer_calculator.dart';

class RunningWorkoutScreen extends StatefulWidget {
  @override
  _RunningWorkoutScreenState createState() => _RunningWorkoutScreenState();
}

class _RunningWorkoutScreenState extends State<RunningWorkoutScreen> {
  final healthService = HealthService();

  Timer? timer;
  bool isRunning = false;
  bool isPaused = false;
  bool isLoading = false;
  bool isHealthAvailable = false;

  int elapsedSeconds = 0;
  int totalSteps = 0;
  double distance = 0.0; // в километрах

  int currentLayer = 0;
  int currentSubLayer = 0;
  int finalRemainder = 0;

  DateTime? workoutStartTime;
  DateTime? pauseStartTime;

  StreamSubscription<StepCount>? _stepCountSubscription;
  int? _initialStepCount;

  @override
  void initState() {
    super.initState();
    _initializeHealth();
  }

  Future<void> _initializeHealth() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      isHealthAvailable = await healthService.authorizeHealth(context);
      print("Health available: $isHealthAvailable");
    } catch (e) {
      print("Health initialization error: $e");
      isHealthAvailable = false;
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _startWorkout() async {
    if (!isHealthAvailable) {
      _showMessage("Health is unavailable");
      return;
    }

    setState(() {
      isRunning = true;
      isPaused = false;
      elapsedSeconds = 0;
      totalSteps = 0;
      distance = 0.0;
      currentLayer = 0;
      currentSubLayer = 0;
      finalRemainder = 0;
      workoutStartTime = DateTime.now();
      _initialStepCount = null;
    });

    _startTimer();
    _startPedometer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused && mounted) {
        setState(() {
          elapsedSeconds++;
          _updateLayers();
        });
      }
    });
  }

  void _startPedometer() {
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onPedometerError,
      cancelOnError: true,
    );
  }

  void _onStepCount(StepCount event) {
    if (!mounted || isPaused || !isRunning) return;

    setState(() {
      if (_initialStepCount == null) {
        _initialStepCount = event.steps;
      }
      totalSteps = event.steps - _initialStepCount!;
      distance = totalSteps * 0.000762; // Примерная конверсия в километры
      _updateLayers();
    });
  }

  void _onPedometerError(error) {
    print("Pedometer Error: $error");
    _showMessage("Pedometer Error: $error");
  }

  void _pauseWorkout() {
    if (!mounted) return;
    setState(() {
      isPaused = true;
      pauseStartTime = DateTime.now();
    });
  }

  void _resumeWorkout() {
    if (!mounted) return;
    setState(() {
      isPaused = false;
      pauseStartTime = null;
    });
  }

  Future<void> _endWorkout() async {
    if (!isRunning || !mounted) return;

    timer?.cancel();
    _stepCountSubscription?.cancel();
    final endTime = DateTime.now();

    try {
      if (workoutStartTime != null) {
        bool success = await healthService.saveWorkoutToHealth(
          workoutStartTime: workoutStartTime!,
          workoutEndTime: endTime,
          context: context,
          workoutType: 'running',
          steps: totalSteps,
          distance: distance,
        );

        if (!success) {
          _showMessage("Failed to save workout");
        }
      }
    } catch (e) {
      _showMessage("Save error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isRunning = false;
          isPaused = false;
          workoutStartTime = null;
        });
      }
    }
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  String _formatDistance() {
    return '${distance.toStringAsFixed(2)} км';
  }

  void _updateLayers() {
    if (distance > 0 && elapsedSeconds > 0) {
      double durationInMinutes = elapsedSeconds / 60.0;
      List<int> result = LayerCalculator.calculateRunningLayer(distance, durationInMinutes);

      setState(() {
        currentLayer = result[0];
        currentSubLayer = result[1];
        finalRemainder = result[2];
      });
    } else {
      setState(() {
        currentLayer = 0;
        currentSubLayer = 0;
        finalRemainder = 0;
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _stepCountSubscription?.cancel();
    super.dispose();
  }

  Widget _buildWorkoutDisplay() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (!isRunning) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isHealthAvailable ? 'Готовы к тренировке' : 'Health недоступен',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isHealthAvailable ? _startWorkout : null,
            child: Text('Начать тренировку'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Время: ${_formatTime(elapsedSeconds)}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          'Всего шагов: $totalSteps',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 10),
        Text(
          'Дистанция: ${_formatDistance()}',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 30),
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
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (!isPaused)
              ElevatedButton(
                onPressed: _pauseWorkout,
                child: Text('Пауза'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              )
            else
              ElevatedButton(
                onPressed: _resumeWorkout,
                child: Text('Продолжить'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ElevatedButton(
              onPressed: _endWorkout,
              child: Text('Завершить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Беговая тренировка'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _buildWorkoutDisplay(),
          ),
        ),
      ),
    );
  }
}
