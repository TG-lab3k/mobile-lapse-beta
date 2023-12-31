import 'package:lapse/business/event/repository/database/memory_content.dart';
import 'package:lapse/business/event/repository/database/schedule.dart';
import 'package:lapse/infra/plugin/calendar_plugin.dart';

const AHEAD_MINUTES = 0;
const EVENT_DURATION = Duration(minutes: 30);
class CalendarRepository {
  createSchedules(EventBo memoryContentBo, String location) async {
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
              actionAtMills + EVENT_DURATION.inMilliseconds),
          aheadInMinutes: AHEAD_MINUTES,
        ));
      }
    });
  }

  deleteSchedules(EventBo memoryContentBo) async {
    List<ScheduleBo>? schedules = memoryContentBo.schedules;
    if (schedules == null) {
      return;
    }

    schedules?.forEach((schedule) {
      var actionAtMills = schedule.actionAt;
      var title = memoryContentBo.title;
      if (actionAtMills != null && title != null) {
        CalendarPlugin.deleteEvent(CalendarEvent(
          title: memoryContentBo.title!,
          startAt: DateTime.fromMillisecondsSinceEpoch(actionAtMills),
          endAt: DateTime.fromMillisecondsSinceEpoch(
              actionAtMills + EVENT_DURATION.inMilliseconds),
          aheadInMinutes: AHEAD_MINUTES,
        ));
      }
    });
  }
}
