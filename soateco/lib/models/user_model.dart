class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? admissionNumber;
  final String? ntaLevel;
  final String? course;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.admissionNumber,
    this.ntaLevel,
    this.course,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'student',
      admissionNumber: map['admissionNumber'],
      ntaLevel: map['ntaLevel'],
      course: map['course'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'admissionNumber': admissionNumber,
      'ntaLevel': ntaLevel,
      'course': course,
      'createdAt': createdAt,
    };
  }
}
