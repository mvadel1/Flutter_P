class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String role;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? 'user',
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'role': role,
      'is_verified': isVerified,
    };
  }
}
