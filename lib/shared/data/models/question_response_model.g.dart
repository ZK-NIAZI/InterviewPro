// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_response_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionResponseModelAdapter extends TypeAdapter<QuestionResponseModel> {
  @override
  final int typeId = 2;

  @override
  QuestionResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionResponseModel(
      questionId: fields[0] as String,
      isCorrect: fields[1] as bool,
      notes: fields[2] as String?,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionResponseModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.isCorrect)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
