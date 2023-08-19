import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lapse/business/event/common/util/common_formats.dart';
import 'package:lapse/business/event/repository/database/database_repository.dart';
import 'package:lapse/business/event/repository/database/schedule.dart';
import 'package:lapse/infra/data/database/model/memory_model.dart';

class ScheduleEventBo {
  int? scheduleId;
  int? eventId;
  bool expired = false;
  String? dayLabel; //昨天
  String? week; //周2
  DateTime? actionAt;
  String? eventTitle;
  String? eventContent;
  List<String>? tagList;
}

class ScheduleState {
  List<ScheduleEventBo>? scheduleEventList;

  ScheduleState({this.scheduleEventList});
}

class ScheduleService extends Cubit<ScheduleState> {
  DatabaseRepository _databaseRepository = DatabaseRepository();
  VoidCallback? listContentCompleted;
  AppLocalizations? localizations;

  ScheduleService() : super(ScheduleState());

  listScheduleEvent({int? tagId}) async {
    if (isClosed) {
      return;
    }

    List<int>? eventIdList = [];
    if (tagId != null) {
      eventIdList = await _databaseRepository.listEventIdsWithTagId([tagId]);
    }
    List<ScheduleWrapperBo>? scheduleWrapperList = await _databaseRepository
        .listScheduleEvent(eventIdList != null ? eventIdList : []);

    List<ScheduleEventBo> scheduleEventList = [];
    DateTime nowAt = DateTime.now();
    scheduleWrapperList?.forEach((wrapperBo) {
      ScheduleEventBo scheduleEventBo = ScheduleEventBo();
      scheduleEventList.add(scheduleEventBo);

      //
      ScheduleModel scheduleModel = wrapperBo.scheduleModel;
      scheduleEventBo.scheduleId = scheduleModel.id;
      DateTime actionAt =
          DateTime.fromMillisecondsSinceEpoch(scheduleModel.actionAt!);
      scheduleEventBo.actionAt = actionAt;
      scheduleEventBo.expired = nowAt.isAfter(actionAt);
      scheduleEventBo.dayLabel =
          CommonFormats.formatDay(localizations!, nowAt, actionAt);
      scheduleEventBo.week = CommonFormats.formatWeek(localizations!, actionAt);

      //Event
      MemoryContentModel? eventModel = wrapperBo.eventModel;
      scheduleEventBo.eventId = eventModel?.id;
      scheduleEventBo.eventTitle = eventModel?.title;
      scheduleEventBo.eventContent = eventModel?.content;

      //TAG
      List<TagModel>? tagModelList = wrapperBo.tagList;
      List<String> tagList = [];
      tagModelList?.forEach((tagModel) {
        tagList.add("#${tagModel.tag!}");
      });
      scheduleEventBo.tagList = tagList;
    });

    //
    emit(ScheduleState(scheduleEventList: scheduleEventList));
    listContentCompleted?.call();
  }

  doneSchedule(int scheduleId, int eventId) async {
    _databaseRepository.doneSchedule(eventId, scheduleId);
    listScheduleEvent();
  }

  removeSchedule(int scheduleId, int eventId) async {
    _databaseRepository.removeSchedule(eventId, scheduleId);
    listScheduleEvent();
  }
}
