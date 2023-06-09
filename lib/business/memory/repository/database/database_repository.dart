//

import 'package:lapse/business/memory/repository/database/memory_content.dart';
import 'package:lapse/business/memory/repository/database/tag.dart';
import 'package:lapse/business/memory/repository/database/tenant.dart';
import 'package:lapse/infra/data/database/database_helper.dart';
import 'package:lapse/infra/data/database/model/memory_model.dart';

class DatabaseRepository {
  Future<MemoryContentBo> createMemoryContent(
      MemoryContentBo memoryContentBo) async {
    final TenantBo? tenantBo = memoryContentBo.tenant;
    if (tenantBo == null || tenantBo.id == null) {
      return memoryContentBo;
    }

    //update tag
    List<int> tagIds = [];
    List<TagBo>? tags = memoryContentBo.tags;
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
      newTags = await databaseHelper.createTags(newTags);
      newTags.forEach((newTag) {
        tagIds.add(newTag.id!);
      });
    }

    //Content
    var contentModel = await databaseHelper.createContent(MemoryContentModel(
        title: memoryContentBo.title,
        content: memoryContentBo.content,
        tenantId: tenantBo.id));
    memoryContentBo.id = contentModel.id;

    //Tag mapping
    if (tagIds.isNotEmpty) {
      await databaseHelper.createTagMapping(
          contentModel.id!, tagIds, tenantBo.id!);
    }

    //Schedule
    var schedules = memoryContentBo.schedules;
    if (schedules?.isNotEmpty == true) {
      List<ScheduleModel> scheduleModelList = [];
      var scheduleBoList = memoryContentBo.schedules;
      scheduleBoList?.forEach((scheduleBo) {
        scheduleModelList.add(ScheduleModel(
            actionAt: scheduleBo.actionAt,
            memoryId: memoryContentBo.id!,
            status: scheduleBo.status,
            tenantId: tenantBo.id));
      });
      await databaseHelper.createSchedules(
          memoryContentBo.id!, scheduleModelList, tenantBo.id!);
    }

    return memoryContentBo;
  }

  List<TagModel> transformTags(List<TagBo> tagBoList, int tenantId) {
    List<TagModel> tagModelList = [];
    for (var tagBo in tagBoList) {
      tagModelList.add(TagModel(tag: tagBo.tag, tenantId: tenantId));
    }
    return tagModelList;
  }
}
