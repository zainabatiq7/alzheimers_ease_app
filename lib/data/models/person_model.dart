class PersonModel {
  final String id;
  final String name;
  final String relationship;
  final List<double> faceEmbedding; // Stores the 192 double values from MobileFaceNet
  final String? imageUrl;

  PersonModel({
    required this.id,
    required this.name,
    required this.relationship,
    required this.faceEmbedding,
    this.imageUrl,
  });

  /// Factory constructor to convert Firebase Firestore document data back into a PersonModel object
  factory PersonModel.fromMap(Map<String, dynamic> map, String docId) {
    return PersonModel(
      id: docId,
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      // Safely parse dynamic elements to double to prevent type casting exceptions
      faceEmbedding: (map['faceEmbedding'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
          <double>[],
      // Fallback check across various legacy field key names
      imageUrl: map['imageUrl'] ?? map['photoUrl'] ?? map['faceImageUrl'],
    );
  }

  /// Converts the PersonModel class instance into a structural Map for writing into Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'faceEmbedding': faceEmbedding,
      'imageUrl': imageUrl,
    };
  }
}