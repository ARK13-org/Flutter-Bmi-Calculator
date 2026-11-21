import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  UserService._();
  static final instance = UserService._();
  final _api = ApiClient.instance;
  Future<UserModel> getProfile() async => UserModel.fromJson(
      await _api.get('/users/profile') as Map<String, dynamic>);
  Future<UserModel> updateProfile(
      {String? name, int? age, double? heightCm}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (age != null) body['age'] = age;
    if (heightCm != null) body['height_cm'] = heightCm;
    return UserModel.fromJson(
        await _api.patch('/users/profile', body: body) as Map<String, dynamic>);
  }
}
