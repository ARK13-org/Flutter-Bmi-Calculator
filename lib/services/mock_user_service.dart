import '../models/user_model.dart';

/// In-memory stand-in for future user/profile API endpoints.
class MockUserService {
  MockUserService._();
  static final instance = MockUserService._();

  final UserModel _user = UserModel(
    id: 'user-001',
    name: 'Alex Morgan',
    email: 'alex@example.com',
    age: 25,
    heightCm: 175,
  );

  Future<UserModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _user;
  }

  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required int age,
    required double heightCm,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _user
      ..name = name
      ..email = email
      ..age = age
      ..heightCm = heightCm;
    return _user;
  }
}
