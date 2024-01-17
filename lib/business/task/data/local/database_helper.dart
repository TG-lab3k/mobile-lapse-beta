const _id = "id";
const _createAt = "create_at";
const _updateAt = "update_at";
const _tag = "tag";
const _title = "title";
const _content = "content";
const _tagId = "tag_id";
const _actionAt = "action_at";
const _status = "status";
const _birthday = "birthday";
const _gender = "gender";
const _lastRowId = "lastrowid";

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;
}
