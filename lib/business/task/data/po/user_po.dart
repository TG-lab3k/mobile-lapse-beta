import 'common_po.dart';

class SupervisorPo extends BasePo {
  String? name;
  String? avatar;
  int? role;

  SupervisorPo(
      {int? id,
      String? createAt,
      String? updateAt,
      this.name,
      this.avatar,
      this.role})
      : super(id: id, createAt: createAt, updateAt: updateAt);
}

class ChildPo extends BasePo {
  String? name;
  String? avatar;
  String? birthday;
  int? gender;

  ChildPo(
      {int? id,
      String? createAt,
      String? updateAt,
      this.name,
      this.avatar,
      this.birthday,
      this.gender})
      : super(id: id, createAt: createAt, updateAt: updateAt);
}
