enum UserRole { admin, stockManager, kasir }

class UserModel {
  final String id; // Berasal dari Firebase Auth UID
  final String name;
  final String username;
  final String email;
  final String password;
  final String? profilePictureUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    this.profilePictureUrl,
    required this.role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? password,
    String? profilePictureUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'profile_picture_url': profilePictureUrl,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      profilePictureUrl: map['profile_picture_url'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () =>
            UserRole.admin, // Fallback agar tidak crash jika data corrupt
      ), // Default ke admin jika tidak ada role yang diberikan
    );
  }
}
