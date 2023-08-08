import 'package:lapse/infra/data/database/model/memory_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const _id = "id";
const _serverId = "server_id";
const _serverCreateAt = "server_create_at";
const _serverUpdateAt = "server_update_at";
const _createAt = "create_at";
const _updateAt = "update_at";
const _reserve1 = "reserve1";
const _reserve2 = "reserve2";
const _tag = "tag";
const _num = "num";
const _title = "title";
const _content = "content";
const _tagId = "tag_id";
const _memoryId = "memory_id";
const _actionAt = "action_at";
const _status = "status";
const _tenantId = "tenant_id";
const _tenantName = "tenant_name";
const _birthday = "birthday";
const _gender = "gender";
const _icon = "icon";
const _doneAt = "done_at";
const _lastRowId = "lastrowid";

const _databaseVersion = 1;

class DatabaseHelper {
  static final String _logTag = "#DatabaseHelper#";
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static final _databaseName = "lapselocal.sqlite";

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<void> initialize() async {
    if (_database != null) {
      return;
    }
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);
    _database = await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<Database> _getWriteDatabase() async {
    if (_database == null) {
      await initialize();
    }
    return _database!;
  }

  release(Database database) {
    //TODO ignore
  }

  _onCreate(Database database, int newVersion) async {
    database.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS ${TagModel.tableName} (
            $_id INTEGER PRIMARY KEY AUTOINCREMENT,
            $_tag TEXT NOT NULL unique,
            $_num INTEGER,
            $_tenantId INTEGER,
            $_serverId INTEGER,
            $_serverCreateAt INTEGER,
            $_serverUpdateAt INTEGER,
            $_createAt INTEGER,
            $_updateAt INTEGER,
            $_reserve1 TEXT,
            $_reserve2 INTEGER
        );
    ''');

      await txn.execute('''
        CREATE TABLE IF NOT EXISTS ${MemoryContentModel.tableName} (
            $_id INTEGER PRIMARY KEY AUTOINCREMENT,
            $_title TEXT,
            $_content TEXT,
            $_tenantId INTEGER,
            $_serverId INTEGER,
            $_serverCreateAt INTEGER,
            $_serverUpdateAt INTEGER,
            $_createAt INTEGER,
            $_updateAt INTEGER,
            $_reserve1 TEXT,
            $_reserve2 INTEGER
        );
    ''');

      await txn.execute('''
        CREATE TABLE IF NOT EXISTS ${TagMappingModel.tableName} (
            $_id INTEGER PRIMARY KEY AUTOINCREMENT,
            $_tagId INTEGER,
            $_memoryId INTEGER,
            $_tenantId INTEGER,
            $_serverId INTEGER,
            $_serverCreateAt INTEGER,
            $_serverUpdateAt INTEGER,
            $_createAt INTEGER,
            $_updateAt INTEGER,
            $_reserve1 TEXT,
            $_reserve2 INTEGER
        );
    ''');

      await txn.execute('''
        CREATE TABLE IF NOT EXISTS ${ScheduleModel.tableName} (
            $_id INTEGER PRIMARY KEY AUTOINCREMENT,
            $_actionAt INTEGER,
            $_memoryId INTEGER,
            $_status INTEGER,
            $_doneAt INTEGER,
            $_tenantId INTEGER,
            $_serverId INTEGER,
            $_serverCreateAt INTEGER,
            $_serverUpdateAt INTEGER,
            $_createAt INTEGER,
            $_updateAt INTEGER,
            $_reserve1 TEXT,
            $_reserve2 INTEGER
        );
    ''');

      await txn.execute('''
        CREATE TABLE IF NOT EXISTS ${TenantModel.tableName} (
            $_id INTEGER PRIMARY KEY AUTOINCREMENT,
            $_tenantName TEXT,
            $_birthday INTEGER,
            $_gender INTEGER,
            $_icon TEXT,
            $_serverId INTEGER,
            $_serverCreateAt INTEGER,
            $_serverUpdateAt INTEGER,
            $_createAt INTEGER,
            $_updateAt INTEGER,
            $_reserve1 TEXT,
            $_reserve2 INTEGER
        );
    ''');
    });
  }

  _onUpgrade(Database database, int oldVersion, int newVersion) async {
    //do nothing
  }

  Future<List<TagModel>> createTags(List<TagModel> tags) async {
    Database database = await _getWriteDatabase();
    await database.transaction((txn) async {
      var sql = _SQL.sqlTagInsert();
      var nowAt = DateTime.now().millisecondsSinceEpoch;
      var batch = txn.batch();
      try {
        for (var newTag in tags) {
          batch.rawInsert(sql, [newTag.tag, newTag.tenantId, nowAt, nowAt]);
        }
      } finally {
        await batch.commit();
      }
    });
    List<String> tagLabels = [];
    for (var newTag in tags) {
      tagLabels.add(newTag.tag!);
    }

    var selectSql = _SQL.sqlTagSelectWithTag(tagLabels);
    List<Map> results = await database.rawQuery(selectSql, tagLabels);
    var succeeds = mappingTagModel(results);
    return succeeds;
  }

  Future<MemoryContentModel> createContent(
      MemoryContentModel contentModel) async {
    Database database = await _getWriteDatabase();
    await database.transaction((txn) async {
      var sql = _SQL.sqlMemoryContentInsert();
      var nowAt = DateTime.now().millisecondsSinceEpoch;
      await txn.rawInsert(sql, [
        contentModel.title,
        contentModel.content,
        contentModel.tenantId,
        nowAt,
        nowAt
      ]);
    });
    var sql = _SQL.sqlMemoryContentLastRowId();
    var result = await database.rawQuery(sql);
    var rowId = mappingLastRowId(result);
    contentModel.id = rowId;
    print("$_logTag @createContent contentModel.id: $rowId");
    return contentModel;
  }

  createTagMapping(int contentId, List<int> tagIds, int tenantId) async {
    Database database = await _getWriteDatabase();
    await database.transaction((txn) async {
      var batch = txn.batch();
      try {
        var sql = _SQL.sqlTagMappingInsert();
        var nowAt = DateTime.now().millisecondsSinceEpoch;
        for (var tagId in tagIds) {
          batch.rawInsert(sql, [tagId, contentId, tenantId, nowAt, nowAt]);
        }
      } finally {
        await batch.commit();
      }
    });
  }

  createSchedules(
      int contentId, List<ScheduleModel> schedules, int tenantId) async {
    Database database = await _getWriteDatabase();
    await database.transaction((txn) async {
      var batch = txn.batch();
      try {
        var sql = _SQL.sqlScheduleInsert();
        var nowAt = DateTime.now().millisecondsSinceEpoch;
        for (var schedule in schedules) {
          batch.rawInsert(sql, [
            schedule.actionAt,
            contentId,
            schedule.status,
            tenantId,
            nowAt,
            nowAt
          ]);
        }
      } finally {
        await batch.commit();
      }
    });
  }

  Future<List<MemoryContentModel>> listMemoryContent(
      List<int> tenantIds) async {
    var database = await _getWriteDatabase();
    var sql = _SQL.sqlMemoryContentSelectList(tenantIds);
    var results = await database.rawQuery(sql, tenantIds);
    var contents = mappingMemoryContent(results);

    return contents;
  }

  Future<MemoryContentModel> getMemoryContent(int memoryId) async {
    var database = await _getWriteDatabase();
    var sql = _SQL.sqlMemoryContentSelect([memoryId]);
    var results = await database.rawQuery(sql, [memoryId]);
    var contents = mappingMemoryContent(results);
    if (contents.length == 0) {
      return MemoryContentModel();
    } else {
      return contents[0];
    }
  }

  Future<List<MemoryContentModel>?> listEvent(List<int> eventIdList) async {
    var database = await _getWriteDatabase();
    var sql = _SQL.sqlMemoryContentSelect(eventIdList);
    var results = await database.rawQuery(sql, eventIdList);
    var events = mappingMemoryContent(results);
    if (events.length == 0) {
      return [];
    } else {
      return events;
    }
  }

  Future<List<ScheduleModel>> listSchedules(List<int> memoryIds) async {
    var database = await _getWriteDatabase();
    var sql = _SQL.sqlScheduleWithContent(memoryIds);
    var results = await database.rawQuery(sql, memoryIds);
    var schedules = mappingScheduleModel(results);
    return schedules;
  }

  Future<List<ScheduleModel>> listSchedulesWithStatus(
      List<int> statusList) async {
    var database = await _getWriteDatabase();
    var sql = _SQL.sqlScheduleWithStatus(statusList);
    var results = await database.rawQuery(sql, statusList);
    var schedules = mappingScheduleModel(results);
    return schedules;
  }

  Future<ScheduleModel> updateScheduleStatus(
      ScheduleModel scheduleModel) async {
    var database = await _getWriteDatabase();
    var sql = _SQL.sqlScheduleUpdateStatus();
    var nowAtInMills = DateTime.now().millisecondsSinceEpoch;
    await database.execute(sql,
        [scheduleModel.status, nowAtInMills, nowAtInMills, scheduleModel.id]);
    scheduleModel.doneAt = nowAtInMills;
    scheduleModel.updateAt = nowAtInMills;
    return scheduleModel;
  }

  List<TagModel> mappingTagModel(List<Map> results) {
    List<TagModel> tags = [];
    for (Map row in results) {
      TagModel tagModel = TagModel(
          id: row[_id],
          tag: row[_tag],
          num: row[_num],
          tenantId: row[_tenantId],
          serverId: row[_serverId],
          serverCreateAt: row[_serverCreateAt],
          serverUpdateAt: row[_serverUpdateAt],
          createAt: row[_createAt],
          updateAt: row[_updateAt],
          reserve1: row[_reserve1],
          reserve2: row[_reserve2]);
      tags.add(tagModel);
    }
    return tags;
  }

  List<MemoryContentModel> mappingMemoryContent(List<Map> results) {
    List<MemoryContentModel> contents = [];
    for (Map row in results) {
      contents.add(MemoryContentModel(
        id: row[_id],
        title: row[_title],
        content: row[_content],
        tenantId: row[_tenantId],
        serverId: row[_serverId],
        serverCreateAt: row[_serverCreateAt],
        serverUpdateAt: row[_serverUpdateAt],
        createAt: row[_createAt],
        updateAt: row[_updateAt],
      ));
    }
    return contents;
  }

  List<ScheduleModel> mappingScheduleModel(List<Map> results) {
    List<ScheduleModel> schedules = [];
    for (Map row in results) {
      schedules.add(ScheduleModel(
        id: row[_id],
        actionAt: row[_actionAt],
        memoryId: row[_memoryId],
        status: row[_status],
        doneAt: row[_doneAt],
        tenantId: row[_tenantId],
        serverId: row[_serverId],
        serverCreateAt: row[_serverCreateAt],
        serverUpdateAt: row[_serverUpdateAt],
        createAt: row[_createAt],
        updateAt: row[_updateAt],
      ));
    }
    return schedules;
  }

  int mappingLastRowId(List<Map> results) {
    return results.first[_lastRowId];
  }

  Future<int> deleteMemoryContent(int contentId) async {
    var database = await _getWriteDatabase();
    var contentSql = "DELETE FROM ${MemoryContentModel.tableName} WHERE $_id=?";
    var scheduleSql =
        "DELETE FROM ${ScheduleModel.tableName} WHERE $_memoryId=?";
    var tagMappingSql =
        "DELETE FROM ${TagMappingModel.tableName} WHERE $_memoryId=?";
    await database.transaction((txn) async {
      var args = [contentId];
      await txn.rawDelete(contentSql, args);
      await txn.rawDelete(scheduleSql, args);
      await txn.rawDelete(tagMappingSql, args);
    });
    return contentId;
  }

  Future<int> deleteSchedules(int contentId) async {
    var database = await _getWriteDatabase();
    var sql = "DELETE FROM ${ScheduleModel.tableName} WHERE $_memoryId=?";
    var count = await database.rawDelete(sql, [contentId]);
    return count;
  }
}

class _SQL {
  static String sqlTagSelectWithTag(List<String> tagLabels) {
    var builder = StringBuffer();
    tagLabels.forEach((tag) {
      builder.write("?,");
    });

    var length = builder.length;
    var parameters = builder.toString().substring(0, length - 1);

    return '''SELECT * FROM ${TagModel.tableName} WHERE $_tag in ($parameters)''';
  }

  static String sqlTagSelectAll() {
    return _buildSelectSql(TagModel.tableName, [
      _id,
      _tag,
      _num,
      _tenantId,
      _serverId,
      _serverCreateAt,
      _serverUpdateAt,
      _createAt,
      _updateAt
    ]);
  }

  static String sqlMemoryContentSelect(List<int> ids) {
    var whereBuilder = StringBuffer();
    for (int i = 0; i < ids.length; i++) {
      whereBuilder.write(",?");
    }
    var whereArgs = whereBuilder.toString().substring(1);
    return _buildSelectSql(
        MemoryContentModel.tableName,
        [
          _id,
          _title,
          _content,
          _tenantId,
          _serverId,
          _serverCreateAt,
          _serverUpdateAt,
          _createAt,
          _updateAt
        ],
        where: "$_id in($whereArgs)");
  }

  static String sqlMemoryContentSelectList(List<int> tenantIds) {
    var whereBuilder = StringBuffer();
    for (int i = 0; i < tenantIds.length; i++) {
      whereBuilder.write(",?");
    }
    var whereArgs = whereBuilder.toString().substring(1);
    return _buildSelectSql(
        MemoryContentModel.tableName,
        [
          _id,
          _title,
          _content,
          _tenantId,
          _serverId,
          _serverCreateAt,
          _serverUpdateAt,
          _createAt,
          _updateAt
        ],
        where: "$_tenantId in($whereArgs) ORDER BY $_updateAt DESC");
  }

  static String sqlScheduleWithContent(List<int> memoryIds) {
    var builder = StringBuffer();
    memoryIds.forEach((tag) {
      builder.write("?,");
    });

    var length = builder.length;
    var parameters = builder.toString().substring(0, length - 1);
    return _buildSelectSql(
        ScheduleModel.tableName,
        [
          _id,
          _actionAt,
          _memoryId,
          _status,
          _doneAt,
          _tenantId,
          _serverId,
          _serverCreateAt,
          _serverUpdateAt,
          _createAt,
          _updateAt
        ],
        where: " $_memoryId in ($parameters)");
  }

  static String sqlScheduleWithStatus(List<int> statusList) {
    var builder = StringBuffer();
    statusList.forEach((status) {
      builder.write("?,");
    });

    var length = builder.length;
    var parameters = builder.toString().substring(0, length - 1);
    return _buildSelectSql(
        ScheduleModel.tableName,
        [
          _id,
          _actionAt,
          _memoryId,
          _status,
          _doneAt,
          _tenantId,
          _serverId,
          _serverCreateAt,
          _serverUpdateAt,
          _createAt,
          _updateAt
        ],
        where: " $_status in ($parameters)");
  }

  static String sqlScheduleUpdateStatus() {
    return _buildUpdateSql(
        ScheduleModel.tableName, [_status, _doneAt, _updateAt],
        where: "$_id=?");
  }

  static String _buildUpdateSql(String tableName, List<String> columns,
      {String? where}) {
    var columnsBuilder = StringBuffer();
    columns.forEach((column) {
      columnsBuilder.write(",");
      columnsBuilder.write(column);
      columnsBuilder.write("=?");
    });

    String columnString = columnsBuilder.toString().substring(1);

    var sqlBuilder = StringBuffer("UPDATE $tableName SET $columnString");
    var length = where?.length;
    if (length != null && length > 0) {
      sqlBuilder.write(" WHERE $where");
    }
    return sqlBuilder.toString();
  }

  static String _buildSelectSql(String tableName, List<String> columns,
      {String? where}) {
    var columnString = StringBuffer()
      ..writeAll(columns, ",")
      ..toString();

    var sqlBuilder = StringBuffer("SELECT $columnString FROM $tableName");
    var length = where?.length;
    if (length != null && length > 0) {
      sqlBuilder.write(" WHERE $where");
    }
    return sqlBuilder.toString();
  }

  static String sqlMemoryContentLastRowId() {
    return "SELECT max(rowid) as $_lastRowId FROM ${MemoryContentModel.tableName}";
  }

  static String sqlMemoryContentInsert() {
    return _buildCreateSql(
        MemoryContentModel.tableName, [_title, _content, _tenantId]);
  }

  static String sqlTagInsert() {
    return _buildCreateSql(TagModel.tableName, [_tag, _tenantId]);
  }

  static String sqlScheduleInsert() {
    return _buildCreateSql(
        ScheduleModel.tableName, [_actionAt, _memoryId, _status, _tenantId]);
  }

  static String sqlTagMappingInsert() {
    return _buildCreateSql(
        TagMappingModel.tableName, [_tagId, _memoryId, _tenantId]);
  }

  static String _buildCreateSql(String tableName, List<String> columns) {
    var columnString = StringBuffer()
      ..writeAll(columns, ",")
      ..write(", $_createAt")
      ..write(", $_updateAt")
      ..toString();
    List<String> values = [];
    for (var _ in columns) values.add("?");
    var valueString = StringBuffer()
      ..writeAll(values, ",")
      ..write(",?,?")
      ..toString();

    return "INSERT INTO $tableName ($columnString) VALUES ($valueString)";
  }
}
