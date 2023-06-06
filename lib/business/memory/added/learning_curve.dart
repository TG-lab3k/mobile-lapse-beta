class LearningCurve {
  static final List<Duration> factors = [
    Duration(minutes: 20),
    Duration(hours: 1),
    Duration(hours: 8),
    Duration(days: 1),
    Duration(days: 2),
    Duration(days: 6),
    Duration(days: 15)
  ];

  static List<DateTime> memoryCurve(DateTime startAt) {
    var startAtMills = startAt.millisecondsSinceEpoch;
    List<DateTime> memoryCurves = [];
    factors.forEach((factor) {
      var mills = startAtMills + factor.inMilliseconds;
      var factorAt = DateTime.fromMillisecondsSinceEpoch(mills);
      memoryCurves.add(factorAt);
    });

    return memoryCurves;
  }
}
