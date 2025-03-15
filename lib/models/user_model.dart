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
      id: json['id'].toString(),
      name: json['username'] ?? json['name'],
      email: json['email'],
      phone: json['phone_number'],
      isFirstTimeUser: json['is_first_time_user'] ?? true,
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
  final DateTime? firstDayCircle;
  final int? gestationalPeriod;

  UserPregnancyData({
    required this.dueDate,
    this.weeksPregnant = 0,
    this.pregnancyStage = 'First trimester',
    this.symptoms = const [],
    this.healthConditions = const [],
    this.isFirstChild = true,
    this.babyGender,
    this.firstDayCircle,
    this.gestationalPeriod,
  });

  factory UserPregnancyData.fromJson(Map<String, dynamic> json) {
    return UserPregnancyData(
      dueDate: DateTime.parse(json['dueDate']),
      weeksPregnant: json['weeksPregnant'] ?? 0,
      pregnancyStage: json['pregnancyStage'] ?? 'First trimester',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      healthConditions: List<String>.from(json['healthConditions'] ?? []),
      isFirstChild: json['isFirstChild'] ?? true,
      babyGender: json['babyGender'],
      firstDayCircle: json['firstDayCircle'] != null
          ? DateTime.parse(json['firstDayCircle'])
          : null,
      gestationalPeriod: json['gestationalPeriod'],
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
      'firstDayCircle': firstDayCircle?.toIso8601String(),
      'gestationalPeriod': gestationalPeriod,
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
    DateTime? firstDayCircle,
    int? gestationalPeriod,
  }) {
    return UserPregnancyData(
      dueDate: dueDate ?? this.dueDate,
      weeksPregnant: weeksPregnant ?? this.weeksPregnant,
      pregnancyStage: pregnancyStage ?? this.pregnancyStage,
      symptoms: symptoms ?? this.symptoms,
      healthConditions: healthConditions ?? this.healthConditions,
      isFirstChild: isFirstChild ?? this.isFirstChild,
      babyGender: babyGender ?? this.babyGender,
      firstDayCircle: firstDayCircle ?? this.firstDayCircle,
      gestationalPeriod: gestationalPeriod ?? this.gestationalPeriod,
    );
  }
}
