import 'package:lapse/business/event/repository/database/common.dart';

class TenantBo extends BaseBo {
  String? tenantName;
  int? birthday;
  int? gender;
  String? icon;

  TenantBo(
      {this.tenantName,
      this.birthday,
      this.gender,
      this.icon,
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
