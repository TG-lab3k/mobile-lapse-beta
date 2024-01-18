//
const _id = "id";
const _createAt = "create_at";
const _updateAt = "update_at";

//
const _name = "name";
const _avatar = "avatar";
const _role = "role";
const _birthday = "birthday";
const _gender = "gender";

//
const _title = "title";
const _content = "content";
const _repeat_type = "repeat_type";
const _creator_id = "creator_id";
const _status = "status";

//
const _tag = "tag";
const _tagId = "tag_id";
const _actionAt = "action_at";

const _lastRowId = "lastrowid";

const _table_supervisor = "supervisor";
const _table_child = "child";
const _table_event = "event";
const _table_tag = "tag";
const _table_tag_mapping = "tag_mapping";
const _table_task = "task";
const _table_comment = "comment";

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;
}
