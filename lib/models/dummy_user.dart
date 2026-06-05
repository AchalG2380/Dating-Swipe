class DummyUser {
  final int id;
  final String firstName;
  final String lastName;
  final String image;
  final int age;
  final String gender;
  final String city;

  DummyUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.age,
    required this.gender,
    required this.city,
  });

  String get fullName => '$firstName $lastName';

  factory DummyUser.fromJson(Map<String, dynamic> json) {
    String cityVal = 'Unknown';
    if (json['address'] != null && json['address'] is Map) {
      cityVal = json['address']['city'] ?? 'Unknown';
    }

    return DummyUser(
      id: json['id'] as int,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      age: (json['age'] ?? 20) as int,
      gender: (json['gender'] ?? 'unknown') as String,
      city: cityVal,
    );
  }

  Map<String, dynamic> toMap(String status) {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'image': image,
      'age': age,
      'gender': gender,
      'city': city,
      'status': status,
    };
  }

  factory DummyUser.fromMap(Map<String, dynamic> map) {
    return DummyUser(
      id: map['id'] as int,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      image: map['image'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      city: map['city'] as String,
    );
  }
}
