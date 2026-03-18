// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyGoalAdapter extends TypeAdapter<WeeklyGoal> {
  @override
  final int typeId = 1;

  @override
  WeeklyGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyGoal(
      targetMiles: fields[0] as double,
      weekStart: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyGoal obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.targetMiles)
      ..writeByte(1)
      ..write(obj.weekStart);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
