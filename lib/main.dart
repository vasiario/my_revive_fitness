import 'package:flutter/material.dart';
import 'screens/yoga_pose_selection_screen.dart';

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
