import 'package:lapse/business/memory/repository/database/common.dart';

class ScheduleBo extends BaseBo {
  int? actionAt;
  int? memoryId;
  int? status;
  int? checkAt;
  int? tenantId;

  ScheduleBo(
      {this.actionAt,
      this.memoryId,
      this.status,
      this.checkAt,
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
  idle;
}
