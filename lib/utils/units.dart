class Units {
  static bool get isImperial => false;
  static double cmToIn(double cm) => cm / 2.54;
  static double inToCm(double inches) => inches * 2.54;
  static double kgToLb(double kg) => kg * 2.2046226218;
  static double lbToKg(double pounds) => pounds / 2.2046226218;
  static String height(double cm, String system) => system == 'imperial'
      ? '${cmToIn(cm).toStringAsFixed(1)} in'
      : '${cm.toStringAsFixed(1)} cm';
  static String weight(double kg, String system) => system == 'imperial'
      ? '${kgToLb(kg).toStringAsFixed(1)} lb'
      : '${kg.toStringAsFixed(1)} kg';
}
