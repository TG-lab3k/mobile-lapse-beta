import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lapse/business/event/repository/calendar_repository.dart';
import 'package:lapse/business/event/repository/database/database_repository.dart';
import 'package:lapse/business/event/repository/database/memory_content.dart';
import 'package:lapse/business/event/repository/database/tag.dart';

class AddedPageState {
  List<String>? customerTagList;
}

class AddedService extends Cubit<AddedPageState> {
  CalendarRepository _calendarRepository = new CalendarRepository();
  DatabaseRepository _databaseRepository = new DatabaseRepository();

  AddedService() : super(AddedPageState());

  createEventContent(EventBo eventBo, String location) async {
    await _databaseRepository.createEventContent(eventBo);
    await _calendarRepository.createSchedules(eventBo, location);
  }

  getAddedPageInfo() async {
    var tagBoList = await _databaseRepository.listCustomerTags();
    List<String> tagStrList = [];
    tagBoList?.forEach((tagBo) {
      tagStrList.add("#${tagBo.tag}");
    });
    AddedPageState addedPageState = AddedPageState();
    addedPageState.customerTagList = tagStrList;
    emit(addedPageState);
  }
}
