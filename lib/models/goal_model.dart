class GoalModel {
  final int id;
  final String title;
  final double targetWeightKg;
  final DateTime? targetDate;
  final bool isActive;
  final DateTime? createdAt;
  const GoalModel(
      {required this.id,
      required this.title,
      required this.targetWeightKg,
      this.targetDate,
      required this.isActive,
      this.createdAt});
  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
        id: (json['id'] as num).toInt(),
        title: json['title'].toString(),
        targetWeightKg: (json['target_weight_kg'] as num).toDouble(),
        targetDate: json['target_date'] == null
            ? null
            : DateTime.tryParse(json['target_date'].toString()),
        isActive: json['is_active'] == true,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'].toString()),
      );
}
