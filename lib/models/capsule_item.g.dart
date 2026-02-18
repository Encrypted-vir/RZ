// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capsule_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CapsuleItemAdapter extends TypeAdapter<CapsuleItem> {
  @override
  final int typeId = 0;

  @override
  CapsuleItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CapsuleItem(
      from: fields[0] as String,
      content: fields[1] as String,
      unlockDate: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CapsuleItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.unlockDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CapsuleItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
