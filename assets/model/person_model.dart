class PersonModel {
  final String id;
  final String name;
  final String relationship;
  final List<double> faceEmbedding; // The 192 mathematical double values from MobileFaceNet
  final String? imageUrl;

  PersonModel({
    required this.id,
    required this.name,
    required this.relationship,
    required this.faceEmbedding,
    this.imageUrl,
  });

  // Convert Firebase document snapshot data back into a usable object
  factory PersonModel.fromMap(Map<String, dynamic> map, String docId) {
    return PersonModel(
      id: docId,
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      faceEmbedding: List<double>.from(map['faceEmbedding'] ?? []),
      imageUrl: map['imageUrl'],
    );
  }

  // Convert local entity details into a structural Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'faceEmbedding': faceEmbedding,
      'imageUrl': imageUrl,
    };
  }
}