import 'po/task_po.dart';

class CreateUpdateTaskVo {
  TaskPo task;
  List<EventPo>? eventList;
  List<TagPo>? tagList;

  CreateUpdateTaskVo(this.task, {this.eventList, this.tagList});
}

class QueriedEventOrTaskVo {
  EventPo eventPo;
  TaskPo taskPo;
  List<TagPo>? tagList;

  QueriedEventOrTaskVo(this.eventPo, this.taskPo, {this.tagList});
}

abstract class TaskDataProtocol {
  Future<TaskPo> createTask(CreateUpdateTaskVo createTaskVo);

  Future<void> updateTask(CreateUpdateTaskVo updateTaskVo);

  Future<TaskPo> getTask(int taskId);

  Future<List<TaskPo>> getUnfinishedTaskList();

  Future<List<TaskPo>> getFinishedTaskList();

  Future<List<TagPo>> getTaskTagList(int taskId);

  Future<List<TagPo>> getAllTaskTagList(List<int> taskIdList);

  Future<void> updateEvent(EventPo eventPo);

  Future<List<EventPo>> getTodayEventList();

  Future<List<EventPo>> getExpiredEventList();

  Future<List<EventPo>> getFutureEventList();

  Future<List<EventPo>> getTaskEventList(int taskId);

  Future<List<EventPo>> getAllTaskRecentUnfinishedEventList(
      List<int> taskIdList);

  Future<CommentPo> createComment(CommentPo commentPo);

  Future<List<CommentPo>> getTaskCommentList(int taskId);
}
