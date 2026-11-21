import 'api_client.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();
  final _api = ApiClient.instance;

  Future<void> register(
      {required String name,
      required String email,
      required String password}) async {
    final data = await _api.post('/auth/register',
        body: {'name': name, 'email': email, 'password': password});
    await _api.saveToken(data['access_token'].toString());
  }

  Future<void> login({required String email, required String password}) async {
    final data = await _api
        .post('/auth/login', body: {'email': email, 'password': password});
    await _api.saveToken(data['access_token'].toString());
  }

  Future<UserModel> me() async {
    final data = await _api.get('/users/profile');
    return UserModel.fromJson(data as Map<String, dynamic>);
  }
}
