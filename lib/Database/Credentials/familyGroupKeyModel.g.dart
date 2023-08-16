// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'familyGroupKeyModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class familyGroupKeyModelAdapter extends TypeAdapter<familyGroupKeyModel> {
  @override
  final int typeId = 2;

  @override
  familyGroupKeyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return familyGroupKeyModel()
      ..fid = fields[0] as String
      ..key = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, familyGroupKeyModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.fid)
      ..writeByte(1)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is familyGroupKeyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
