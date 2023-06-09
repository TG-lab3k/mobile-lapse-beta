import 'dart:ffi';
import 'dart:io';

import 'package:lapse/infra/data/database/model/memory_model.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'package:sqlite3/open.dart';

const _id = "id";
const _serverId = "serverId";
const _serverCreateAt = "serverCreateAt";
const _serverUpdateAt = "serverUpdateAt";
const _createAt = "createAt";
const _updateAt = "updateAt";
const _reserve1 = "reserve1";
const _reserve2 = "reserve2";
const _tag = "tag";
const _num = "num";
const _title = "title";
const _content = "content";
const _tagId = "tagId";
const _memoryId = "memoryId";
const _actionAt = "actionAt";
const _status = "status";
const _tenantId = "tenantId";
const _tenantName = "tenantName";
const _birthday = "birthday";
const _gender = "gender";
const _icon = "icon";
const _lastRowId = "lastrowid";

const _databaseVersion = 1;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static final _databaseName = "lapselocal.sqlite";

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  initialize() async {
    _createTable();
  }

  Database getWriteDatabase() {
    if (_database == null) {
      _database = sqlite3.open(_databaseName);
    }
    return _database!;
  }

  release(Database database) {
    database.dispose();
  }

  _createTable() async {
    Database database = sqlite3.open(_databaseName);
    try {
      if (database.userVersion != 0) {
        return;
      }
      database.userVersion = _databaseVersion;
      database.execute('''
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

      database.execute('''
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

      database.execute('''
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

      database.execute('''
        CREATE TABLE IF NOT EXISTS ${ScheduleModel.tableName} (
            $_id INTEGER PRIMARY KEY AUTOINCREMENT,
            $_actionAt INTEGER,
            $_memoryId INTEGER,
            $_status INTEGER,
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

      database.execute('''
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
    } finally {
      //
      _database = database;
    }
  }

  List<TagModel> mappingTagModel(ResultSet resultSet) {
    List<TagModel> tags = [];
    for (final Row row in resultSet) {
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

  int mappingLastRowId(ResultSet resultSet) {
    return resultSet.first[_lastRowId];
  }

  String sqlTagInsert() {
    return "INSERT INTO ${TagModel.tableName} ($_tag, $_tenantId) VALUES (?,?)";
  }

  String sqlTagSelectWithTag(List<String> tagLabels) {
    var builder = StringBuffer();
    tagLabels.forEach((tag) {
      builder.write("?,");
    });

    var length = builder.length;
    var parameters = builder.toString().substring(0, length - 1);

    return '''SELECT * FROM ${TagModel.tableName} WHERE $_tag in ($parameters)''';
  }

  String sqlMemoryContentInsert() {
    return "INSERT INTO ${MemoryContentModel.tableName} ($_title, $_content, $_tenantId) VALUES (?,?,?)";
  }

  String sqlMemoryContentLastRowId() {
    return "SELECT max(rowid) as $_lastRowId FROM ${MemoryContentModel.tableName}";
  }

  String sqlScheduleInsert() {
    return "INSERT INTO ${ScheduleModel.tableName} ($_actionAt, $_memoryId, $_status, $_tenantId) VALUES (?,?,?,?)";
  }

  String sqlTagMappingInsert() {
    return "INSERT INTO ${TagMappingModel.tableName} ($_tagId, $_memoryId, $_tenantId) VALUES (?,?,?)";
  }
}
