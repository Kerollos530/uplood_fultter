class UserModel {
  final String id;
  final String name;
  final String email;
  final String status;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
    this.status = 'Active',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['user_id'],
      name: json['name'],
      email: json['email'],
      status: json['status'] ?? 'Active',
      isAdmin: json['isAdmin'] ?? json['is_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status,
      'isAdmin': isAdmin,
    };
  }
}
