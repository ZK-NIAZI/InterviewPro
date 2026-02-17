/// Candidate Model for Appwrite Sidecar Sync
class CandidateModel {
  final String id;
  final String name;
  final String email;

  CandidateModel({required this.id, required this.name, required this.email});

  /// Create from Appwrite Document
  factory CandidateModel.fromMap(Map<String, dynamic> map) {
    return CandidateModel(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  /// Convert to Appwrite Map
  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email};
  }
}
