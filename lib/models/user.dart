class User {
  final String id;
  final String avatar;
  final String email;
  final String fullname;
  final bool emailVerified;
  final String? birthday;
  final String? cccd;
  final String? status;

  User({
    required this.id,
    required this.email,
    required this.avatar,
    required this.fullname,
    required this.emailVerified,
    this.birthday,
    this.cccd,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        avatar: json['avatar'] ?? '',
        fullname: json['fullname'],
        emailVerified: json['verified'] ?? false,
        birthday: json['birthday'],
        cccd: json['cccd'],
        status: json['status'],
      );
}
