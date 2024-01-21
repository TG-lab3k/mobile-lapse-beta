import 'package:lapse/business/task/data/po/task_po.dart';
import 'package:sqflite/sqflite.dart';

import '../task_data_protocol.dart';
import 'database_helper.dart';

class TaskLocalDatabase extends TaskDataProtocol {
  @override
  Future<CommentPo> createComment(CommentPo commentPo) async {
    final helper = DatabaseHelper();
    Database database = await helper.database;
    int id = await database.transaction((txn) async {
      return await helper.insertComment(txn, commentPo);
    });
    commentPo.id = id;
    return commentPo;
  }

  @override
  Future<TaskPo> createTask(CreateUpdateTaskVo createTaskVo) async {
    final TaskPo taskPo = createTaskVo.task;
    final helper = DatabaseHelper();
    Database database = await helper.database;

    //tag
    List<TagPo>? tagList = createTaskVo.tagList;
    Map<String, TagPo> tagMap = await _createTags(tagList, helper);

    List<TagMappingPo?>? tagMappingList = tagList?.map((e) {
      String? tagName = e.tag;
      TagPo? tagPo = tagMap[tagName];
      if (tagPo != null) {
        return TagMappingPo(tagId: tagPo.id);
      }
      return null;
    }).toList();

    //
    int taskId = await database.transaction((txn) async {
      final int taskId = await helper.insertTask(txn, taskPo);
      List<EventPo>? eventPoList = createTaskVo.eventList;
      eventPoList?.forEach((element) {
        element.taskId = taskId;
      });
      if (eventPoList?.isNotEmpty == true) {
        helper.insertEventList(txn, eventPoList!);
      }
      List<TagMappingPo> mappingList = [];
      tagMappingList?.forEach((tagMappingPo) {
        if (tagMappingPo != null) {
          tagMappingPo.taskId = taskId;
          mappingList.add(tagMappingPo);
        }
      });

      if (mappingList.isNotEmpty) {
        helper.insertTagMappingList(txn, mappingList);
      }

      return taskId;
    });

    taskPo.id = taskId;
    return taskPo;
  }

  Future<Map<String, TagPo>> _createTags(
      List<TagPo>? tagList, DatabaseHelper helper) async {
    List<TagPo> newTagList = [];
    Map<String, TagPo> tagMap = Map();
    tagList?.forEach((tag) {
      if (tag.id == null) {
        newTagList.add(tag);
      } else {
        tagMap[tag.tag!] = tag;
      }
    });

    Database database = await helper.database;
    newTagList.forEach((newTagPo) async {
      String? tagName = newTagPo.tag;
      if (tagName?.isNotEmpty == true) {
        List<String>? tagNameList = tagName?.split("/");
        int? parentId;
        tagNameList?.forEach((tagName) async {
          TagPo? existTag = await helper.findTagWithParent(tagName, parentId);
          if (existTag == null) {
            TagPo tagPo = TagPo(tag: tagName);
            parentId = await database.transaction((txn) {
              return helper.insertTag(txn, tagPo);
            });
          } else {
            parentId = existTag!.id;
          }
        });

        TagPo? tagPo = await helper.getTagById(parentId!);
        tagMap[tagName!] = tagPo!;
      }
    });

    return tagMap;
  }

  @override
  Future<List<EventPo>> getAllTaskRecentUnfinishedEventList(
      List<int> taskIdList) async {
    // TODO: implement getAllTaskRecentUnfinishedEventList
    throw UnimplementedError();
  }

  @override
  Future<List<TagPo>> getAllTaskTagList(List<int> taskIdList) async {
    // TODO: implement getAllTaskTagList
    throw UnimplementedError();
  }

  @override
  Future<List<EventPo>> getExpiredEventList() async {
    // TODO: implement getExpiredEventList
    throw UnimplementedError();
  }

  @override
  Future<List<TaskPo>> getFinishedTaskList() async {
    // TODO: implement getFinishedTaskList
    throw UnimplementedError();
  }

  @override
  Future<List<EventPo>> getFutureEventList() async {
    // TODO: implement getFutureEventList
    throw UnimplementedError();
  }

  @override
  Future<TaskPo> getTask(int taskId) async {
    // TODO: implement getTask
    throw UnimplementedError();
  }

  @override
  Future<List<CommentPo>> getTaskCommentList(int taskId) async {
    // TODO: implement getTaskCommentList
    throw UnimplementedError();
  }

  @override
  Future<List<EventPo>> getTaskEventList(int taskId) async {
    // TODO: implement getTaskEventList
    throw UnimplementedError();
  }

  @override
  Future<List<TagPo>> getTaskTagList(int taskId) async {
    // TODO: implement getTaskTagList
    throw UnimplementedError();
  }

  @override
  Future<List<EventPo>> getTodayEventList() async {
    // TODO: implement getTodayEventList
    throw UnimplementedError();
  }

  @override
  Future<List<TaskPo>> getUnfinishedTaskList() async {
    // TODO: implement getUnfinishedTaskList
    throw UnimplementedError();
  }

  @override
  Future<void> updateEvent(EventPo eventPo) async {
    // TODO: implement updateEvent
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(CreateUpdateTaskVo updateTaskVo) async {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}
