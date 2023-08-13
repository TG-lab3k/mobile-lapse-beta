import 'package:lapse/business/event/repository/database/common.dart';
import 'package:lapse/infra/data/database/model/memory_model.dart';

class ScheduleBo extends BaseBo {
  int? actionAt;
  int? memoryId;
  int? status;
  int? doneAt;
  int? tenantId;

  ScheduleBo(
      {this.actionAt,
      this.memoryId,
      this.status,
      this.doneAt,
      this.tenantId,
      int? id,
      int? serverId,
      int? serverCreateAt,
      int? serverUpdateAt,
      int? createAt,
      int? updateAt})
      : super(
            id: id,
            serverId: serverId,
            serverCreateAt: serverCreateAt,
            serverUpdateAt: serverUpdateAt,
            createAt: createAt,
            updateAt: updateAt);
}

class ScheduleWrapperBo {
  MemoryContentModel? eventModel;
  ScheduleModel scheduleModel;
  List<TagModel>? tagList;

  ScheduleWrapperBo(this.scheduleModel);
}

enum ScheduleStatus {
  todo,
  done,
  overdue;
}
