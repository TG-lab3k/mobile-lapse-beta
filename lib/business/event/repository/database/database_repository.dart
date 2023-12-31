//

import 'dart:collection';

import 'package:lapse/business/event/repository/database/memory_content.dart';
import 'package:lapse/business/event/repository/database/schedule.dart';
import 'package:lapse/business/event/repository/database/tag.dart';
import 'package:lapse/business/event/repository/database/tenant.dart';
import 'package:lapse/infra/data/database/database_helper.dart';
import 'package:lapse/infra/data/database/model/memory_model.dart';

class DatabaseRepository {
  Future<EventBo> createEventContent(EventBo eventBo) async {
    final TenantBo? tenantBo = eventBo.tenant;
    if (tenantBo == null || tenantBo.id == null) {
      return eventBo;
    }

    //Update tag
    List<int> tagIds = [];
    List<TagBo>? tags = eventBo.tags;
    List<TagModel> newTags = [];
    tags?.forEach((tag) {
      if (tag.id != null) {
        tagIds.add(tag.id!);
      } else if (tag.tag != null) {
        newTags.add(TagModel(tag: tag.tag, tenantId: tenantBo.id));
      }
    });

    final DatabaseHelper databaseHelper = DatabaseHelper();
    //Tag
    if (newTags.isNotEmpty) {
      newTags = await databaseHelper.saveTags(newTags);
      newTags.forEach((newTag) {
        tagIds.add(newTag.id!);
      });
    }

    //Content
    var contentModel = await databaseHelper.createContent(MemoryContentModel(
        title: eventBo.title, content: eventBo.content, tenantId: tenantBo.id));
    eventBo.id = contentModel.id;

    //Tag mapping
    if (tagIds.isNotEmpty) {
      await databaseHelper.createTagMapping(
          contentModel.id!, tagIds, tenantBo.id!);
    }

    //Schedule
    var schedules = eventBo.schedules;
    if (schedules?.isNotEmpty == true) {
      List<ScheduleModel> scheduleModelList = [];
      var scheduleBoList = eventBo.schedules;
      scheduleBoList?.forEach((scheduleBo) {
        scheduleModelList.add(ScheduleModel(
            actionAt: scheduleBo.actionAt,
            memoryId: eventBo.id!,
            status: scheduleBo.status,
            tenantId: tenantBo.id));
      });
      await databaseHelper.createSchedules(
          eventBo.id!, scheduleModelList, tenantBo.id!);
    }

    return eventBo;
  }

  Future<EventBo> getMemoryContent(int contentId) async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    var contentModel = await databaseHelper.getMemoryContent(contentId);
    var contentBoList = _transformMemoryContent([contentModel]);
    if (contentBoList.length == 0) {
      return EventBo();
    } else {
      return contentBoList[0];
    }
  }

  Future<List<int>?> listEventIdsWithTagId(List<int> tagIds) async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    List<TagMappingModel>? tagMappingList =
        await databaseHelper.listTagMappingListWithTagIds(tagIds);
    var eventIdList = tagMappingList?.map((e) => e.memoryId!).toList();
    return eventIdList;
  }

  Future<List<ScheduleWrapperBo>?> listScheduleEvent(List<int> eventIds) async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    List<ScheduleModel> scheduleList = await databaseHelper
        .listSchedulesWithStatus(eventIds, [ScheduleStatus.todo.index]);

    List<int> eventIdList = List.from(scheduleList.map((e) => e.memoryId));
    List<MemoryContentModel>? eventList =
        await databaseHelper.listEvent(eventIdList);
    Map<int, MemoryContentModel> eventMap = HashMap();
    eventList?.forEach((eventModel) {
      eventMap[eventModel.id!] = eventModel;
    });

    //query tag mapping
    List<TagMappingModel>? tagMappingList =
        await databaseHelper.listTagMappingListWithEventIds(eventIdList);
    Map<int, List<TagMappingModel>> tagMappingMap = HashMap();
    List<int> tagIdList = [];
    tagMappingList?.forEach((tagMapping) {
      var eventId = tagMapping.memoryId!;
      List<TagMappingModel>? eventGroupList = tagMappingMap[eventId];
      if (eventGroupList == null) {
        eventGroupList = [];
        tagMappingMap[eventId] = eventGroupList;
      }
      eventGroupList.add(tagMapping);
      tagIdList.add(tagMapping.tagId!);
    });

    List<TagModel>? tagList = await databaseHelper.listTags(tagIdList);
    Map<int, TagModel> tagMap = HashMap();
    tagList?.forEach((tagModel) {
      tagMap[tagModel.id!] = tagModel;
    });

    List<ScheduleWrapperBo> scheduleWrapperList = [];
    scheduleList.forEach((scheduleModel) {
      ScheduleWrapperBo scheduleWrapperBo = ScheduleWrapperBo(scheduleModel);
      int? eventId = scheduleModel.memoryId;
      MemoryContentModel? eventModel = eventMap[eventId];
      scheduleWrapperBo.eventModel = eventModel;
      List<TagMappingModel>? tagMappingList = tagMappingMap[eventId];
      List<TagModel> tagList = [];
      tagMappingList?.forEach((tagMapping) {
        TagModel? tagModel = tagMap[tagMapping.tagId!];
        if (tagModel != null) {
          tagList.add(tagModel);
        }
      });
      scheduleWrapperBo.tagList = tagList;
      scheduleWrapperList.add(scheduleWrapperBo);
    });
    return scheduleWrapperList;
  }

  Future<List<EventBo>> listMemoryContent(List<int> tenantIds) async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    List<MemoryContentModel> contentModelList =
        await databaseHelper.listMemoryContent(tenantIds);
    var contentBoList = _transformMemoryContent(contentModelList);
    return contentBoList;
  }

  Future<ScheduleBo> updateScheduleStatus(ScheduleBo scheduleBo) async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    var updateScheduleModel = await databaseHelper.updateScheduleStatus(
        ScheduleModel(id: scheduleBo.id, status: scheduleBo.status));
    scheduleBo.doneAt = updateScheduleModel.doneAt;
    scheduleBo.updateAt = updateScheduleModel.updateAt;
    return scheduleBo;
  }

  List<EventBo> _transformMemoryContent(
      List<MemoryContentModel> contentModelList) {
    List<EventBo> contentBoList = [];
    for (var contentModel in contentModelList) {
      contentBoList.add(EventBo(
          title: contentModel.title,
          content: contentModel.content,
          id: contentModel.id,
          serverId: contentModel.serverId,
          serverCreateAt: contentModel.serverCreateAt,
          serverUpdateAt: contentModel.serverUpdateAt,
          createAt: contentModel.createAt,
          updateAt: contentModel.updateAt));
    }

    return contentBoList;
  }

  Future<List<ScheduleBo>> listSchedule(List<int> contentIds) async {
    List<ScheduleBo> scheduleBoList = [];
    if (contentIds.length > 0) {
      final DatabaseHelper databaseHelper = DatabaseHelper();
      var scheduleModelList = await databaseHelper.listSchedules(contentIds);
      for (var scheduleModel in scheduleModelList) {
        scheduleBoList.add(ScheduleBo(
            actionAt: scheduleModel.actionAt,
            memoryId: scheduleModel.memoryId,
            status: scheduleModel.status,
            doneAt: scheduleModel.doneAt,
            tenantId: scheduleModel.tenantId,
            id: scheduleModel.id,
            serverId: scheduleModel.serverId,
            serverCreateAt: scheduleModel.serverCreateAt,
            serverUpdateAt: scheduleModel.serverUpdateAt,
            createAt: scheduleModel.createAt,
            updateAt: scheduleModel.updateAt));
      }
    }
    return scheduleBoList;
  }

  Future<List<TagBo>> listCustomerTags() async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    var tagList = await databaseHelper.listCustomerTags();
    List<TagBo> tagBoList = [];
    tagList?.forEach((tagModel) {
      tagBoList.add(TagBo(
          tag: tagModel.tag,
          num: tagModel.num,
          tenantId: tagModel.tenantId,
          id: tagModel.id,
          serverId: tagModel.serverId,
          serverCreateAt: tagModel.serverCreateAt,
          serverUpdateAt: tagModel.serverUpdateAt,
          createAt: tagModel.createAt,
          updateAt: tagModel.updateAt));
    });
    return tagBoList;
  }

  Future<void> deleteContent(int contentId) async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    databaseHelper.deleteMemoryContent(contentId);
  }

  Future<List<ScheduleBo>> listTodoSchedules() async {
    List<ScheduleBo> scheduleBoList = [];

    return scheduleBoList;
  }

  Future<void> doneSchedule(int eventId, int scheduleId) async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    await databaseHelper.updateScheduleStatus(
        ScheduleModel(id: scheduleId, status: ScheduleStatus.done.index));

    List<ScheduleModel> scheduleList = await databaseHelper
        .listSchedulesWithStatus([eventId], [ScheduleStatus.done.index]);
    if (scheduleList.isEmpty) {
      await databaseHelper.updateEventStatus(eventId, EventStatus.done.index);
    }
  }

  Future<void> removeSchedule(int eventId, int scheduleId) async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    await databaseHelper.deleteScheduleWithId(scheduleId);

    List<ScheduleModel> scheduleList = await databaseHelper
        .listSchedulesWithStatus([eventId], [ScheduleStatus.done.index]);
    if (scheduleList.isEmpty) {
      await databaseHelper.deleteEventWithId(eventId);
    }
  }
}
