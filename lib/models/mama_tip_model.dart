class MamaTip {
  final int id;
  final String name;
  final String tipContent;
  final String? image;
  final List<TipCategory> categories;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MamaTip({
    required this.id,
    required this.name,
    required this.tipContent,
    this.image,
    required this.categories,
    this.createdAt,
    this.updatedAt,
  });

  factory MamaTip.fromJson(Map<String, dynamic> json) {
    return MamaTip(
      id: json['id'],
      name: json['name'],
      tipContent: json['tip_content'],
      image: json['image'],
      categories: (json['categories'] as List?)
              ?.map((category) => TipCategory.fromJson(category))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

class TipCategory {
  final int id;
  final String name;
  final String contents;
  final String? image;

  TipCategory({
    required this.id,
    required this.name,
    required this.contents,
    this.image,
  });

  factory TipCategory.fromJson(Map<String, dynamic> json) {
    return TipCategory(
      id: json['id'],
      name: json['name'],
      contents: json['contents'],
      image: json['image'],
    );
  }
}
