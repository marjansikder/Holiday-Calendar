import 'package:holiday_calendar/model/models/event_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:collection';


class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  // Table & columns
  static const String tableEvents = 'events';
  static const String columnId = 'id';
  static const String columnDate = 'date';
  static const String columnHolidayBn = 'holidayBn';
  static const String columnHolidayEn = 'holidayEn';

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Initialize the database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'holiday.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableEvents (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnDate TEXT NOT NULL,
            $columnHolidayBn TEXT NOT NULL,
            $columnHolidayEn TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insert a single event into the database
  Future<int> insertEvent(DateTime date, Event event) async {
    final database = await db;
    final dateString = _formatDate(date);
    return await database.insert(tableEvents, {
      columnDate: dateString,
      columnHolidayBn: event.holidayBn,
      columnHolidayEn: event.holidayEn,
    });
  }

  // db_service.dart
  Future<int> deleteEvent(DateTime date, Event event) async {
    final database = await db;
    final dateString = _formatDate(date); // e.g., 'yyyy-MM-dd'

    // If each event has a unique ID column, it’s best to use that:
    // where: '$columnId = ?',
    // whereArgs: [event.id],

    // Otherwise, match on date + holidayBn + holidayEn:
    return await database.delete(
      tableEvents,
      where: '$columnDate = ? AND $columnHolidayBn = ? AND $columnHolidayEn = ?',
      whereArgs: [
        dateString,
        event.holidayBn,
        event.holidayEn,
      ],
    );
  }


  // Fetch all events matching a date
  Future<List<Event>> getEventsByDate(DateTime date) async {
    final database = await db;
    final dateString = _formatDate(date);
    final result = await database.query(
      tableEvents,
      where: '$columnDate = ?',
      whereArgs: [dateString],
    );
    return result.map((map) {
      return Event(
        map[columnHolidayBn] as String,
        map[columnHolidayEn] as String,
      );
    }).toList();
  }

  // Optional: fetch all events in the DB
  Future<List<Map<String, dynamic>>> getAllRows() async {
    final database = await db;
    return await database.query(tableEvents);
  }

  /// Insert multiple events from a `LinkedHashMap<DateTime, List<Event>>`.
  /// This is how we'll pre-populate from `_mockEvents`.
  Future<void> insertMockEvents(
      LinkedHashMap<DateTime, List<Event>> mockData,
      ) async {
    final database = await db;

    // We may want to check if table is empty before inserting
    final count = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM $tableEvents'),
    );

    // Only insert if we have no data yet:
    if (count == 0) {
      // Insert each event
      for (final entry in mockData.entries) {
        final date = entry.key;
        final events = entry.value;

        for (final event in events) {
          await insertEvent(date, event);
        }
      }
    }
  }

  /// Format date as 'yyyy-MM-dd' so we can match exact days
  String _formatDate(DateTime date) {
    // Could also use intl DateFormat if you prefer
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
