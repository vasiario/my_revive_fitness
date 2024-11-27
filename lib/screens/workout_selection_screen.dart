import 'package:flutter/material.dart';
import 'yoga_pose_selection_screen.dart';
import 'running_workout_screen.dart';

class WorkoutSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите тип тренировки'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.self_improvement),
            title: Text('Йога'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => YogaPoseSelectionScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.directions_run),
            title: Text('Бег'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RunningWorkoutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
