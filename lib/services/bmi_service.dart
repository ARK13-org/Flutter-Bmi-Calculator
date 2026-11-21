import '../models/bmi_record.dart';
import 'api_client.dart';

class BmiService {
  BmiService._();
  static final instance = BmiService._();
  final _api = ApiClient.instance;

  Future<BmiRecord> create(
      {required double heightCm,
      required double weightKg,
      String? note}) async {
    final data = await _api.post('/bmi/records',
        body: {'height_cm': heightCm, 'weight_kg': weightKg, 'note': note});
    return BmiRecord.fromJson(data as Map<String, dynamic>);
  }

  Future<List<BmiRecord>> history() async {
    final data = await _api.get('/bmi/records');
    return (data as List)
        .map((e) => BmiRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BmiRecord> update(int id,
      {required double heightCm,
      required double weightKg,
      String? note}) async {
    final data = await _api.patch('/bmi/records/$id',
        body: {'height_cm': heightCm, 'weight_kg': weightKg, 'note': note});
    return BmiRecord.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete('/bmi/records/$id');
  Future<Map<String, dynamic>> compare() async =>
      Map<String, dynamic>.from(await _api.get('/bmi/compare') as Map);
  Future<Map<String, dynamic>> statistics() async =>
      Map<String, dynamic>.from(await _api.get('/bmi/statistics') as Map);
  Future<Map<String, dynamic>> dashboard() async =>
      Map<String, dynamic>.from(await _api.get('/dashboard') as Map);
}
