import 'package:lapse/business/memory/repository/database/common.dart';
import 'package:lapse/business/memory/repository/database/schedule.dart';

import 'package:lapse/business/memory/repository/database/tag.dart';
import 'package:lapse/business/memory/repository/database/tenant.dart';

class MemoryContentBo extends BaseBo {
  String? title;
  String? content;

  TenantBo? tenant;

  List<TagBo>? tags;

  List<ScheduleBo>? schedules;

  MemoryContentBo(
      {this.title,
      this.content,
      this.tenant,
      this.tags,
      this.schedules,
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
