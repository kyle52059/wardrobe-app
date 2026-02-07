class ClothingItem {
  final String id;
  final String imagePath;      // 原图
  final String? maskedPath;    // 抠图后
  final String category;       // 上衣/裤子/鞋子等
  final DateTime createdAt;

  ClothingItem({
    required this.id,
    required this.imagePath,
    this.maskedPath,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'imagePath': imagePath, 'maskedPath': maskedPath,
    'category': category, 'createdAt': createdAt.toIso8601String(),
  };

  factory ClothingItem.fromJson(Map<String, dynamic> json) => ClothingItem(
    id: json['id'], imagePath: json['imagePath'], maskedPath: json['maskedPath'],
    category: json['category'], createdAt: DateTime.parse(json['createdAt']),
  );
}
