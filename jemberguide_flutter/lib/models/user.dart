class User {
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String role;

  User({
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    this.role = 'user',
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'fullName': fullName,
      'email': email,
      'role': role,
    };
  }
}
