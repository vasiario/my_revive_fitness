import 'package:flutter/material.dart';
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
  bool isWorkoutActive = true;
  int currentLayer = 0;
  int currentSubLayer = 0;
  int finalRemainder = 0;
  double valueFromList = 0.56;
  int totalProgress = 0;
  late Stopwatch stopwatch;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch()..start();
    timer = Timer.periodic(Duration(seconds: 1), _updateWorkout);
  }

  @override
  void dispose() {
    timer.cancel();
    stopwatch.stop();
    super.dispose();
  }

  void _updateWorkout(Timer timer) {
    setState(() {
      double currentDuration = stopwatch.elapsed.inSeconds / 60;

      // Применяем формулу
      final result = calculateStaticsLayer(currentDuration, valueFromList);
      currentLayer = result[0];
      currentSubLayer = result[1];
      finalRemainder = result[2];

      // Рассчитываем общий прогресс до 100%
      totalProgress = ((currentLayer * 7 + currentSubLayer) / (5 * 7) * 100).toInt();

      // Логируем все вычисления
      print('Текущее время (мин): $currentDuration');
      print('Значение позы: $valueFromList');
      print('Рассчитанное cleaned: ${currentDuration * valueFromList}');
      print('Текущий слой (wholePart): $currentLayer');
      print('Текущий подслой (remainder): $currentSubLayer');
      print('Остаток в процентах (finalRemainder): $finalRemainder%');
      print('Общий прогресс: $totalProgress%');

      // Завершаем тренировку, если все слои завершены
      if (totalProgress >= 100) {
        isWorkoutActive = false;
        stopwatch.stop();
        timer.cancel();
        print('Тренировка завершена!');
      }
    });
  }

  /// Формула `calculateStaticsLayer`
  List<int> calculateStaticsLayer(double currentDuration, double valueFromList) {
    if (currentDuration == 0) return [0, 0, 0];

    double cleaned = currentDuration * valueFromList;
    int wholePart = (cleaned / 7).floor();
    int remainder = (cleaned % 7).floor();
    double fractionalPart = cleaned % 1;
    int finalRemainder = (fractionalPart * 100).toInt();

    return [wholePart, remainder, finalRemainder];
  }

  /// Форматируем время в `00:00:00`
  String formatElapsedTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тренировка'),
      ),
      body: Center(
        child: isWorkoutActive
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Поза: ${widget.yogaPose}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Слой: $currentLayer',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Подслой: $currentSubLayer',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Общий прогресс: $totalProgress%',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Время: ${formatElapsedTime(stopwatch.elapsed.inSeconds)}',
              style: TextStyle(fontSize: 24),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Тренировка завершена!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Вернуться к выбору позы'),
            ),
          ],
        ),
      ),
    );
  }
}