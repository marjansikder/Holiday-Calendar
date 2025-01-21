import 'package:flutter/material.dart';
import 'package:holiday_calendar/routes/routes_name.dart';
import 'package:holiday_calendar/view/calendar/holiday_calendar_screen.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings setting) {
    switch (setting.name) {

      case RouteName.holidayCalendar:
        return MaterialPageRoute(
          builder: (context) => const HolidayCalendarScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (context) {
            return const Scaffold(
              body: Text('Something went wrong!'),
            );
          },
        );
    }
  }
}
