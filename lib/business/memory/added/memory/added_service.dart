import 'package:lapse/business/memory/repository/calendar_repository.dart';
import 'package:lapse/business/memory/repository/database/database_repository.dart';
import 'package:lapse/business/memory/repository/database/memory_content.dart';

class AddedService {
  CalendarRepository _calendarRepository = new CalendarRepository();
  DatabaseRepository _databaseRepository = new DatabaseRepository();

  createMemoryContent(MemoryContentBo memoryContentBo, String location) async {
    await _databaseRepository.createMemoryContent(memoryContentBo);
    await _calendarRepository.createSchedules(memoryContentBo, location);
  }
}
