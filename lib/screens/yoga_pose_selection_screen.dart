import 'package:flutter/material.dart';
import 'yoga_workout_screen.dart';

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
                  builder: (context) =>
                      YogaWorkoutScreen(yogaPose: yogaPoses[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
