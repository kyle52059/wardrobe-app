class UserProfile {
  final String? photoPath;     // 用户全身照
  final double? height;        // 身高cm
  final double? weight;        // 体重kg
  final String? bodyType;      // 体型：偏瘦/标准/偏胖

  UserProfile({this.photoPath, this.height, this.weight, this.bodyType});

  Map<String, dynamic> toJson() => {
    'photoPath': photoPath, 'height': height, 'weight': weight, 'bodyType': bodyType,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    photoPath: json['photoPath'], height: json['height']?.toDouble(),
    weight: json['weight']?.toDouble(), bodyType: json['bodyType'],
  );

  UserProfile copyWith({String? photoPath, double? height, double? weight, String? bodyType}) =>
    UserProfile(
      photoPath: photoPath ?? this.photoPath, height: height ?? this.height,
      weight: weight ?? this.weight, bodyType: bodyType ?? this.bodyType,
    );
}
