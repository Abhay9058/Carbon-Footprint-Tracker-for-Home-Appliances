class UserModel {
  final int id;
  final String username;
  final String? email;
  final String role;
  final String memberSince;
  final double totalCarbonEmissions;
  final bool darkMode;
  final bool ecoTipsNotifications;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    required this.role,
    required this.memberSince,
    required this.totalCarbonEmissions,
    required this.darkMode,
    required this.ecoTipsNotifications,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'user',
      memberSince: json['member_since'] as String,
      totalCarbonEmissions: (json['total_carbon_emissions'] as num?)?.toDouble() ?? 0.0,
      darkMode: json['dark_mode'] as bool? ?? false,
      ecoTipsNotifications: json['eco_tips_notifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'member_since': memberSince,
      'total_carbon_emissions': totalCarbonEmissions,
      'dark_mode': darkMode,
      'eco_tips_notifications': ecoTipsNotifications,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? role,
    String? memberSince,
    double? totalCarbonEmissions,
    bool? darkMode,
    bool? ecoTipsNotifications,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      memberSince: memberSince ?? this.memberSince,
      totalCarbonEmissions: totalCarbonEmissions ?? this.totalCarbonEmissions,
      darkMode: darkMode ?? this.darkMode,
      ecoTipsNotifications: ecoTipsNotifications ?? this.ecoTipsNotifications,
    );
  }
}
