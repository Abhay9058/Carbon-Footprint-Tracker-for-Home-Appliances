class ApplianceModel {
  final int id;
  final int userId;
  final String name;
  final String applianceType;
  final double wattage;
  final int quantity;
  final String createdAt;

  ApplianceModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.applianceType,
    required this.wattage,
    required this.quantity,
    required this.createdAt,
  });

  factory ApplianceModel.fromJson(Map<String, dynamic> json) {
    return ApplianceModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      applianceType: json['appliance_type'] as String,
      wattage: (json['wattage'] as num).toDouble(),
      quantity: json['quantity'] as int,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'appliance_type': applianceType,
      'wattage': wattage,
      'quantity': quantity,
      'created_at': createdAt,
    };
  }

  ApplianceModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? applianceType,
    double? wattage,
    int? quantity,
    String? createdAt,
  }) {
    return ApplianceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      applianceType: applianceType ?? this.applianceType,
      wattage: wattage ?? this.wattage,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ApplianceCreate {
  final String name;
  final String applianceType;
  final double wattage;
  final int quantity;

  ApplianceCreate({
    required this.name,
    required this.applianceType,
    required this.wattage,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'appliance_type': applianceType,
      'wattage': wattage,
      'quantity': quantity,
    };
  }
}
