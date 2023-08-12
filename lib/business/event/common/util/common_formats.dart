import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapse/l10n/localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String _logTag = "#CommonFormats#";
const TIME_FORMAT_ZERO = "0";

class CommonFormats {
  static final int oneDayMills = 1000 * 60 * 60 * 24;
  static final DateFormat dHHmmFormat = DateFormat('yyyy-MM-dd HH:mm');

  static String formatRemainingTime(
      DateTime startAt, DateTime endAt, BuildContext context) {
    var startAtInMills = startAt.millisecondsSinceEpoch;
    var endAtInMills = endAt.millisecondsSinceEpoch;
    var durationInMills = endAtInMills - startAtInMills;
    print(
        "$_logTag @formatRemainingTime durationInMills:$durationInMills, startAtInMills: $startAtInMills, endAtInMills: $endAtInMills");
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

    var timeFormat = builder.toString();
    if (timeFormat == minuteString && minutes == 0) {
      timeFormat = TIME_FORMAT_ZERO;
    }
    return timeFormat;
  }

  static String formatWeek(AppLocalizations localizations, DateTime dateTime) {
    var weekName = "";
    switch (dateTime.weekday) {
      case DateTime.monday:
        weekName = localizations.commonMonday;
        break;
      case DateTime.tuesday:
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

  static String formatDay(
      AppLocalizations localizations, DateTime nowAt, DateTime actionAt) {
    int nowYear = nowAt.year;
    int nowMonth = nowAt.month;
    int nowDay = nowAt.day;
    int actionYear = actionAt.year;
    int actionMonth = actionAt.month;
    int actionDay = actionAt.day;
    if (nowYear == actionYear &&
        nowMonth == actionMonth &&
        nowDay == actionDay) {
      return localizations.commonDateToday;
    }

    int nowHour = nowAt.hour;
    int nowMinute = nowAt.minute;
    int nowSecond = nowAt.second;
    int nowMills = nowAt.millisecond;
    int actionHour = actionAt.hour;
    int actionMinute = actionAt.minute;
    int actionSecond = actionAt.second;
    int actionMills = actionAt.millisecond;
    DateTime nowAlign = nowAt.subtract(Duration(
        hours: nowHour,
        minutes: nowMinute,
        seconds: nowSecond,
        milliseconds: nowMills));
    DateTime actionAlign = actionAt.subtract(Duration(
        hours: actionHour,
        minutes: actionMinute,
        seconds: actionSecond,
        milliseconds: actionMills));
    if (nowAt.isAfter(actionAt)) {
      //逾期
      Duration diff = nowAlign.difference(actionAlign);
      int days = diff.inDays;
      if (days == 0) {
        return localizations.commonDateToday;
      } else if (days == 1) {
        return localizations.commonDateBeforeOneDay;
      } else {
        //N天前
        return days.toString() + localizations.commonDateBeforeSeveralDay;
      }
    } else {
      Duration diff = actionAlign.difference(nowAlign);
      int days = diff.inDays;
      if (days == 0) {
        return localizations.commonDateToday;
      } else if (days == 1) {
        return localizations.commonDateAfterOneDay;
      } else {
        //N天后
        return days.toString() + localizations.commonDateAfterSeveralDay;
      }
    }
  }
}
