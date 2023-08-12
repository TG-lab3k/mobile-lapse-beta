import 'package:lapse/business/event/repository/calendar_repository.dart';
import 'package:lapse/business/event/repository/database/database_repository.dart';
import 'package:lapse/business/event/repository/database/memory_content.dart';

class AddedService {
  CalendarRepository _calendarRepository = new CalendarRepository();
  DatabaseRepository _databaseRepository = new DatabaseRepository();

  createEventContent(EventBo eventBo, String location) async {
    await _databaseRepository.createEventContent(eventBo);
    await _calendarRepository.createSchedules(eventBo, location);
  }
}
