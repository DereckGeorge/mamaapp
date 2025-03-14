class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool isFirstTimeUser;
  final UserPregnancyData? pregnancyData;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.isFirstTimeUser = true,
    this.pregnancyData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      isFirstTimeUser: json['isFirstTimeUser'] ?? true,
      pregnancyData: json['pregnancyData'] != null
          ? UserPregnancyData.fromJson(json['pregnancyData'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isFirstTimeUser': isFirstTimeUser,
      'pregnancyData': pregnancyData?.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    bool? isFirstTimeUser,
    UserPregnancyData? pregnancyData,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isFirstTimeUser: isFirstTimeUser ?? this.isFirstTimeUser,
      pregnancyData: pregnancyData ?? this.pregnancyData,
    );
  }
}

class UserPregnancyData {
  final DateTime dueDate;
  final int weeksPregnant;
  final String pregnancyStage; 
  final List<String> symptoms;
  final List<String> healthConditions;
  final bool isFirstChild;
  final String? babyGender;

  UserPregnancyData({
    required this.dueDate,
    required this.weeksPregnant,
    required this.pregnancyStage,
    this.symptoms = const [],
    this.healthConditions = const [],
    this.isFirstChild = true,
    this.babyGender,
  });

  factory UserPregnancyData.fromJson(Map<String, dynamic> json) {
    return UserPregnancyData(
      dueDate: DateTime.parse(json['dueDate']),
      weeksPregnant: json['weeksPregnant'],
      pregnancyStage: json['pregnancyStage'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      healthConditions: List<String>.from(json['healthConditions'] ?? []),
      isFirstChild: json['isFirstChild'] ?? true,
      babyGender: json['babyGender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dueDate': dueDate.toIso8601String(),
      'weeksPregnant': weeksPregnant,
      'pregnancyStage': pregnancyStage,
      'symptoms': symptoms,
      'healthConditions': healthConditions,
      'isFirstChild': isFirstChild,
      'babyGender': babyGender,
    };
  }

  UserPregnancyData copyWith({
    DateTime? dueDate,
    int? weeksPregnant,
    String? pregnancyStage,
    List<String>? symptoms,
    List<String>? healthConditions,
    bool? isFirstChild,
    String? babyGender,
  }) {
    return UserPregnancyData(
      dueDate: dueDate ?? this.dueDate,
      weeksPregnant: weeksPregnant ?? this.weeksPregnant,
      pregnancyStage: pregnancyStage ?? this.pregnancyStage,
      symptoms: symptoms ?? this.symptoms,
      healthConditions: healthConditions ?? this.healthConditions,
      isFirstChild: isFirstChild ?? this.isFirstChild,
      babyGender: babyGender ?? this.babyGender,
    );
  }
} 