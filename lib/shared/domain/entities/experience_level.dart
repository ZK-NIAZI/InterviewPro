/// Experience level entity representing different levels of professional experience
class ExperienceLevel {
  final String id;
  final String title;
  final String description;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExperienceLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.sortOrder,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperienceLevel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ExperienceLevel(id: $id, title: $title, description: $description)';
}
