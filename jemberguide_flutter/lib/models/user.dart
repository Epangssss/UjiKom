class User {
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String phone;
  final String address;

  User({
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      password: map['password'],
      fullName: map['fullName'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}
