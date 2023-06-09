class BaseModel {
  int? id;
  int? serverId;
  int? serverCreateAt;
  int? serverUpdateAt;
  int? createAt;
  int? updateAt;
  String? reserve1;
  int? reserve2;

  BaseModel(
      {this.id,
      this.serverId,
      this.serverCreateAt,
      this.serverUpdateAt,
      this.createAt,
      this.updateAt,
      this.reserve1,
      this.reserve2});
}

class TagModel extends BaseModel {
  static const tableName = "_lap_tag";
  String? tag;
  int? num; //TODO
  int? tenantId;

  TagModel(
      {int? id,
      this.tag,
      this.num,
      this.tenantId,
      int? serverId,
      int? serverCreateAt,
      int? serverUpdateAt,
      int? createAt,
      int? updateAt,
      String? reserve1,
      int? reserve2})
      : super(
            id: id,
            serverId: serverId,
            serverCreateAt: serverCreateAt,
            serverUpdateAt: serverUpdateAt,
            createAt: createAt,
            updateAt: updateAt,
            reserve1: reserve1,
            reserve2: reserve2);
}

class MemoryContentModel extends BaseModel {
  static const tableName = "_lap_memory_content";

  String? title;
  String? content;
  int? tenantId;

  MemoryContentModel(
      {int? id,
      this.title,
      this.content,
      this.tenantId,
      int? serverId,
      int? serverCreateAt,
      int? serverUpdateAt,
      int? createAt,
      int? updateAt,
      String? reserve1,
      int? reserve2})
      : super(
            id: id,
            serverId: serverId,
            serverCreateAt: serverCreateAt,
            serverUpdateAt: serverUpdateAt,
            createAt: createAt,
            updateAt: updateAt,
            reserve1: reserve1,
            reserve2: reserve2);
}

class TagMappingModel extends BaseModel {
  static const tableName = "_lap_tag_mapping";
  int? tagId;
  int? memoryId;
  int? tenantId;

  TagMappingModel(
      {int? id,
      this.tagId,
      this.memoryId,
      this.tenantId,
      int? serverId,
      int? serverCreateAt,
      int? serverUpdateAt,
      int? createAt,
      int? updateAt,
      String? reserve1,
      int? reserve2})
      : super(
            id: id,
            serverId: serverId,
            serverCreateAt: serverCreateAt,
            serverUpdateAt: serverUpdateAt,
            createAt: createAt,
            updateAt: updateAt,
            reserve1: reserve1,
            reserve2: reserve2);
}

class ScheduleModel extends BaseModel {
  static const tableName = "_lap_schedule";
  int? actionAt;
  int? memoryId;
  int? status;
  int? tenantId;

  ScheduleModel(
      {int? id,
      this.actionAt,
      this.memoryId,
      this.status,
      this.tenantId,
      int? serverId,
      int? serverCreateAt,
      int? serverUpdateAt,
      int? createAt,
      int? updateAt,
      String? reserve1,
      int? reserve2})
      : super(
            id: id,
            serverId: serverId,
            serverCreateAt: serverCreateAt,
            serverUpdateAt: serverUpdateAt,
            createAt: createAt,
            updateAt: updateAt,
            reserve1: reserve1,
            reserve2: reserve2);
}

class TenantModel extends BaseModel {
  static const tableName = "_lap_tenant";
  String? tenantName;
  int? birthday;
  int? gender;
  String? icon;

  TenantModel(
      {int? id,
      this.tenantName,
      this.birthday,
      this.gender,
      this.icon,
      int? serverId,
      int? serverCreateAt,
      int? serverUpdateAt,
      int? createAt,
      int? updateAt,
      String? reserve1,
      int? reserve2})
      : super(
            id: id,
            serverId: serverId,
            serverCreateAt: serverCreateAt,
            serverUpdateAt: serverUpdateAt,
            createAt: createAt,
            updateAt: updateAt,
            reserve1: reserve1,
            reserve2: reserve2);
}
