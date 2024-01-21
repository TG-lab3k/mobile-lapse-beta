import 'package:intl/intl.dart';
import 'package:lapse/business/task/data/po/common_po.dart';
import 'package:lapse/business/task/data/po/task_po.dart';
import 'package:lapse/business/task/data/po/user_po.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  static const String _dbName = 'lapse_task_libs.db';

  // Table names
  static const String _tableEvent = 'event';
  static const String _tableTag = 'tag';
  static const String _tableTagMapping = 'tag_mapping';
  static const String _tableTask = 'task';
  static const String _tableComment = 'comment';
  static const String _tableSupervisor = 'supervisor';
  static const String _tableChild = 'child';

  // Common column names
  static const String _columnId = 'id';
  static const String _columnCreateAt = 'create_at';
  static const String _columnUpdateAt = 'update_at';

  // Event table columns
  static const String _columnActionAt = 'action_at';
  static const String _columnEventOrder = 'event_order';
  static const String _columnTaskIdEvent = 'task_id';
  static const String _columnStatus = 'status';
  static const String _columnDoneAt = 'done_at';

  // Tag table columns
  static const String _columnTag = 'tag';
  static const String _columnParentIdTag = 'parent_id';

  // TagMapping table columns
  static const String _columnTagIdMapping = 'tag_id';
  static const String _columnTaskIdMapping = 'task_id';

  // Task table columns
  static const String _columnTitle = 'title';
  static const String _columnContent = 'content';
  static const String _columnRepeatType = 'repeat_type';
  static const String _columnCreatorId = 'creator_id';
  static const String _columnAssignId = 'assign_id';
  static const String _columnChildId = 'child_id';

  // Comment table columns
  static const String _columnComment = 'comment';
  static const String _columnType = 'type';
  static const String _columnTaskIdComment = 'task_id';
  static const String _columnEventId = 'event_id';

  // Supervisor table columns
  static const String _columnName = 'name';
  static const String _columnAvatar = 'avatar';
  static const String _columnRole = 'role';

  // Child table columns
  static const String _columnBirthday = 'birthday';
  static const String _columnGender = 'gender';

  DatabaseHelper._internal();

  DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  DateFormat _dayFormat = DateFormat('yyyy-MM-dd');

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async {
        await _createEventTable(db);
        await _createTagTable(db);
        await _createTagMappingTable(db);
        await _createTaskTable(db);
        await _createCommentTable(db);
        await _createSupervisorTable(db);
        await _createChildTable(db);
      },
      version: 1,
    );
  }

  Future<void> _createEventTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableEvent (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnCreateAt TEXT,
        $_columnUpdateAt TEXT,
        $_columnActionAt TEXT,
        $_columnEventOrder INTEGER,
        $_columnTaskIdEvent INTEGER,
        $_columnStatus INTEGER,
        $_columnDoneAt TEXT
      )
    ''');
  }

  Future<void> _createTagTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableTag (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnCreateAt TEXT,
        $_columnUpdateAt TEXT,
        $_columnTag TEXT,
        $_columnParentIdTag INTEGER,
        $_columnChildId INTEGER
      )
    ''');
  }

  Future<void> _createTagMappingTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableTagMapping (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnCreateAt TEXT,
        $_columnUpdateAt TEXT,
        $_columnTagIdMapping INTEGER,
        $_columnTaskIdMapping INTEGER
      )
    ''');
  }

  Future<void> _createTaskTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableTask (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnCreateAt TEXT,
        $_columnUpdateAt TEXT,
        $_columnTitle TEXT,
        $_columnContent TEXT,
        $_columnRepeatType INTEGER,
        $_columnStatus INTEGER,
        $_columnCreatorId INTEGER,
        $_columnAssignId INTEGER,
        $_columnChildId INTEGER
      )
    ''');
  }

  Future<void> _createCommentTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableComment (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnCreateAt TEXT,
        $_columnUpdateAt TEXT,
        $_columnComment TEXT,
        $_columnType INTEGER,
        $_columnTaskIdComment INTEGER,
        $_columnEventId INTEGER
      )
    ''');
  }

  Future<void> _createSupervisorTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableSupervisor (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnCreateAt TEXT,
        $_columnUpdateAt TEXT,
        $_columnName TEXT,
        $_columnAvatar TEXT,
        $_columnRole INTEGER
      )
    ''');
  }

  Future<void> _createChildTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableChild (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnCreateAt TEXT,
        $_columnUpdateAt TEXT,
        $_columnName TEXT,
        $_columnAvatar TEXT,
        $_columnBirthday TEXT,
        $_columnGender INTEGER
      )
    ''');
  }

  Future<EventPo?> getEventById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableEvent,
      where: '$_columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToEventPo(maps[0]);
    } else {
      return null;
    }
  }

  Future<List<EventPo>> getEventsToday(int status) async {
    final Database db = await database;
    String today = _dayFormat.format(DateTime.now());
    final List<Map<String, dynamic>> maps = await db.query(
      _tableEvent,
      where: '$_columnActionAt LIKE ? AND $_columnStatus = ?',
      whereArgs: ['$today%', status],
      orderBy: '$_columnActionAt DESC',
    );

    if (maps.isNotEmpty) {
      return maps.map((e) => _mapToEventPo(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<EventPo>> getEventsBeforeToday(int status) async {
    final Database db = await database;
    String today = _dayFormat.format(DateTime.now());
    final List<Map<String, dynamic>> maps = await db.query(
      _tableEvent,
      where: '$_columnActionAt < ? AND $_columnStatus = ?',
      whereArgs: [today, status],
      orderBy: '$_columnActionAt DESC',
    );

    if (maps.isNotEmpty) {
      return maps.map((e) => _mapToEventPo(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<EventPo>> getEventsAfterToday(int status) async {
    final Database db = await database;
    String today = _dayFormat.format(DateTime.now());
    final List<Map<String, dynamic>> maps = await db.query(
      _tableEvent,
      where: '$_columnActionAt > ? AND $_columnStatus = ?',
      whereArgs: [today, status],
      orderBy: '$_columnActionAt DESC',
    );

    if (maps.isNotEmpty) {
      return maps.map((e) => _mapToEventPo(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<EventPo>> getEventsRecentByTaskIdList(
      List<int> taskId, int status) async {
    final Database db = await database;
    final nowAt = _dateFormat.format(DateTime.now());
    String questionMarks =
        List.generate(taskId.length, (index) => '?').join(', ');
    String sql = '''
      SELECT $_columnId, MIN($_columnActionAt) as minActionAt
      FROM $_tableEvent 
      WHERE $_columnActionAt > ? AND $_columnStatus = ? AND $_columnTaskIdEvent IN($questionMarks)
      GROUP BY $_columnTaskIdEvent
    ''';
    final List<Map<String, dynamic>> maps =
        await db.rawQuery(sql, [nowAt, status, questionMarks]);

    if (maps.isNotEmpty) {
      var eventIds = maps.map((e) => e[_columnId] as int).toList();
      String questionMarks =
          List.generate(eventIds.length, (index) => '?').join(', ');
      List<Map<String, dynamic>> mapList = await db.query(_tableEvent,
          where: "$_columnId IN($questionMarks)", whereArgs: [eventIds]);
      if (mapList.isNotEmpty) {
        return mapList.map((e) => _mapToEventPo(e)).toList();
      }
    }
    return [];
  }

  Future<List<EventPo>> getAllEvents() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableEvent);

    return List.generate(maps.length, (i) {
      return _mapToEventPo(maps[i]);
    });
  }

  // Tag table queries
  Future<TagPo?> getTagById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableTag,
      where: '$_columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToTagPo(maps[0]);
    } else {
      return null;
    }
  }

  Future<List<TagPo>> getTagsByIds(List<int> ids) async {
    if (ids.isEmpty) {
      return [];
    }

    final Database db = await database;
    String questionMarks = List.generate(ids.length, (index) => '?').join(', ');
    final List<Map<String, dynamic>> maps = await db.query(
      _tableTag,
      where: '$_columnId IN ($questionMarks)',
      whereArgs: [ids],
    );

    if (maps.isNotEmpty) {
      return maps.map((e) => _mapToTagPo(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<TagPo>> getAllTags() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableTag);

    return List.generate(maps.length, (i) => _mapToTagPo(maps[i]));
  }

  // TagMapping table queries
  Future<TagMappingPo?> getTagMappingById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableTagMapping,
      where: '$_columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToTagMappingPo(maps[0]);
    } else {
      return null;
    }
  }

  Future<List<TagMappingPo>> getTagMappingsByTaskIds(List<int> taskIds) async {
    if (taskIds.isEmpty) {
      return [];
    }
    final Database db = await database;
    String questionMarks =
        List.generate(taskIds.length, (index) => '?').join(', ');
    final List<Map<String, dynamic>> maps = await db.query(
      _tableTagMapping,
      where: '$_columnTaskIdMapping IN ($questionMarks)',
      whereArgs: [taskIds],
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => _mapToTagMappingPo(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<TagMappingPo>> getAllTagMappings() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableTagMapping);

    return List.generate(maps.length, (i) => _mapToTagMappingPo(maps[i]));
  }

  // Task table queries
  Future<TaskPo?> getTaskById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableTask,
      where: '$_columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToTaskPo(maps[0]);
    } else {
      return null;
    }
  }

  Future<List<TaskPo>> getTasksByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final Database db = await database;
    String questionMarks = List.generate(ids.length, (index) => '?').join(', ');
    final List<Map<String, dynamic>> maps = await db.query(
      _tableTask,
      where: '$_columnId IN ($questionMarks)',
      whereArgs: [ids],
    );

    if (maps.isNotEmpty) {
      return maps.map((e) => _mapToTaskPo(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<TaskPo>> getTasksNotStatus(int status) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableTask,
      where: '$_columnStatus != ?',
      whereArgs: [status],
    );

    if (maps.isNotEmpty) {
      return maps.map((e) => _mapToTaskPo(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<TaskPo>> getAllTasks() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableTask);

    return List.generate(maps.length, (i) => _mapToTaskPo(maps[i]));
  }

  // Comment table queries
  Future<CommentPo?> getCommentById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableComment,
      where: '$_columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToCommentPo(maps[0]);
    } else {
      return null;
    }
  }

  Future<List<CommentPo>> getAllComments() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableComment);

    return List.generate(maps.length, (i) => _mapToCommentPo(maps[i]));
  }

  // Supervisor table queries
  Future<SupervisorPo?> getSupervisorById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableSupervisor,
      where: '$_columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToSupervisorPo(maps[0]);
    } else {
      return null;
    }
  }

  Future<List<SupervisorPo>> getAllSupervisors() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableSupervisor);

    return List.generate(maps.length, (i) => _mapToSupervisorPo(maps[i]));
  }

  // Child table queries
  Future<ChildPo?> getChildById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableChild,
      where: '$_columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToChildPo(maps[0]);
    } else {
      return null;
    }
  }

  Future<List<ChildPo>> getAllChildren() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableChild);

    return List.generate(maps.length, (i) => _mapToChildPo(maps[i]));
  }

  // Helper functions to map database results to Po objects
  EventPo _mapToEventPo(Map<String, dynamic> map) {
    return EventPo(
      id: map[_columnId] as int?,
      createAt: map[_columnCreateAt] as String?,
      updateAt: map[_columnUpdateAt] as String?,
      actionAt: map[_columnActionAt] as String?,
      eventOrder: map[_columnEventOrder] as int?,
      taskId: map[_columnTaskIdEvent] as int?,
      status: map[_columnStatus] as int?,
      doneAt: map[_columnDoneAt] as String?,
    );
  }

  TagPo _mapToTagPo(Map<String, dynamic> map) {
    return TagPo(
      id: map[_columnId] as int?,
      createAt: map[_columnCreateAt] as String?,
      updateAt: map[_columnUpdateAt] as String?,
      tag: map[_columnTag] as String?,
      parentId: map[_columnParentIdTag] as int?,
      childId: map[_columnChildId] as int?,
    );
  }

  TagMappingPo _mapToTagMappingPo(Map<String, dynamic> map) {
    return TagMappingPo(
      id: map[_columnId] as int?,
      createAt: map[_columnCreateAt] as String?,
      updateAt: map[_columnUpdateAt] as String?,
      tagId: map[_columnTagIdMapping] as int?,
      taskId: map[_columnTaskIdMapping] as int?,
    );
  }

  TaskPo _mapToTaskPo(Map<String, dynamic> map) {
    return TaskPo(
      id: map[_columnId] as int?,
      createAt: map[_columnCreateAt] as String?,
      updateAt: map[_columnUpdateAt] as String?,
      title: map[_columnTitle] as String?,
      content: map[_columnContent] as String?,
      repeatType: map[_columnRepeatType] as int?,
      status: map[_columnStatus] as int?,
      creatorId: map[_columnCreatorId] as int?,
      assignId: map[_columnAssignId] as int?,
      childId: map[_columnChildId] as int?,
    );
  }

  CommentPo _mapToCommentPo(Map<String, dynamic> map) {
    return CommentPo(
      id: map[_columnId] as int?,
      createAt: map[_columnCreateAt] as String?,
      updateAt: map[_columnUpdateAt] as String?,
      comment: map[_columnComment] as String?,
      type: map[_columnType] as int?,
      taskId: map[_columnTaskIdComment] as int?,
      eventId: map[_columnEventId] as int?,
    );
  }

  SupervisorPo _mapToSupervisorPo(Map<String, dynamic> map) {
    return SupervisorPo(
      id: map[_columnId] as int?,
      createAt: map[_columnCreateAt] as String?,
      updateAt: map[_columnUpdateAt] as String?,
      name: map[_columnName] as String?,
      avatar: map[_columnAvatar] as String?,
      role: map[_columnRole] as int?,
    );
  }

  ChildPo _mapToChildPo(Map<String, dynamic> map) {
    return ChildPo(
      id: map[_columnId] as int?,
      createAt: map[_columnCreateAt] as String?,
      updateAt: map[_columnUpdateAt] as String?,
      name: map[_columnName] as String?,
      avatar: map[_columnAvatar] as String?,
      birthday: map[_columnBirthday] as String?,
      gender: map[_columnGender] as int?,
    );
  }

  _addCreateTime(BasePo basePo) {
    DateTime nowAt = DateTime.now();
    String nowInString = _dateFormat.format(nowAt);
    basePo.createAt = nowInString;
    basePo.updateAt = nowInString;
  }

  Future<int> insertEvent(Transaction transaction, EventPo event) async {
    _addCreateTime(event);
    return await transaction.insert(_tableEvent, _eventToMap(event));
  }

  Future<List<int>> insertEventList(
      Transaction transaction, List<EventPo> eventList) async {
    Batch batch = transaction.batch();
    eventList.forEach((eventPo) {
      _addCreateTime(eventPo);
      batch.insert(_tableEvent, _eventToMap(eventPo));
    });
    return batch.commit().then((value) => value.map((e) => e as int).toList());
  }

  Future<int> insertTag(Transaction transaction, TagPo tag) async {
    _addCreateTime(tag);
    return await transaction.insert(_tableTag, _tagToMap(tag));
  }

  Future<List<int>> insertTagList(
      Transaction transaction, List<TagPo> tagList) async {
    Batch batch = transaction.batch();
    tagList.forEach((tag) {
      _addCreateTime(tag);
      batch.insert(_tableTag, _tagToMap(tag));
    });
    return batch.commit().then((value) => value.map((e) => e as int).toList());
  }

  Future<int> insertTagMapping(
      Transaction transaction, TagMappingPo tagMapping) async {
    _addCreateTime(tagMapping);
    return await transaction.insert(
        _tableTagMapping, _tagMappingToMap(tagMapping));
  }

  Future<List<int>> insertTagMappingList(
      Transaction transaction, List<TagMappingPo> tagMappingList) async {
    Batch batch = transaction.batch();
    tagMappingList.forEach((tagMapping) {
      _addCreateTime(tagMapping);
      batch.insert(_tableTagMapping, _tagMappingToMap(tagMapping));
    });
    return batch.commit().then((value) => value.map((e) => e as int).toList());
  }

  Future<int> insertTask(Transaction transaction, TaskPo task) async {
    _addCreateTime(task);
    return await transaction.insert(_tableTask, _taskToMap(task));
  }

  Future<int> insertComment(Transaction transaction, CommentPo comment) async {
    _addCreateTime(comment);
    return await transaction.insert(_tableComment, _commentToMap(comment));
  }

  Future<int> insertSupervisor(
      Transaction transaction, SupervisorPo supervisor) async {
    _addCreateTime(supervisor);
    return await transaction.insert(
        _tableSupervisor, _supervisorToMap(supervisor));
  }

  Future<int> insertChild(Transaction transaction, ChildPo child) async {
    _addCreateTime(child);
    return await transaction.insert(_tableChild, _childToMap(child));
  }

  Map<String, dynamic> _eventToMap(EventPo event) {
    return {
      _columnCreateAt: event.createAt,
      _columnUpdateAt: event.updateAt,
      _columnActionAt: event.actionAt,
      _columnEventOrder: event.eventOrder,
      _columnTaskIdEvent: event.taskId,
      _columnStatus: event.status,
      _columnDoneAt: event.doneAt,
    };
  }

  Map<String, dynamic> _tagToMap(TagPo tag) {
    return {
      _columnCreateAt: tag.createAt,
      _columnUpdateAt: tag.updateAt,
      _columnTag: tag.tag,
      _columnParentIdTag: tag.parentId,
      _columnChildId: tag.childId,
    };
  }

  Map<String, dynamic> _tagMappingToMap(TagMappingPo tagMapping) {
    return {
      _columnCreateAt: tagMapping.createAt,
      _columnUpdateAt: tagMapping.updateAt,
      _columnTagIdMapping: tagMapping.tagId,
      _columnTaskIdMapping: tagMapping.taskId,
    };
  }

  Map<String, dynamic> _taskToMap(TaskPo task) {
    return {
      _columnCreateAt: task.createAt,
      _columnUpdateAt: task.updateAt,
      _columnTitle: task.title,
      _columnContent: task.content,
      _columnRepeatType: task.repeatType,
      _columnStatus: task.status,
      _columnCreatorId: task.creatorId,
      _columnAssignId: task.assignId,
      _columnChildId: task.childId,
    };
  }

  Map<String, dynamic> _commentToMap(CommentPo comment) {
    return {
      _columnCreateAt: comment.createAt,
      _columnUpdateAt: comment.updateAt,
      _columnComment: comment.comment,
      _columnType: comment.type,
      _columnTaskIdComment: comment.taskId,
      _columnEventId: comment.eventId,
    };
  }

  Map<String, dynamic> _supervisorToMap(SupervisorPo supervisor) {
    return {
      _columnCreateAt: supervisor.createAt,
      _columnUpdateAt: supervisor.updateAt,
      _columnName: supervisor.name,
      _columnAvatar: supervisor.avatar,
      _columnRole: supervisor.role,
    };
  }

  Map<String, dynamic> _childToMap(ChildPo child) {
    return {
      _columnCreateAt: child.createAt,
      _columnUpdateAt: child.updateAt,
      _columnName: child.name,
      _columnAvatar: child.avatar,
      _columnBirthday: child.birthday,
      _columnGender: child.gender,
    };
  }

  Future<TagPo?> findTagWithParent(String tagName, int? parentId) async {
    Database db = await this.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableTag,
      where: '$_columnParentIdTag = ? AND $_columnTag = ?',
      whereArgs: [parentId, tagName],
    );

    if (maps.isNotEmpty) {
      return _mapToTagPo(maps[0]);
    } else {
      return null;
    }
  }
}
