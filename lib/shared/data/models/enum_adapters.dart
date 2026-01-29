import 'package:hive/hive.dart';
import '../../domain/entities/entities.dart';

/// Hive adapter for Role enum
class RoleAdapter extends TypeAdapter<Role> {
  @override
  final int typeId = 10;

  @override
  Role read(BinaryReader reader) {
    final index = reader.readByte();
    return Role.values[index];
  }

  @override
  void write(BinaryWriter writer, Role obj) {
    writer.writeByte(obj.index);
  }
}

/// Hive adapter for Level enum
class LevelAdapter extends TypeAdapter<Level> {
  @override
  final int typeId = 11;

  @override
  Level read(BinaryReader reader) {
    final index = reader.readByte();
    return Level.values[index];
  }

  @override
  void write(BinaryWriter writer, Level obj) {
    writer.writeByte(obj.index);
  }
}

/// Hive adapter for QuestionCategory enum
class QuestionCategoryAdapter extends TypeAdapter<QuestionCategory> {
  @override
  final int typeId = 12;

  @override
  QuestionCategory read(BinaryReader reader) {
    final index = reader.readByte();
    return QuestionCategory.values[index];
  }

  @override
  void write(BinaryWriter writer, QuestionCategory obj) {
    writer.writeByte(obj.index);
  }
}

/// Hive adapter for InterviewStatus enum
class InterviewStatusAdapter extends TypeAdapter<InterviewStatus> {
  @override
  final int typeId = 13;

  @override
  InterviewStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return InterviewStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, InterviewStatus obj) {
    writer.writeByte(obj.index);
  }
}
