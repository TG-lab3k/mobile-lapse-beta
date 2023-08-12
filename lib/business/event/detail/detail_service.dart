import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lapse/business/event/repository/calendar_repository.dart';
import 'package:lapse/business/event/repository/database/database_repository.dart';
import 'package:lapse/business/event/repository/database/memory_content.dart';
import 'package:lapse/business/event/repository/database/schedule.dart';

const String _logTag = "#DetailService#";

class DetailService extends Cubit<EventBo> {
  DetailService() : super(EventBo());

  DatabaseRepository _databaseRepository = DatabaseRepository();
  CalendarRepository _calendarRepository = CalendarRepository();

  Future<void> acquireMemoryContent(int contentId) async {
    var contentBo = await _databaseRepository.getMemoryContent(contentId);
    if (contentBo.id == contentId) {
      var scheduleBoList = await _databaseRepository.listSchedule([contentId]);
      List<ScheduleBo> scheduleList = [];
      contentBo.schedules = scheduleList;
      for (var scheduleBo in scheduleBoList) {
        scheduleList.add(scheduleBo);
      }
    }

    print("$_logTag @acquireMemoryContent contentBo: ${contentBo.id}");
    emit(contentBo);
  }

  Future<ScheduleBo> updateScheduleStatus(ScheduleBo scheduleBo) async {
    var updateScheduleBo =
        await _databaseRepository.updateScheduleStatus(scheduleBo);
    return updateScheduleBo;
  }

  Future<void> deleteContent(EventBo memoryContentBo) async {
    if (memoryContentBo.id != null) {
      await _databaseRepository.deleteContent(memoryContentBo.id!);
    }
    _calendarRepository.deleteSchedules(memoryContentBo);
  }
}
