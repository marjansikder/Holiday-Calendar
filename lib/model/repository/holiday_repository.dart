// lib/model/repository/holiday_repository.dart
import 'package:flutter/foundation.dart';
import 'package:holiday_calendar/model/db/db_service.dart';
import 'package:holiday_calendar/model/models/event_model.dart';


class HolidayRepository {
  final DBService dbService;

  HolidayRepository({required this.dbService});

  // Insert event into DB
  Future<void> addEvent(Event event, DateTime date) async {
    await dbService.insertEvent(event, date);
  }

  // Get events from DB for a specific date
  Future<List<Event>> getEventsForDay(DateTime date) async {
    return await dbService.getEventsForDate(date);
  }
}
