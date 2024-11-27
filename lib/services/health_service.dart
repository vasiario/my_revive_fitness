import 'package:flutter/material.dart';
import 'package:health/health.dart';

class HealthService {
  final Health health = Health();
  static const int STEPS_THRESHOLD = 10;

  Future<bool> authorizeHealth(BuildContext context) async {
    try {
      final types = [
        HealthDataType.WORKOUT,
        HealthDataType.STEPS,
        HealthDataType.DISTANCE_WALKING_RUNNING,
      ];

      final permissions = [
        HealthDataAccess.READ_WRITE,
        HealthDataAccess.READ_WRITE,
        HealthDataAccess.READ_WRITE,
      ];

      // Проверяем существующие разрешения
      bool? hasPermissions = await health.hasPermissions(types, permissions: permissions);

      if (hasPermissions == null || !hasPermissions) {
        hasPermissions = await health.requestAuthorization(types, permissions: permissions);
      }

      if (!hasPermissions) {
        _showMessage(context, "Требуется разрешение на доступ к данным здоровья");
        return false;
      }

      return true;
    } catch (e) {
      print("Ошибка авторизации Health: $e");
      _showMessage(context, "Ошибка авторизации Health: $e");
      return false;
    }
  }

  Future<int> getSteps(DateTime startTime, DateTime endTime) async {
    try {
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.STEPS],
      );

      print("Получено ${healthData.length} записей о шагах");

      int steps = 0;
      for (HealthDataPoint point in healthData) {
        if (point.value is NumericHealthValue) {
          int currentSteps = (point.value as NumericHealthValue).numericValue.toInt();
          if (currentSteps > STEPS_THRESHOLD) {
            steps += currentSteps;
            print("Добавлено шагов: $currentSteps (всего: $steps)");
          }
        }
      }

      return steps;
    } catch (e) {
      print("Ошибка получения шагов: $e");
      return 0;
    }
  }

  Future<bool> saveWorkoutToHealth({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
    required BuildContext context,
    required String workoutType, // Изменяем параметр для указания типа тренировки
    required int steps,
    required double distance,
  }) async {
    try {
      // Определяем тип тренировки
      HealthWorkoutActivityType activityType;
      switch (workoutType.toLowerCase()) {
        case 'yoga':
          activityType = HealthWorkoutActivityType.YOGA;
          break;
        case 'running':
          activityType = HealthWorkoutActivityType.RUNNING;
          break;
        case 'walking':
        default:
          activityType = HealthWorkoutActivityType.WALKING;
          break;
      }

      // Сохраняем тренировку
      bool success = await health.writeWorkoutData(
        activityType: activityType,
        start: workoutStartTime,
        end: workoutEndTime,
        totalEnergyBurned: calculateCalories(steps),
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
        totalDistance: (distance * 1000).round(),
        totalDistanceUnit: HealthDataUnit.METER,
      );

      if (success) {
        _showMessage(context, "Тренировка успешно сохранена!");
      } else {
        _showMessage(context, "Не удалось сохранить тренировку");
      }

      return success;
    } catch (e) {
      print("Ошибка сохранения тренировки: $e");
      _showMessage(context, "Ошибка сохранения тренировки: $e");
      return false;
    }
  }


  int calculateCalories(int steps) {
    return (steps * 0.04).round();
  }

  void _showMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}