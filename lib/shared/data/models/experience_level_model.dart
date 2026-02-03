import 'package:hive/hive.dart';
import '../../domain/entities/experience_level.dart';

part 'experience_level_model.g.dart';

/// Hive model for experience level data persistence
@HiveType(
  typeId: 3,
) // Using typeId 3 (roles use 0, interviews use 1, questions use 2)
class ExperienceLevelModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int sortOrder;

  @HiveField(4)
  final bool isActive;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  ExperienceLevelModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sortOrder,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from domain entity to model
  factory ExperienceLevelModel.fromEntity(ExperienceLevel entity) {
    return ExperienceLevelModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert from Appwrite document to model
  factory ExperienceLevelModel.fromDocument(Map<String, dynamic> document) {
    return ExperienceLevelModel(
      id: document['\$id'] ?? '',
      title: document['title'] ?? '',
      description: document['description'] ?? '',
      sortOrder: document['sortOrder'] ?? 0,
      isActive: document['isActive'] ?? true,
      createdAt: DateTime.parse(
        document['\$createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        document['\$updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert model to domain entity
  ExperienceLevel toEntity() {
    return ExperienceLevel(
      id: id,
      title: title,
      description: description,
      sortOrder: sortOrder,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert model to Appwrite document format
  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'description': description,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperienceLevelModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ExperienceLevelModel(id: $id, title: $title, description: $description)';
}
