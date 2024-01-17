import 'package:lapse/business/task/data/po/task_po.dart';

import '../task_data_protocol.dart';

class TaskLocalDatabase extends TaskDataProtocol {
  @override
  createComment(CommentPo commentPo) {
    // TODO: implement createComment
    throw UnimplementedError();
  }

  @override
  createTask(CreateUpdateTaskVo createTaskVo) {
    // TODO: implement createTask
    throw UnimplementedError();
  }

  @override
  List<EventPo> getAllTaskRecentUnfinishedEventList(List<int> taskIdList) {
    // TODO: implement getAllTaskRecentUnfinishedEventList
    throw UnimplementedError();
  }

  @override
  List<TagPo> getAllTaskTagList(List<int> taskIdList) {
    // TODO: implement getAllTaskTagList
    throw UnimplementedError();
  }

  @override
  List<EventPo> getExpiredEventList() {
    // TODO: implement getExpiredEventList
    throw UnimplementedError();
  }

  @override
  List<TaskPo> getFinishedTaskList() {
    // TODO: implement getFinishedTaskList
    throw UnimplementedError();
  }

  @override
  List<EventPo> getFutureEventList() {
    // TODO: implement getFutureEventList
    throw UnimplementedError();
  }

  @override
  TaskPo getTask(int taskId) {
    // TODO: implement getTask
    throw UnimplementedError();
  }

  @override
  List<CommentPo> getTaskCommentList(int taskId) {
    // TODO: implement getTaskCommentList
    throw UnimplementedError();
  }

  @override
  List<EventPo> getTaskEventList(int taskId) {
    // TODO: implement getTaskEventList
    throw UnimplementedError();
  }

  @override
  List<TagPo> getTaskTagList(int taskId) {
    // TODO: implement getTaskTagList
    throw UnimplementedError();
  }

  @override
  List<EventPo> getTodayEventList() {
    // TODO: implement getTodayEventList
    throw UnimplementedError();
  }

  @override
  List<TaskPo> getUnfinishedTaskList() {
    // TODO: implement getUnfinishedTaskList
    throw UnimplementedError();
  }

  @override
  updateEvent(EventPo eventPo) {
    // TODO: implement updateEvent
    throw UnimplementedError();
  }

  @override
  updateTask(CreateUpdateTaskVo updateTaskVo) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}
