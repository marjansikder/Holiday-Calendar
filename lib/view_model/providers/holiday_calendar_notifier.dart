

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
    // get the repository
    _repository = ref.watch(holidayRepositoryDbProvider);

    // On app startup, ensure DB is seeded with mock data
    // This runs once when the provider is created.
    _repository.initMockData();

    final now = DateTime.now();
    return HolidayCalendarState(
      calendarFormat: CalendarFormat.month,
      focusedDay: now,
      selectedDay: now,
      selectedEvents: [],
      showResetButton: false,
    );
  }





  List<Event> getHolidays(DateTime day) {
    return _repository.getEvents(day);
  }


  Future<List<Event>> getEventsForDay(DateTime day) {
    return _repository.getEventsForDay(day);
  }



  // Called when user taps a day in the calendar
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
    state = state.copyWith(
      selectedDay: now,
      focusedDay: now,
      selectedEvents: [],
      showResetButton: false,
    );
  }

  /// Insert a new event into the DB for the selected day.
  Future<void> addEventForSelectedDay(Event event) async {
    if (state.selectedDay == null) return;
    // Insert to DB
    await _repository.addEvent(state.selectedDay!, event);

    // Re-fetch
    final updatedEvents = await _repository.getEventsForDay(state.selectedDay!);
    state = state.copyWith(selectedEvents: updatedEvents);
  }

  Future<void> deleteEventForSelectedDay(Event event) async {
    if (state.selectedDay == null) return;
    // 1) Delete from DB
    await _repository.deleteEvent(state.selectedDay!, event);

    // 2) Re-fetch updated events
    final updatedEvents = await _repository.getEventsForDay(state.selectedDay!);
    state = state.copyWith(selectedEvents: updatedEvents);
  }


  // Utility to get a formatted selected day
  String getSelectedDayFormatted() {
    final day = state.selectedDay ?? DateTime.now();
    return DateFormat("dd/MM/yyyy").format(day);
  }
}

