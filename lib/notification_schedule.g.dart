// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationScheduleAdapter extends TypeAdapter<NotificationSchedule> {
  @override
  final int typeId = 0;

  @override
  NotificationSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSchedule(
      day: fields[0] as String,
      hour: fields[1] as int,
      minute: fields[2] as int,
      title: fields[3] as String,
      body: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSchedule obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.hour)
      ..writeByte(2)
      ..write(obj.minute)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.body);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
