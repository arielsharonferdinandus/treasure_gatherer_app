class UserModel {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String password;

  UserModel({
    String? id,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "email": email,
      "phone": phone,
      "password": password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
    );
  }

  ///check if either username or email matches a login identifier.
  bool matchesIdentifier(String identifier) {
    return username.toLowerCase() == identifier.toLowerCase() ||
        email.toLowerCase() == identifier.toLowerCase();
  }
}
