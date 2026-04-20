class UsageLogModel {
  final int id;
  final int userId;
  final int applianceId;
  final double hours;
  final String date;
  final double carbonEmission;
  final String createdAt;

  UsageLogModel({
    required this.id,
    required this.userId,
    required this.applianceId,
    required this.hours,
    required this.date,
    required this.carbonEmission,
    required this.createdAt,
  });

  factory UsageLogModel.fromJson(Map<String, dynamic> json) {
    return UsageLogModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      applianceId: json['appliance_id'] as int,
      hours: (json['hours'] as num).toDouble(),
      date: json['date'] as String,
      carbonEmission: (json['carbon_emission'] as num).toDouble(),
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'appliance_id': applianceId,
      'hours': hours,
      'date': date,
      'carbon_emission': carbonEmission,
      'created_at': createdAt,
    };
  }
}

class UsageLogCreate {
  final int applianceId;
  final double hours;
  final String date;

  UsageLogCreate({
    required this.applianceId,
    required this.hours,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'appliance_id': applianceId,
      'hours': hours,
      'date': date,
    };
  }
}
