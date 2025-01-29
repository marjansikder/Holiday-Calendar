

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_calendar/model/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../model/repository/holiday_repository.dart';
import 'holiday_calendar_provider.dart';
import 'holiday_calendar_state.dart';

class HolidayCalendarNotifier extends Notifier<HolidayCalendarState> {
  late final HolidayRepository _repository;


  final Map<DateTime, List<Event>> _dayEventsCache = {};


  @override
  HolidayCalendarState build() {
    _repository = ref.watch(holidayRepositoryDbProvider);


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


  /// Get holidays for a specific day (synchronous)
  List<Event> getHolidays(DateTime day) {
    return _repository.getEvents(day) ?? [];
  }

  /// Fetch all events (user-added + holidays) for a specific day and store them
  Future<void> loadEventsForDay(DateTime day) async {

    final eventsFromDB = await _repository.getEventsForDay(day);

    final holidayEvents = getHolidays(day);

    _dayEventsCache[day] = (eventsFromDB + holidayEvents);
  }

  /// Return all events (user-added + holidays) for a specific day (synchronously)
  List<Event> getEventsForDaySync(DateTime day) {
    return _dayEventsCache[day] ?? [];
  }

  /// Called when user selects a day in the calendar
  Future<void> onDaySelected(DateTime selectedDay, DateTime focusedDay) async {

    await loadEventsForDay(selectedDay);


    state = state.copyWith(
      selectedDay: selectedDay,
      focusedDay: focusedDay,
      selectedEvents: getEventsForDaySync(selectedDay),
      showResetButton: true,
    );
  }

  /// Insert a new user-added event into the database for the selected day
  Future<void> addEventForSelectedDay(Event event) async {
    if (state.selectedDay == null) return;


    await _repository.addEvent(state.selectedDay!, event);


    await loadEventsForDay(state.selectedDay!);
  }

  /// Delete a user-added event from the database for the selected day
  Future<void> deleteEventForSelectedDay(Event event) async {
    if (state.selectedDay == null) return;


    await _repository.deleteEvent(state.selectedDay!, event);


    await loadEventsForDay(state.selectedDay!);
  }

  /// Reset to the current day and clear selected events
  Future<void> resetToCurrentDay() async {
    final now = DateTime.now();


    await loadEventsForDay(now);


    state = state.copyWith(
      selectedDay: now,
      focusedDay: now,
      selectedEvents: getEventsForDaySync(now),
      showResetButton: false,
    );
  }

  /// Called when the calendar format changes (e.g., month to week)
  void onFormatChanged(CalendarFormat newFormat) {
    if (state.calendarFormat != newFormat) {
      state = state.copyWith(calendarFormat: newFormat);
    }
  }

  /// Called when the user changes pages in the calendar
  void onPageChanged(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay, showResetButton: true);
  }

  /// Utility to get a formatted string for the selected day
  String getSelectedDayFormatted() {
    final day = state.selectedDay ?? DateTime.now();
    return DateFormat("dd/MM/yyyy").format(day);
  }
}


