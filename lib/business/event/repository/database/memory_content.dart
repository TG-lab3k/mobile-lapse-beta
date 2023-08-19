import 'package:lapse/business/event/repository/database/common.dart';
import 'package:lapse/business/event/repository/database/schedule.dart';

import 'package:lapse/business/event/repository/database/tag.dart';
import 'package:lapse/business/event/repository/database/tenant.dart';

class EventBo extends BaseBo {
  String? title;
  String? content;

  TenantBo? tenant;

  List<TagBo>? tags;

  List<ScheduleBo>? schedules;

  EventBo(
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

enum EventStatus {
  todo,
  done
}
