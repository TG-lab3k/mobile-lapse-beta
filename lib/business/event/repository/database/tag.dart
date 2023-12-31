import 'package:lapse/business/event/repository/database/common.dart';

class TagBo extends BaseBo {
  String? tag;
  int? num;
  int? tenantId;
  List<TagBo>? children;

  TagBo(
      {this.tag,
      this.num,
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
