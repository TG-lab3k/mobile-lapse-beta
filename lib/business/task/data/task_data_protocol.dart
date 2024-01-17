import 'po/task_po.dart';

class CreateUpdateTaskVo {
  TaskPo? task;
  List<EventPo>? eventList;
  List<TagPo>? tagList;
}

abstract class TaskDataProtocol {
  createTask(CreateUpdateTaskVo createTaskVo);

  updateTask(CreateUpdateTaskVo updateTaskVo);

  TaskPo getTask(int taskId);

  List<TaskPo> getUnfinishedTaskList();

  List<TaskPo> getFinishedTaskList();

  List<TagPo> getTaskTagList(int taskId);

  List<TagPo> getAllTaskTagList(List<int> taskIdList);

  updateEvent(EventPo eventPo);

  List<EventPo> getTodayEventList();

  List<EventPo> getExpiredEventList();

  List<EventPo> getFutureEventList();

  List<EventPo> getTaskEventList(int taskId);

  List<EventPo> getAllTaskRecentUnfinishedEventList(List<int> taskIdList);

  createComment(CommentPo commentPo);

  List<CommentPo> getTaskCommentList(int taskId);
}
