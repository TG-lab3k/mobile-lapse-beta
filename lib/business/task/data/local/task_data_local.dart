import 'package:lapse/business/task/data/po/task_po.dart';
import 'package:sqflite/sqflite.dart';

import '../task_data_protocol.dart';
import 'database_helper.dart';

class TaskLocalDatabase extends TaskDataProtocol {
  @override
  createComment(CommentPo commentPo) {
    // TODO: implement createComment
    throw UnimplementedError();
  }

  @override
  Future<void> createTask(CreateUpdateTaskVo createTaskVo) async {
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
    database.transaction((txn) async {
      final int taskId = await helper.insertTask(txn, taskPo);

      //
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
    });
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
