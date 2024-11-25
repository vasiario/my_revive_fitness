import 'package:flutter/material.dart';
import 'package:health/health.dart';

class HealthService {
  final health = Health();

  Future<void> authorizeHealth(BuildContext context) async {
    try {
      bool isAvailable =
          await health.isDataTypeAvailable(HealthDataType.WORKOUT);

      if (!isAvailable) {
        _showMessage(context, "Health Connect недоступен. Установите приложение.");
        return;
      }

      final types = [HealthDataType.WORKOUT];
      final permissions = [HealthDataAccess.WRITE];

      bool granted = await health.requestAuthorization(types, permissions: permissions);

      if (granted) {
        print("Health permissions granted.");
      } else {
        print("Health permissions denied.");
        _showMessage(context, "Разрешения отклонены.");
      }
    } catch (e) {
      print("Ошибка авторизации Health Connect: $e");
      _showMessage(context, "Ошибка авторизации: $e");
    }
  }

  Future<void> saveWorkoutToHealth({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
    required BuildContext context,
  }) async {
    try {
      bool success = await health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.YOGA,
        start: workoutStartTime,
        end: workoutEndTime,
        totalEnergyBurned: 200,
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      );

      if (success) {
        print("Workout saved successfully to Health.");
        _showMessage(context, "Тренировка успешно записана!");
      } else {
        print("Failed to save workout to Health.");
        _showMessage(context, "Не удалось записать тренировку.");
      }
    } catch (e) {
      print("Error saving workout: $e");
      _showMessage(context, "Ошибка при записи тренировки: $e");
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
