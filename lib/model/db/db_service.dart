import 'package:holiday_calendar/model/models/event_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

 // or event_model.dart

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  // Name of the table and database fields
  static const String _tableEvents = 'events';
  static const String columnId = 'id';
  static const String columnTitleEn = 'holidayEn';
  static const String columnTitleBn = 'holidayBn';
  static const String columnDate = 'date'; // we can store date as ISO string or timestamp

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'holidays.db');

    // Open or create the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create the table
        await db.execute('''
          CREATE TABLE $_tableEvents (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitleEn TEXT NOT NULL,
            $columnTitleBn TEXT NOT NULL,
            $columnDate TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insert event into DB
  Future<int> insertEvent(Event event, DateTime date) async {
    final database = await db;
    // For date, you can store as an ISO string ('yyyy-MM-dd') or full dateTime
    final dateString = _formatDate(date);
    return await database.insert(_tableEvents, {
      columnTitleEn: event.holidayEn,
      columnTitleBn: event.holidayBn,
      columnDate: dateString,
    });
  }

  // Fetch events for a specific date
  Future<List<Event>> getEventsForDate(DateTime date) async {
    final database = await db;
    final dateString = _formatDate(date);
    final result = await database.query(
      _tableEvents,
      where: '$columnDate = ?',
      whereArgs: [dateString],
    );
    return result.map((row) => Event(
      row[columnTitleBn] as String,
      row[columnTitleEn] as String,
    )).toList();
  }

  // Example: format date as 'yyyy-MM-dd'
  String _formatDate(DateTime date) {
    // Or use a more robust approach with intl if you prefer
    return '${date.year.toString().padLeft(4,'0')}-'
        '${date.month.toString().padLeft(2,'0')}-'
        '${date.day.toString().padLeft(2,'0')}';
  }
}
