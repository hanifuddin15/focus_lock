// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusSessionModelAdapter extends TypeAdapter<FocusSessionModel> {
  @override
  final int typeId = 0;

  @override
  FocusSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusSessionModel(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime?,
      durationMinutes: fields[3] as int,
      blockedApps: (fields[4] as List).cast<String>(),
      wasCompletedFully: fields[5] as bool,
      earlyBreakAttempts: fields[6] as int,
      challengeType: fields[7] as String,
      isActive: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSessionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.blockedApps)
      ..writeByte(5)
      ..write(obj.wasCompletedFully)
      ..writeByte(6)
      ..write(obj.earlyBreakAttempts)
      ..writeByte(7)
      ..write(obj.challengeType)
      ..writeByte(8)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
