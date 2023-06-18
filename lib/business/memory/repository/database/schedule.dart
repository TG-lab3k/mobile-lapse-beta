import 'package:lapse/business/memory/repository/database/common.dart';

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

enum ScheduleStatus {
  todo,
  done,
  overdue;
}
