import '../models/goal_model.dart';
import 'api_client.dart';

class GoalsService {
  GoalsService._();
  static final instance = GoalsService._();
  final _api = ApiClient.instance;
  Future<List<GoalModel>> list() async => (await _api.get('/goals') as List)
      .map((e) => GoalModel.fromJson(e as Map<String, dynamic>))
      .toList();
  Future<GoalModel> create(
          {required String title,
          required double targetWeightKg,
          DateTime? targetDate}) async =>
      GoalModel.fromJson(await _api.post('/goals', body: {
        'title': title,
        'target_weight_kg': targetWeightKg,
        if (targetDate != null)
          'target_date': targetDate.toUtc().toIso8601String()
      }) as Map<String, dynamic>);
  Future<GoalModel> update(int id,
          {bool? isActive, String? title, double? targetWeightKg}) async =>
      GoalModel.fromJson(await _api.patch('/goals/$id', body: {
        if (isActive != null) 'is_active': isActive,
        if (title != null) 'title': title,
        if (targetWeightKg != null) 'target_weight_kg': targetWeightKg
      }) as Map<String, dynamic>);
  Future<void> delete(int id) => _api.delete('/goals/$id');
  Future<Map<String, dynamic>> progress() async =>
      Map<String, dynamic>.from(await _api.get('/goals/progress') as Map);
}
