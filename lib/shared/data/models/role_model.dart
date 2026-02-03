import 'package:equatable/equatable.dart';

/// Role model for Appwrite backend
class RoleModel extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RoleModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create RoleModel from Appwrite document
  factory RoleModel.fromDocument(Map<String, dynamic> document) {
    return RoleModel(
      id: document['\$id'] ?? '',
      name: document['name'] ?? '',
      icon: document['icon'] ?? '',
      description: document['description'] ?? '',
      isActive: document['isActive'] ?? true,
      createdAt: DateTime.parse(
        document['\$createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        document['\$updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert RoleModel to Appwrite document format
  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'icon': icon,
      'description': description,
      'isActive': isActive,
    };
  }

  /// Create a copy with updated fields
  RoleModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    description,
    isActive,
    createdAt,
    updatedAt,
  ];
}
