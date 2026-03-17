class UserModel {
  final String userId;
  final String username;
  final String role;

  const UserModel({
    required this.userId,
    required this.username,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: (map['userId'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      role: (map['role'] ?? '').toString(),
    );
  }
}

