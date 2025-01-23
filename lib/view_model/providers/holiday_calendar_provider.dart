import 'package:holiday_calendar/model/db/db_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_calendar/model/repository/holiday_repository.dart';
import 'holiday_calendar_notifier.dart';
import 'holiday_calendar_state.dart';



final holidayCalendarProvider =
    NotifierProvider<HolidayCalendarNotifier, HolidayCalendarState>(
        HolidayCalendarNotifier.new);

// Provide DBService (singleton).
final dbServiceProvider = Provider<DBService>((ref) {
  return DBService();
});

// Provide a HolidayRepository that uses the DBService
final holidayRepositoryDbProvider = Provider<HolidayRepository>((ref) {
  final dbService = ref.watch(dbServiceProvider);
  return HolidayRepository(dbService: dbService);
});