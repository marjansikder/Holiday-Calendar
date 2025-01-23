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
    DateTime(2025, 2, 15): [const Event('শবে বরাত', 'Shab e-Barat')],
    DateTime(2025, 2, 21): [Event('আন্তর্জাতিক মাতৃভাষা দিবস', 'International Mother Language Day')],
    DateTime(2025, 3, 26): [const Event('স্বাধীনতা দিবস', 'Independence Day')],
    DateTime(2025, 3, 28): [const Event('শবে কদর', 'Shab e-Qadr')],
    DateTime(2025, 3, 29): [const Event('ঈদুল ফিতরের ছুটি', 'Eid ul-Fitr Holiday')],
    DateTime(2025, 3, 30): [const Event('ঈদুল ফিতরের ছুটি', 'Eid ul-Fitr Holiday')],
    DateTime(2025, 3, 31): [Event('ঈদুল ফিতরের ছুটি', 'Eid ul-Fitr Holiday')],
    DateTime(2025, 4, 1): [Event('ঈদুল ফিতরের ছুটি', 'Eid ul-Fitr Holiday')],
    DateTime(2025, 4, 2): [Event('ঈদুল ফিতরের ছুটি', 'Eid ul-Fitr Holiday')],
    DateTime(2025, 4, 14): [Event('পহেলা বৈশাখ', 'Pahela Baishakh')],
    DateTime(2025, 5, 1): [Event('মে দিবস', 'May Day')],
    DateTime(2025, 5, 11): [Event('বুদ্ধ পূর্ণিমা', 'Buddha Purnima')],
    DateTime(2025, 6, 5): [Event('ঈদুল আযহার ছুটি', 'Eid al-Adha Holiday')],
    DateTime(2025, 6, 7): [Event('ঈদুল আযহার ছুটি', 'Eid al-Adha Holiday')],
    DateTime(2025, 6, 8): [Event('ঈদুল আযহার ছুটি', 'Eid al-Adha Holiday')],
    DateTime(2025, 6, 9): [Event('ঈদুল আযহার ছুটি', 'Eid al-Adha Holiday')],
    DateTime(2025, 6, 10): [Event('ঈদুল আযহার ছুটি', 'Eid al-Adha Holiday')],
    DateTime(2025, 7, 6): [Event('আশুরা', 'Ashura')],
    DateTime(2025, 8, 16): [Event('জন্মাষ্টমী', 'Janmashtami')],
    DateTime(2025, 9, 5): [Event('ঈদে মিলাদুন্নবী', 'Eid e-Milad-un Nabi')],
    DateTime(2025, 10, 1): [Event('দুর্গাপূজা', 'Durga Puja')],
    DateTime(2025, 10, 2): [Event('দুর্গাপূজা', 'Durga Puja')],
    DateTime(2025, 12, 16): [Event('বিজয় দিবস', 'Victory Day')],
    DateTime(2025, 12, 25): [Event('বড়দিন', 'Christmas Day')],
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
