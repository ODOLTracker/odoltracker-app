class VehicleImage {
  final int id;
  final int detectionID;
  final String imageURL;
  final String cloudinaryPublicID;
  final String verificationStatus;

  VehicleImage({
    required this.id,
    required this.detectionID,
    required this.imageURL,
    required this.cloudinaryPublicID,
    required this.verificationStatus,
  });

  factory VehicleImage.fromJson(Map<String, dynamic> json) {
    return VehicleImage(
      id: json['id'] as int,
      detectionID: json['detectionID'] as int,
      imageURL: json['imageURL'] as String,
      cloudinaryPublicID: json['cloudinaryPublicID'] as String,
      verificationStatus: json['verificationStatus'] as String,
    );
  }
} 