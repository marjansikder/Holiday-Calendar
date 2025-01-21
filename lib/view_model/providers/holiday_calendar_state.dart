
import 'package:holiday_calendar/model/models/event_model.dart';
import 'package:table_calendar/table_calendar.dart';

class HolidayCalendarState {
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<Event> selectedEvents;
  final bool showResetButton;

  const HolidayCalendarState({
    required this.calendarFormat,
    required this.focusedDay,
    required this.selectedDay,
    required this.selectedEvents,
    required this.showResetButton,
  });

  // For copying an existing state with new values
  HolidayCalendarState copyWith({
    CalendarFormat? calendarFormat,
    DateTime? focusedDay,
    DateTime? selectedDay,
    List<Event>? selectedEvents,
    bool? showResetButton,
  }) {
    return HolidayCalendarState(
      calendarFormat: calendarFormat ?? this.calendarFormat,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      showResetButton: showResetButton ?? this.showResetButton,
    );
  }
}