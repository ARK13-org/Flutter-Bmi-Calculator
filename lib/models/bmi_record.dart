class BmiRecord {
  final int id;
  final double heightCm;
  final double weightKg;
  final double bmi;
  final String category;
  final String? note;
  final DateTime createdAt;

  const BmiRecord(
      {required this.id,
      required this.heightCm,
      required this.weightKg,
      required this.bmi,
      required this.category,
      this.note,
      required this.createdAt});

  factory BmiRecord.fromJson(Map<String, dynamic> json) => BmiRecord(
        id: (json['id'] as num).toInt(),
        heightCm: (json['height_cm'] as num).toDouble(),
        weightKg: (json['weight_kg'] as num).toDouble(),
        bmi: (json['bmi'] as num).toDouble(),
        category: (json['category'] ?? 'Unknown').toString(),
        note: json['note']?.toString(),
        createdAt: DateTime.tryParse((json['measured_at'] ?? '').toString())
                ?.toLocal() ??
            DateTime.now(),
      );
}
