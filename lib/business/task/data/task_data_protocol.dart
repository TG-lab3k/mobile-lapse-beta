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
  List<List<TagPo>>? tagList;

  QueriedEventOrTaskVo(this.eventPo, this.taskPo, {this.tagList});
}

abstract class TaskDataProtocol {
  Future<TaskPo> createTask(CreateUpdateTaskVo createTaskVo);

  Future<void> updateTask(CreateUpdateTaskVo updateTaskVo);

  Future<TaskPo> getTask(int taskId);

  Future<List<QueriedEventOrTaskVo>> getTasksUnfinished();

  Future<List<QueriedEventOrTaskVo>> getTasksFinished();

  Future<List<TagPo>> getTaskTagList(int taskId);

  Future<List<TagPo>> getAllTaskTagList(List<int> taskIdList);

  Future<void> updateEvent(EventPo eventPo);

  Future<List<QueriedEventOrTaskVo>> getEventsToday();

  Future<List<QueriedEventOrTaskVo>> getEventsExpired();

  Future<List<QueriedEventOrTaskVo>> getEventsFuture();

  Future<List<EventPo>> getTaskEventList(int taskId);

  Future<List<EventPo>> getAllTaskRecentUnfinishedEventList(
      List<int> taskIdList);

  Future<CommentPo> createComment(CommentPo commentPo);

  Future<List<CommentPo>> getTaskCommentList(int taskId);
}
