import 'package:flutter/material.dart';
import 'package:holiday_calendar/routes/routes_name.dart';
import 'package:holiday_calendar/view/calendar/holiday_calendar_screen_db.dart';


class AppRoutes {
  static const String holidayCalendarScreen = RouteName.holidayCalendar;

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      holidayCalendarScreen: (context) => const HolidayCalendarScreen(),
    };
  }
}
