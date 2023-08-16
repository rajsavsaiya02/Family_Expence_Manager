// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commanValueModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class commanValueModelAdapter extends TypeAdapter<commanValueModel> {
  @override
  final int typeId = 1;

  @override
  commanValueModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return commanValueModel()
      ..uid = fields[0] as String
      ..email = fields[1] as String
      ..key = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, commanValueModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is commanValueModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
