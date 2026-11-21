import '../models/user_model.dart';

/// In-memory stand-in for user/profile API endpoints.
class MockUserService {
  MockUserService._();

  static final instance = MockUserService._();

  static UserModel _user = const UserModel(
    id: 1,
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
    required int age,
    required double heightCm,
    String? email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    // UserModel fields are final, so create a new instance.
    _user = UserModel(
      id: _user.id,
      name: name,
      email: email ?? _user.email,
      age: age,
      heightCm: heightCm,
      createdAt: _user.createdAt,
    );

    return _user;
  }
}
