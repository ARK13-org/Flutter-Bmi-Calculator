import '../models/bmi_record.dart';

/// In-memory stand-in for BMI create/read/delete API endpoints.
class MockBmiService {
  MockBmiService._();

  static final instance = MockBmiService._();

  final List<BmiRecord> _records = [
    BmiRecord(
      id: 1,
      heightCm: 175,
      weightKg: 82,
      bmi: 26.78,
      category: 'Overweight',
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
    ),
    BmiRecord(
      id: 2,
      heightCm: 175,
      weightKg: 79,
      bmi: 25.80,
      category: 'Overweight',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  Future<List<BmiRecord>> getHistory() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_records);
  }

  Future<BmiRecord> addRecord({
    required double heightCm,
    required double weightKg,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    final record = BmiRecord(
      id: DateTime.now().microsecondsSinceEpoch,
      heightCm: heightCm,
      weightKg: weightKg,
      bmi: bmi,
      category: _getCategory(bmi),
      createdAt: DateTime.now(),
    );

    _records.insert(0, record);
    return record;
  }

  Future<void> deleteRecord(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _records.removeWhere((record) => record.id == id);
  }

  String _getCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  BmiRecord? get latest => _records.isEmpty ? null : _records.first;

  BmiRecord? get previous => _records.length < 2 ? null : _records[1];
}
