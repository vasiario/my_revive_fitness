import 'dart:math';

class LayerCalculator {
  static final Map<String, double> yogaPoseValues = {
    'Лотос': 0.56,
    'Полулотос': 0.55,
    'Алмазная': 0.5484,
    'На коленях': 0.53,
    'Бабочка': 0.52,
    'Стоя': 0.51,
    'Другая': 0.50,
  };

  static List<int> calculateYogaLayer(int elapsedSeconds, String yogaPose) {
    double timeInMinutes = elapsedSeconds / 60.0;
    double valueFromList = yogaPoseValues[yogaPose] ?? 0.5;

    print('Calculating Yoga Layer:');
    print('Elapsed time (minutes): $timeInMinutes');
    print('Value from list for pose "$yogaPose": $valueFromList');

    double cleaned = timeInMinutes * valueFromList;

    print('Cleaned value: $cleaned');

    int wholePart = cleaned ~/ 7;
    int remainder = cleaned.truncate() % 7;
    int finalRemainder = ((cleaned % 1) * 100).toInt();

    print('Whole part (layers): $wholePart');
    print('Remainder (sublayers): $remainder');
    print('Final remainder (%): $finalRemainder');

    return [wholePart, remainder, finalRemainder];
  }

  static List<int> calculateRunningLayer(double distanceInKm, double durationInMinutes) {
    if (durationInMinutes == 0) {
      print('Duration is zero, cannot calculate layers.');
      return [0, 0, 0];
    }

    double speed = distanceInKm / durationInMinutes;

    print('Calculating Running Layer:');
    print('Distance (km): $distanceInKm');
    print('Duration (minutes): $durationInMinutes');
    print('Speed (km/min): $speed');

    double layerKmRatio = pow(speed + 1.06, 4).toDouble();
    print('Layer km ratio: $layerKmRatio');

    double cleaned = durationInMinutes * (layerKmRatio * speed);
    print('Cleaned value: $cleaned');

    int wholePart = cleaned ~/ 7;
    int remainder = cleaned.truncate() % 7;
    int finalRemainder = ((cleaned % 1) * 100).toInt();

    print('Whole part (layers): $wholePart');
    print('Remainder (sublayers): $remainder');
    print('Final remainder (%): $finalRemainder');

    return [wholePart, remainder, finalRemainder];
  }
}
