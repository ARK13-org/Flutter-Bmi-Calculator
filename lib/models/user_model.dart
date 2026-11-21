class UserModel {
  final int id;
  final String name;
  final String email;
  final int? age;
  final double? heightCm;
  final DateTime? createdAt;

  const UserModel(
      {required this.id,
      required this.name,
      required this.email,
      this.age,
      this.heightCm,
      this.createdAt});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] as num).toInt(),
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        age: (json['age'] as num?)?.toInt(),
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'].toString()),
      );
}
