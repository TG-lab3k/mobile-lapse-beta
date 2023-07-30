class LearningCurve {
  static final List<Duration> factors = [
    Duration(hours: 1),
    Duration(hours: 8),
    Duration(days: 1),
    Duration(days: 2),
    Duration(days: 6),
    Duration(days: 15)
  ];

  static final List<Duration> diffFactors = [
    Duration(),
    Duration(hours: 7),
    Duration(hours: 16),
    Duration(days: 1),
    Duration(days: 4),
    Duration(days: 9)
  ];

  static final _year = DateTime.now();
  static final breakBeginAt = DateTime(
    _year.year,
  );
  static final breakEndAt = DateTime.now();

  static DateTime _adjustForBreakIfNeeded(DateTime origin) {
    var hour = origin.hour;
    if (hour >= 21) {
      var duration = Duration(hours: hour - 20);
      return origin.subtract(duration);
    } else if (hour < 7) {
      var duration = Duration(hours: 7 - hour);
      return origin.add(duration);
    } else {
      return origin;
    }
  }

  static List<DateTime> memoryCurve(DateTime startAt) {
    var startAtMills = startAt.millisecondsSinceEpoch;
    List<DateTime> memoryCurves = [];
    factors.forEach((factor) {
      var mills = startAtMills + factor.inMilliseconds;
      var newTime = DateTime.fromMillisecondsSinceEpoch(mills);
      newTime = _adjustForBreakIfNeeded(newTime);
      memoryCurves.add(newTime);
    });

    return memoryCurves;
  }

  static List<DateTime> memoryCurveNext(DateTime firstAt, int firstIndex) {
    var length = factors.length;
    List<DateTime> memoryCurves = [];
    if (firstIndex >= 0 && firstIndex < length - 1) {
      var nextIndex = firstIndex + 1;
      var startInMills = firstAt.millisecondsSinceEpoch;
      var newDiffFactors = diffFactors.sublist(nextIndex);
      for (var diff in newDiffFactors) {
        startInMills += diff.inMilliseconds;
        var newTime = DateTime.fromMillisecondsSinceEpoch(startInMills);
        newTime = _adjustForBreakIfNeeded(newTime);
        memoryCurves.add(newTime);
      }
    }
    return memoryCurves;
  }
}
