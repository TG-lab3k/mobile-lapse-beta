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

  static Future<bool> addEvent(CalendarEvent event) async {
    return _channel
        .invokeMethod<bool?>('createCalendarEvent', event.toJson())
        .then((value) => value ?? false);
  }

  static Future<bool> deleteEvent(CalendarEvent event) async {
    return _channel
        .invokeMethod<bool?>('deleteCalendarEvent', event.toJson())
        .then((value) => value ?? false);
  }
}
