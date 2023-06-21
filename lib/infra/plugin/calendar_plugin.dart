import 'package:flutter/services.dart';

class CalendarEvent {
  String title;
  String? description;
  DateTime startAt;
  DateTime? endAt;
  int? aheadInMinutes;
  String? location;

  CalendarEvent(
      {required this.title,
      this.description,
      required this.startAt,
      this.endAt,
      this.aheadInMinutes,
      this.location});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> params = {
      'title': title,
      'description': description,
      'location': location,
      'startAt': startAt.millisecondsSinceEpoch,
      'endAt': endAt?.millisecondsSinceEpoch,
      'aheadInMinutes': aheadInMinutes
    };
    return params;
  }
}

class CalendarPlugin {
  static const MethodChannel _channel =
      const MethodChannel('plugin.calendarAndAlarm');

  static Future<int?> addEvent(CalendarEvent event) async {
    return await _channel
        .invokeMethod<int?>('createCalendarEvent', event.toJson());
  }

  static Future<int?> deleteEvent(CalendarEvent event) async {
    return await _channel
        .invokeMethod<int?>('deleteCalendarEvent', event.toJson());
  }

  static Future<int?> checkAndRequestCalendarPermission() async {
    return await _channel
        .invokeMethod<int>('checkAndRequestCalendarPermission');
  }
}
