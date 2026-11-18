import '../models/bmi_record.dart';

/// In-memory stand-in for future BMI create/read/delete API endpoints.
class MockBmiService {
  MockBmiService._();
  static final instance = MockBmiService._();

  final List<BmiRecord> _records = [
    BmiRecord(id: 'seed-1', heightCm: 175, weightKg: 82, bmi: 26.78,
      createdAt: DateTime.now().subtract(const Duration(days: 28))),
    BmiRecord(id: 'seed-2', heightCm: 175, weightKg: 79, bmi: 25.80,
      createdAt: DateTime.now().subtract(const Duration(days: 14))),
  ];

  Future<List<BmiRecord>> getHistory() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_records);
  }

  Future<BmiRecord> addRecord({required double heightCm, required double weightKg}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final heightM = heightCm / 100;
    final record = BmiRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      heightCm: heightCm,
      weightKg: weightKg,
      bmi: weightKg / (heightM * heightM),
      createdAt: DateTime.now(),
    );
    _records.insert(0, record);
    return record;
  }

  Future<void> deleteRecord(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _records.removeWhere((record) => record.id == id);
  }

  BmiRecord? get latest => _records.isEmpty ? null : _records.first;
  BmiRecord? get previous => _records.length < 2 ? null : _records[1];
}
