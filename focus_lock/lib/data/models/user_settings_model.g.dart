// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsModelAdapter extends TypeAdapter<UserSettingsModel> {
  @override
  final int typeId = 2;

  @override
  UserSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettingsModel(
      challengeType: fields[0] as String,
      savedBarcodeHash: fields[1] as String?,
      savedBarcodeValue: fields[2] as String?,
      whitelistedApps: (fields[3] as List).cast<String>(),
      weeklyReportEnabled: fields[4] as bool,
      onboardingCompleted: fields[5] as bool,
      subscriptionTier: fields[6] as String,
      defaultDurationMinutes: fields[7] as int,
      lastBlockedApps: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingsModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.challengeType)
      ..writeByte(1)
      ..write(obj.savedBarcodeHash)
      ..writeByte(2)
      ..write(obj.savedBarcodeValue)
      ..writeByte(3)
      ..write(obj.whitelistedApps)
      ..writeByte(4)
      ..write(obj.weeklyReportEnabled)
      ..writeByte(5)
      ..write(obj.onboardingCompleted)
      ..writeByte(6)
      ..write(obj.subscriptionTier)
      ..writeByte(7)
      ..write(obj.defaultDurationMinutes)
      ..writeByte(8)
      ..write(obj.lastBlockedApps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
