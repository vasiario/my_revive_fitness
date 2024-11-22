import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:async';

void main() {
  runApp(YogaWorkoutApp());
}

class YogaWorkoutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoga Workout App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: YogaPoseSelectionScreen(),
    );
  }
}

class YogaPoseSelectionScreen extends StatelessWidget {
  final List<String> yogaPoses = [
    'Лотос',
    'Полулотос',
    'Алмазная',
    'На коленях',
    'Бабочка',
    'Стоя',
    'Другая',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите позу йоги'),
      ),
      body: ListView.builder(
        itemCount: yogaPoses.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(yogaPoses[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutScreen(yogaPose: yogaPoses[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class WorkoutScreen extends StatefulWidget {
  final String yogaPose;

  WorkoutScreen({required this.yogaPose});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final health = Health();
  bool isWorkoutActive = false;
  DateTime? workoutStartTime;
  DateTime? workoutEndTime;
  late Stopwatch stopwatch;
  late Timer timer;
  int elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _authorizeHealth();
  }

  /// Запрашиваем разрешение на запись данных
  Future<void> _authorizeHealth() async {
    final types = [HealthDataType.WORKOUT];
    final permissions = [HealthDataAccess.WRITE];

    bool granted = await health.requestAuthorization(types, permissions: permissions);

    if (granted) {
      print("Health permissions granted.");
    } else {
      print("Health permissions denied.");
    }
  }

  /// Начало тренировки
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

  /// Завершение тренировки
  Future<void> _endWorkoutSession() async {
    setState(() {
      isWorkoutActive = false;
      workoutEndTime = DateTime.now();
    });
    stopwatch.stop();
    timer.cancel();

    if (workoutStartTime != null && workoutEndTime != null) {
      await _saveWorkoutToHealth();
    }
  }

  /// Сохранение тренировки в Apple Health или Google Fit
  Future<void> _saveWorkoutToHealth() async {
    try {
      bool success = await health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.YOGA,
        start: workoutStartTime!,
        end: workoutEndTime!,
        totalEnergyBurned: 200, // Пример: 200 калорий
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      );

      if (success) {
        print("Workout saved successfully to Health.");
        _showMessage("Тренировка успешно записана!");
      } else {
        print("Failed to save workout to Health.");
        _showMessage("Не удалось записать тренировку.");
      }
    } catch (e) {
      print("Error saving workout: $e");
      _showMessage("Ошибка при записи тренировки: $e");
    }
  }

  /// Форматирование времени в "00:00:00"
  String _formatElapsedTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  /// Показ сообщения на экране
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Тренировка активна',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Время: ${_formatElapsedTime(elapsedSeconds)}',
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
