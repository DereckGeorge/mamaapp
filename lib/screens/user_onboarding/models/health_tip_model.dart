class HealthTipCategory {
  final String id;
  final String name;
  final String iconPath;
  final String description;

  HealthTipCategory({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.description,
  });

  factory HealthTipCategory.fromJson(Map<String, dynamic> json) {
    return HealthTipCategory(
      id: json['id'],
      name: json['name'],
      iconPath: json['iconPath'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'description': description,
    };
  }
}

class HealthTip {
  final String id;
  final String categoryId;
  final String title;
  final String summary;
  final String content;
  final String? imageUrl;
  final DateTime publishedDate;
  final bool isFeatured;

  HealthTip({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.summary,
    required this.content,
    this.imageUrl,
    required this.publishedDate,
    this.isFeatured = false,
  });

  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'],
      categoryId: json['categoryId'],
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      publishedDate: DateTime.parse(json['publishedDate']),
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'publishedDate': publishedDate.toIso8601String(),
      'isFeatured': isFeatured,
    };
  }
} 