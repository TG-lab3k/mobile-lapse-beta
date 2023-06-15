import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lapse/business/memory/repository/database/database_repository.dart';
import 'package:lapse/business/memory/repository/database/memory_content.dart';

class HomeState {
  List<MemoryContentBo>? memoryContents;

  HomeState({this.memoryContents});
}

const String _logTag = "#HomeService#";

class HomeService extends Cubit<HomeState> {
  DatabaseRepository _databaseRepository = DatabaseRepository();

  HomeService({this.listContentCompleted}) : super(HomeState());

  VoidCallback? listContentCompleted;

  void listMemoryContents() async {
    var contentBos = await _databaseRepository.listMemoryContent([1]);
    if (contentBos.length > 0) {
      var contentIds =
          contentBos.map((contentBo) => contentBo.id!).toList(growable: false);
      var scheduleBos = await _databaseRepository.listSchedule(contentIds);
      final Map<int, MemoryContentBo> contentBoMap = Map();
      for (var contentBo in contentBos) {
        contentBoMap[contentBo.id!] = contentBo;
      }
      for (var scheduleBo in scheduleBos) {
        var contentId = scheduleBo.memoryId;
        var contentBo = contentBoMap[contentId];
        if (contentBo != null) {
          var cntBo = contentBo!;
          if (cntBo.schedules == null) {
            cntBo.schedules = [];
          }
          cntBo.schedules?.add(scheduleBo);
        }
      }
    }
    listContentCompleted?.call();
    emit(HomeState(memoryContents: contentBos));
  }
}
