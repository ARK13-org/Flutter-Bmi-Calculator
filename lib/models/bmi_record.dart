class BmiRecord {
  final String id;
  final double heightCm;
  final double weightKg;
  final double bmi;
  final DateTime createdAt;

  const BmiRecord({
    required this.id,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    required this.createdAt,
  });

  String get category {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obesity';
  }
}
