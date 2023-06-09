//

import 'package:lapse/business/memory/repository/database/memory_content.dart';
import 'package:lapse/business/memory/repository/database/tag.dart';
import 'package:lapse/business/memory/repository/database/tenant.dart';
import 'package:lapse/infra/data/database/database_helper.dart';
import 'package:lapse/infra/data/database/model/memory_model.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseRepository {

  MemoryContentBo createMemoryContent(MemoryContentBo memoryContentBo) {
    final TenantBo? tenantBo = memoryContentBo.tenant;
    if (tenantBo == null || tenantBo.id == null) {
      return memoryContentBo;
    }

    //update tag
    List<int> tagIds = [];
    List<TagBo>? tags = memoryContentBo.tags;
    List<TagBo> newTags = [];
    tags?.forEach((tag) {
      if (tag.id != null) {
        tagIds.add(tag.id!);
      } else if (tag.tag != null) {
        newTags.add(tag);
      }
    });

    final DatabaseHelper databaseHelper = DatabaseHelper();
    final Database database = databaseHelper.getWriteDatabase();
    try{
      //Tag
      if (newTags.isNotEmpty) {
        var insertSql = databaseHelper.sqlTagInsert();
        var statement = database.prepare(insertSql);
        List<String> tagLabels = [];
        newTags.forEach((newTag) {
          tagLabels.add(newTag.tag!);
          statement.execute([newTag.tag, tenantBo.id]);
        });
        statement.dispose();

        //
        var selectSql = databaseHelper.sqlTagSelectWithTag(tagLabels);
        statement = database.prepare(selectSql);
        var resultSet = statement.select(tagLabels);
        List<TagModel> tagModels = databaseHelper.mappingTagModel(resultSet);
        tagModels.forEach((tagModel) {
          tagIds.add(tagModel.id!);
        });
        statement.dispose();
      }

      //Content
      var insertSql = databaseHelper.sqlMemoryContentInsert();
      var statement = database.prepare(insertSql);
      statement
          .execute([memoryContentBo.title, memoryContentBo.content, tenantBo.id]);
      statement.dispose();
      var sql = databaseHelper.sqlMemoryContentLastRowId();
      var resultSet = database.select(sql);
      var lastRowId = databaseHelper.mappingLastRowId(resultSet);
      memoryContentBo.id = lastRowId;

      //Tag mapping
      if (tagIds.isNotEmpty) {
        insertSql = databaseHelper.sqlTagMappingInsert();
        statement = database.prepare(insertSql);
        tagIds.forEach((tagId) {
          statement.execute([tagId, lastRowId, tenantBo.id]);
        });
      }

      //Schedule
      var schedules = memoryContentBo.schedules;
      if (schedules?.isNotEmpty == true) {
        insertSql = databaseHelper.sqlScheduleInsert();
        statement = database.prepare(insertSql);
        schedules?.forEach((schedule) {
          statement.execute([
            schedule.actionAt,
            memoryContentBo.id,
            schedule.status,
            tenantBo.id
          ]);
        });
        statement.dispose();
      }
    }finally{
      databaseHelper.release(database);
    }

    return memoryContentBo;
  }
}
