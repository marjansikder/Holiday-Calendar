import 'package:holiday_calendar/model/models/event_model.dart';
import 'package:holiday_calendar/model/repository/repository.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'holiday_calendar_provider.dart';
import 'holiday_calendar_state.dart';

/// A Riverpod Notifier that manages the holiday calendar state.
class HolidayCalendarNotifier extends Notifier<HolidayCalendarState> {
  late final HolidayRepository _repository;

  HolidayCalendarState build() {
    // Read the repository from another provider (defined below).
    _repository = ref.watch(holidayRepositoryProvider);

    // Initialize default state
    final now = DateTime.now();
    return HolidayCalendarState(
      calendarFormat: CalendarFormat.month,
      focusedDay: now,
      selectedDay: now,
      selectedEvents: [],
      showResetButton: false,
    );
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final events = _repository.getEventsForDay(selectedDay);
    state = state.copyWith(
      selectedDay: selectedDay,
      focusedDay: focusedDay,
      selectedEvents: events,
      showResetButton: true,
    );
  }

  void onFormatChanged(CalendarFormat newFormat) {
    if (state.calendarFormat != newFormat) {
      state = state.copyWith(calendarFormat: newFormat);
    }
  }

  void onPageChanged(DateTime focusedDay) {
    state = state.copyWith(
      focusedDay: focusedDay,
      showResetButton: true,
    );
  }

  void resetToCurrentDay() {
    final now = DateTime.now();
    state = state.copyWith(
      selectedDay: now,
      focusedDay: now,
      selectedEvents: [],
      showResetButton: false,
    );
  }

  // Called by TableCalendar in "eventLoader" to get events for a given day
  List<Event> getEventsForDay(DateTime day) {
    return _repository.getEventsForDay(day);
  }

  // Utility to get a formatted selected day
  String getSelectedDayFormatted() {
    final day = state.selectedDay ?? DateTime.now();
    return DateFormat("dd/MM/yyyy").format(day);
  }
}
