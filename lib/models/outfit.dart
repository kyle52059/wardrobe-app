class Outfit {
  final String id;
  final String? topId;
  final String? bottomId;
  final String? profilePhotoPath;
  final DateTime createdAt;
  final String? note;

  Outfit({required this.id, this.topId, this.bottomId, this.profilePhotoPath, required this.createdAt, this.note});

  Map<String, dynamic> toJson() => {
    'id': id, 'topId': topId, 'bottomId': bottomId,
    'profilePhotoPath': profilePhotoPath, 'createdAt': createdAt.toIso8601String(), 'note': note,
  };

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
    id: json['id'], topId: json['topId'], bottomId: json['bottomId'],
    profilePhotoPath: json['profilePhotoPath'], createdAt: DateTime.parse(json['createdAt']), note: json['note'],
  );
}
