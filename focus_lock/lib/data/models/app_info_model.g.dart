// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppInfoModelAdapter extends TypeAdapter<AppInfoModel> {
  @override
  final int typeId = 1;

  @override
  AppInfoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppInfoModel(
      packageName: fields[0] as String,
      appName: fields[1] as String,
      category: fields[2] as String?,
      isBlocked: fields[3] as bool,
      isWhitelisted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppInfoModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.isBlocked)
      ..writeByte(4)
      ..write(obj.isWhitelisted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
