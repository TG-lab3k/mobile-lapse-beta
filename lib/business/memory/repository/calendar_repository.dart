import 'package:lapse/business/memory/repository/database/memory_content.dart';
import 'package:lapse/business/memory/repository/database/schedule.dart';
import 'package:lapse/infra/plugin/calendar_plugin.dart';

class CalendarRepository {
  createSchedules(MemoryContentBo memoryContentBo, String location) async {
    List<ScheduleBo>? schedules = memoryContentBo.schedules;
    if (schedules == null) {
      return;
    }

    var endAtDuration = Duration(minutes: 30);
    schedules?.forEach((schedule) {
      var actionAtMills = schedule.actionAt;
      var title = memoryContentBo.title;
      if (actionAtMills != null && title != null) {
        CalendarPlugin.addEvent(CalendarEvent(
          title: memoryContentBo.title!,
          description: memoryContentBo.content,
          location: location,
          startAt: DateTime.fromMillisecondsSinceEpoch(actionAtMills),
          endAt: DateTime.fromMillisecondsSinceEpoch(
              actionAtMills + endAtDuration.inMilliseconds),
          aheadInMinutes: 5,
        ));
      }
    });
  }
}
