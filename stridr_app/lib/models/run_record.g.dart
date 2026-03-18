// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RunRecordAdapter extends TypeAdapter<RunRecord> {
  @override
  final int typeId = 0;

  @override
  RunRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RunRecord(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      distanceMeters: fields[3] as double,
      durationSeconds: fields[4] as int,
      avgPaceSecondsPerMile: fields[5] as double,
      routePoints: (fields[6] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, RunRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.distanceMeters)
      ..writeByte(4)
      ..write(obj.durationSeconds)
      ..writeByte(5)
      ..write(obj.avgPaceSecondsPerMile)
      ..writeByte(6)
      ..write(obj.routePoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
