// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experience_level_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExperienceLevelModelAdapter extends TypeAdapter<ExperienceLevelModel> {
  @override
  final int typeId = 3;

  @override
  ExperienceLevelModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExperienceLevelModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      sortOrder: fields[3] as int,
      isActive: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ExperienceLevelModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.sortOrder)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperienceLevelModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
