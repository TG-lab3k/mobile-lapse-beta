import 'package:flutter/material.dart';
import 'package:lapse/l10n/localizations.dart';

class CommonFormats {
  static String formatRemainingTime(
      DateTime startAt, DateTime endAt, BuildContext context) {
    var durationInMills =
        endAt.millisecondsSinceEpoch - startAt.millisecondsSinceEpoch;
    if (durationInMills <= 0) {
      return "";
    }

    var days = durationInMills ~/ Duration.millisecondsPerDay;
    if (days > 0) {
      durationInMills = durationInMills - Duration(days: days).inMilliseconds;
    }
    var hours = durationInMills ~/ Duration.millisecondsPerHour;
    if (hours > 0) {
      durationInMills = durationInMills - Duration(hours: hours).inMilliseconds;
    }
    var minutes = durationInMills ~/ Duration.millisecondsPerMinute;

    var localizations = TextI18ns.from(context);
    var dayString = days.toString() + localizations.commonUnitDay;
    var hourString = hours.toString() + localizations.commonUnitHour;
    var minuteString = minutes.toString() + localizations.commonUnitMinute;
    print(
        "#CommonFormats# formatRemainingTime $dayString, $hourString, $minuteString");
    var builder = StringBuffer("");
    if (days > 0) {
      builder.write(dayString);
    }
    if (hours > 0) {
      builder.write(hourString);
      if (minutes > 0) {
        builder.write(minuteString);
      }
    } else if (days == 0) {
      builder.write(minuteString);
    }
    return builder.toString();
  }

  static String formatWeek(BuildContext context, DateTime dateTime) {
    var localizations = TextI18ns.from(context);
    var weekName = "";
    switch (dateTime.weekday) {
      case DateTime.monday:
        weekName = localizations.commonMonday;
        break;
      case DateTime.thursday:
        weekName = localizations.commonTuesday;
        break;
      case DateTime.wednesday:
        weekName = localizations.commonWednesday;
        break;

      case DateTime.thursday:
        weekName = localizations.commonThursday;
        break;

      case DateTime.friday:
        weekName = localizations.commonFriday;
        break;
      case DateTime.saturday:
        weekName = localizations.commonSaturday;
        break;
      case DateTime.sunday:
        weekName = localizations.commonSunday;
        break;
      default:
        break;
    }
    return weekName;
  }
}