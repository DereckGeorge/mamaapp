class MamaTip {
  final int id;
  final String name;
  final String tipContent;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;

  MamaTip({
    required this.id,
    required this.name,
    required this.tipContent,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MamaTip.fromJson(Map<String, dynamic> json) {
    return MamaTip(
      id: json['id'],
      name: json['name'],
      tipContent: json['tip_content'],
      image: json['image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
