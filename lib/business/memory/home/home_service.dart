import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lapse/business/memory/repository/database/database_repository.dart';
import 'package:lapse/business/memory/repository/database/memory_content.dart';

class HomeState {
  List<MemoryContentBo>? memoryContents;

  HomeState({this.memoryContents});
}

class HomeService extends Cubit<HomeState> {
  DatabaseRepository _databaseRepository = DatabaseRepository();

  HomeService() : super(HomeState());

  void listMemoryContents() {
    _databaseRepository.listMemoryContent([1]).then((contentList) {
      emit(HomeState(memoryContents: contentList));
    });
  }
}
