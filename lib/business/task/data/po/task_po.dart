import 'common_po.dart';

enum EventStatus {
  todo,
  done,
}

enum TaskStatus {
  todo,
  done,
}

class EventPo extends BasePo {
  String? actionAt;
  int? eventOrder;
  int? taskId;
  int? status;
  String? doneAt;

  EventPo(
      {int? id,
      String? createAt,
      String? updateAt,
      this.actionAt,
      this.eventOrder,
      this.taskId,
      this.status,
      this.doneAt})
      : super(id: id, createAt: createAt, updateAt: updateAt);
}

class TagPo extends BasePo {
  String? tag;
  int? parentId;
  int? childId;

  TagPo(
      {int? id,
      String? createAt,
      String? updateAt,
      this.tag,
      this.parentId,
      this.childId})
      : super(id: id, createAt: createAt, updateAt: updateAt);
}

class TagMappingPo extends BasePo {
  int? tagId;
  int? taskId;

  TagMappingPo(
      {int? id, String? createAt, String? updateAt, this.tagId, this.taskId})
      : super(id: id, createAt: createAt, updateAt: updateAt);
}

class TaskPo extends BasePo {
  String? title;
  String? content;
  int? repeatType;
  int? status;
  int? creatorId;
  int? assignId;
  int? childId;

  TaskPo(
      {int? id,
      String? createAt,
      String? updateAt,
      this.title,
      this.content,
      this.repeatType,
      this.status,
      this.creatorId,
      this.assignId,
      this.childId})
      : super(id: id, createAt: createAt, updateAt: updateAt);
}

class CommentPo extends BasePo {
  String? comment;
  int? type;
  int? taskId;
  int? eventId;

  CommentPo(
      {int? id,
      String? createAt,
      String? updateAt,
      this.comment,
      this.type,
      this.taskId,
      this.eventId})
      : super(id: id, createAt: createAt, updateAt: updateAt);
}
