// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InterviewModelAdapter extends TypeAdapter<InterviewModel> {
  @override
  final int typeId = 0;

  @override
  InterviewModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterviewModel(
      id: fields[0] as String,
      candidateName: fields[1] as String,
      role: fields[2] as Role,
      level: fields[3] as Level,
      startTime: fields[4] as DateTime,
      endTime: fields[5] as DateTime?,
      responses: (fields[6] as List).cast<QuestionResponseModel>(),
      status: fields[7] as InterviewStatus,
      overallScore: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, InterviewModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.candidateName)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.responses)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.overallScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
