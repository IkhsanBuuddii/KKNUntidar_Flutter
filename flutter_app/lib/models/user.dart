class User {
  int? id;
  String fullName;
  String nim;
  String email;
  String phone;
  String password; // plain when creating, stored hashed in DB

  User({this.id, required this.fullName, required this.nim, required this.email, required this.phone, required this.password});

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'full_name': fullName,
      'nim': nim,
      'email': email,
      'phone': phone,
      'password': password,
    };
    if (id != null) m['id'] = id;
    return m;
  }

  static User fromMap(Map<String, dynamic> m) => User(
    id: m['id'] as int?,
    fullName: m['full_name'] ?? '',
    nim: m['nim'] ?? '',
    email: m['email'] ?? '',
    phone: m['phone'] ?? '',
    password: m['password'] ?? '',
  );
}
