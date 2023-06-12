import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:lapse/business/memory/repository/database/memory_content.dart';
import 'package:lapse/business/memory/repository/database/schedule.dart';

class CalendarRepository {
  createSchedules(MemoryContentBo memoryContentBo, String location) async {
    List<ScheduleBo>? schedules = memoryContentBo.schedules;
    if (schedules == null) {
      return;
    }

    var startAtDuration = Duration(minutes: 10);
    var endAtDuration = Duration(minutes: 5);
    schedules?.forEach((schedule) {
      var actionAtMills = schedule.actionAt;
      var title = memoryContentBo.title;
      if (actionAtMills != null && title != null) {
        Add2Calendar.addEvent2Cal(Event(
          title: memoryContentBo.title!,
          description: memoryContentBo.content,
          location: location,
          startDate: DateTime.fromMillisecondsSinceEpoch(
              actionAtMills - startAtDuration.inMilliseconds),
          endDate: DateTime.fromMillisecondsSinceEpoch(
              actionAtMills - endAtDuration.inMilliseconds),
          iosParams: IOSParams(
            reminder: Duration(minutes: 5),
            url: "https://www.baidu.com",
            // on iOS, you can set alarm notification after your event.
          ),
          androidParams: AndroidParams(
            emailInvites: ["leigt3@outlook.com"]
          ),
        ));
      }
    });
  }
}
