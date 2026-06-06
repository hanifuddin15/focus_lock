// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeResultModelAdapter extends TypeAdapter<ChallengeResultModel> {
  @override
  final int typeId = 3;

  @override
  ChallengeResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeResultModel(
      id: fields[0] as String,
      type: fields[1] as String,
      timestamp: fields[2] as DateTime,
      success: fields[3] as bool,
      attemptDurationSeconds: fields[4] as int,
      sessionId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeResultModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.success)
      ..writeByte(4)
      ..write(obj.attemptDurationSeconds)
      ..writeByte(5)
      ..write(obj.sessionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
