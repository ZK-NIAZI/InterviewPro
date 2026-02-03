import 'package:equatable/equatable.dart';

/// Role entity for domain layer
class Role extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Role({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

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
