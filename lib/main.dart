import 'package:flutter/material.dart';
import 'screens/workout_selection_screen.dart';

void main() {
  runApp(WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WorkoutSelectionScreen(), // Новый экран
    );
  }
}
