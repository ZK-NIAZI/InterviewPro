// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EvaluationModelAdapter extends TypeAdapter<EvaluationModel> {
  @override
  final int typeId = 4;

  @override
  EvaluationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EvaluationModel(
      interviewId: fields[0] as String,
      candidateName: fields[1] as String,
      role: fields[2] as String,
      level: fields[3] as String,
      evaluationDate: fields[4] as DateTime,
      communicationSkills: fields[5] as int,
      problemSolvingApproach: fields[6] as int,
      culturalFit: fields[7] as int,
      overallImpression: fields[8] as int,
      additionalComments: fields[9] as String,
      calculatedScore: fields[10] as double,
    );
  }

  @override
  void write(BinaryWriter writer, EvaluationModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.interviewId)
      ..writeByte(1)
      ..write(obj.candidateName)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.evaluationDate)
      ..writeByte(5)
      ..write(obj.communicationSkills)
      ..writeByte(6)
      ..write(obj.problemSolvingApproach)
      ..writeByte(7)
      ..write(obj.culturalFit)
      ..writeByte(8)
      ..write(obj.overallImpression)
      ..writeByte(9)
      ..write(obj.additionalComments)
      ..writeByte(10)
      ..write(obj.calculatedScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
