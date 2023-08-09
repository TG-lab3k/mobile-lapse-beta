import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lapse/business/memory/common/util/common_formats.dart';
import 'package:lapse/business/memory/repository/database/database_repository.dart';
import 'package:lapse/business/memory/repository/database/schedule.dart';
import 'package:lapse/infra/data/database/model/memory_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  ScheduleService({this.listContentCompleted}) : super(ScheduleState());

  listScheduleEvent() async {
    List<ScheduleWrapperBo>? scheduleWrapperList =
        await _databaseRepository.listScheduleEvent();

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

      //
      MemoryContentModel? eventModel = wrapperBo.eventModel;
      scheduleEventBo.eventId = eventModel?.id;
      scheduleEventBo.eventTitle = eventModel?.title;
      scheduleEventBo.eventContent = eventModel?.content;
    });

    //
    emit(ScheduleState(scheduleEventList: scheduleEventList));
  }
}
