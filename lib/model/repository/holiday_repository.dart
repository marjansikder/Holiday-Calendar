// lib/model/repository/holiday_repository.dart
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:holiday_calendar/model/db/db_service.dart';
import 'package:holiday_calendar/model/models/event_model.dart';


class HolidayRepository {
  final DBService dbService;

  // The mock event data (in-memory), used just for initial DB insert.
  final LinkedHashMap<DateTime, List<Event>> _mockEvents =
  LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: (DateTime key) => key.day * 1000000 + key.month * 10000 + key.year,
  )..addAll({
    // ... your existing date-event pairs ...
  });

  HolidayRepository({required this.dbService});

  /// Initialize DB with our mock events IF the table is empty
  Future<void> initMockData() async {
    await dbService.insertMockEvents(_mockEvents);
  }

  /// Insert a single event for a given date
  Future<void> addEvent(DateTime date, Event event) async {
    await dbService.insertEvent(date, event);
  }

  /// Retrieve events from DB for a given date
  Future<List<Event>> getEventsForDay(DateTime date) async {
    return await dbService.getEventsByDate(date);
  }
}

/// Helper if needed
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
