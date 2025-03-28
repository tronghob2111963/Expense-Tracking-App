class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String address;
  final String country;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.address,
    required this.country,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'country': country,
    };
  }
}
