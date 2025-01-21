import 'package:holiday_calendar/model/repository/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'holiday_calendar_notifier.dart';
import 'holiday_calendar_state.dart';

final holidayRepositoryProvider = Provider<HolidayRepository>((ref) {
  return HolidayRepository();
});

// Provide the HolidayCalendarNotifier using Riverpod's Notifier API
final holidayCalendarProvider =
    NotifierProvider<HolidayCalendarNotifier, HolidayCalendarState>(
        HolidayCalendarNotifier.new);
