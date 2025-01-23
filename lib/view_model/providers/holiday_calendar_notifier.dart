

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_calendar/model/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../model/repository/holiday_repository.dart';
import 'holiday_calendar_provider.dart';
import 'holiday_calendar_state.dart';

class HolidayCalendarNotifier extends Notifier<HolidayCalendarState> {
  late final HolidayRepository _repository;

  @override
  HolidayCalendarState build() {
    _repository = ref.watch(holidayRepositoryDbProvider);

    final now = DateTime.now();
    return HolidayCalendarState(
      calendarFormat: CalendarFormat.month,
      focusedDay: now,
      selectedDay: now,
      selectedEvents: [],
      showResetButton: false,
    );
  }

  // Called when user taps on a day in the calendar
  Future<void> onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    final events = await _repository.getEventsForDay(selectedDay);
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
    state = state.copyWith(focusedDay: focusedDay, showResetButton: true);
  }

  Future<void> resetToCurrentDay() async {
    final now = DateTime.now();
    // Clear selected events
    state = state.copyWith(
      selectedDay: now,
      focusedDay: now,
      selectedEvents: [],
      showResetButton: false,
    );
  }

  // Insert a new event into the DB for the currently selected day
  Future<void> addEventForSelectedDay(Event event) async {
    if (state.selectedDay == null) return;

    // Insert into DB
    await _repository.addEvent(event, state.selectedDay!);

    // Refresh events for that day
    final updatedEvents = await _repository.getEventsForDay(state.selectedDay!);

    // Update state
    state = state.copyWith(selectedEvents: updatedEvents);
  }

  // For TableCalendar
  Future<List<Event>> getEventsForDay(DateTime day) async {
    return await _repository.getEventsForDay(day);
  }

  // For your date label
  String getSelectedDayFormatted() {
    final day = state.selectedDay ?? DateTime.now();
    return DateFormat("dd/MM/yyyy").format(day);
  }
}

