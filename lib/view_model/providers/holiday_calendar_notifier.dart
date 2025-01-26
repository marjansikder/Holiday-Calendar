

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

  // Cache for events (synchronous)
  final Map<DateTime, List<Event>> _dayEventsCache = {};

  // Constructor: Repository initialization
  @override
  HolidayCalendarState build() {
    _repository = ref.watch(holidayRepositoryDbProvider);

    // Ensure DB is seeded with mock data on app startup
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
    // Fetch user-added events asynchronously
    final eventsFromDB = await _repository.getEventsForDay(day);

    // Fetch holidays synchronously
    final holidayEvents = getHolidays(day);

    // Combine events and cache them
    _dayEventsCache[day] = (eventsFromDB ?? []) + (holidayEvents);

    // Update `selectedEvents` if the day matches the selectedDay


    // Notify UI to rebuild if necessary (e.g., Riverpod listeners)
  }

  /// Return all events (user-added + holidays) for a specific day (synchronously)
  List<Event> getEventsForDaySync(DateTime day) {
    // Check the cache; if not loaded, return an empty list
    return _dayEventsCache[day] ?? [];
  }

  /// Called when user selects a day in the calendar
  Future<void> onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    // Load events for the selected day
    await loadEventsForDay(selectedDay);

    // Update state with selected day and events
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

    // Insert event into the database
    await _repository.addEvent(state.selectedDay!, event);

    // Reload events for the day to include the new event
    await loadEventsForDay(state.selectedDay!);
  }

  /// Delete a user-added event from the database for the selected day
  Future<void> deleteEventForSelectedDay(Event event) async {
    if (state.selectedDay == null) return;

    // Delete event from the database
    await _repository.deleteEvent(state.selectedDay!, event);

    // Reload events for the day to reflect the deletion
    await loadEventsForDay(state.selectedDay!);
  }

  /// Reset to the current day and clear selected events
  Future<void> resetToCurrentDay() async {
    final now = DateTime.now();

    // Reload events for today
    await loadEventsForDay(now);

    // Update state to reflect today's date and events
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


