import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_calendar/component/app_colors.dart';
import 'package:holiday_calendar/component/app_styles.dart';
import 'package:holiday_calendar/view_model/providers/holiday_calendar_notifier.dart';
import 'package:holiday_calendar/view_model/providers/holiday_calendar_provider.dart';
import 'package:holiday_calendar/view_model/providers/holiday_calendar_state.dart';
import 'package:holiday_calendar/widgets/custom_app_bar.dart';
import 'package:table_calendar/table_calendar.dart';

class HolidayCalendarScreen extends ConsumerWidget {
  const HolidayCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod: read the entire calendar state
    final calendarState = ref.watch(holidayCalendarProvider);
    // Also get the Notifier to dispatch actions
    final calendarNotifier = ref.read(holidayCalendarProvider.notifier);

    return Scaffold(
      appBar: CustomAppBarWithShadow(
          title: 'Holiday ${calendarState.focusedDay.year}'),
      body: Column(
        children: [
          const SizedBox(height: 2),
          // The calendar
          _buildTableCalendar(calendarState, calendarNotifier),
          const SizedBox(height: 8),
          // The selected date label
          _buildSelectedDate(calendarNotifier),
          const SizedBox(height: 10),
          // The events list
          _buildEventList(calendarState),
          const SizedBox(height: 12),
          // The Today button
          _buildTodayButton(calendarState, calendarNotifier),
        ],
      ),
    );
  }

  Widget _buildTableCalendar(
    HolidayCalendarState state,
    HolidayCalendarNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: AppColors.whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.3),
              offset: const Offset(0.0, 0.05),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: TableCalendar(
          locale: 'en_US',
          headerStyle: HeaderStyle(
              //headerMargin: EdgeInsets.only(left: 8, right: 8, bottom: 12, top: 8),
              headerPadding: const EdgeInsets.only(left: 8, right: 8),
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle:
                  const TextStyle(fontSize: 16, color: AppColors.blackColor),
              decoration: BoxDecoration(
                color: AppColors.appbarColor.withOpacity(.2),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5),
                  topLeft: Radius.circular(5),
                ),
              )),
          focusedDay: state.focusedDay,
          firstDay: DateTime(state.focusedDay.year, 1, 1),
          lastDay: DateTime(state.focusedDay.year + 5, 12, 31),
          calendarFormat: state.calendarFormat,
          weekNumbersVisible: false,
          // Checking if the day is the selected day
          selectedDayPredicate: (day) =>
              day.year == state.selectedDay?.year &&
              day.month == state.selectedDay?.month &&
              day.day == state.selectedDay?.day,
          eventLoader: notifier.getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          weekendDays: const [DateTime.friday, DateTime.saturday],
          onDaySelected: (selectedDay, focusedDay) {
            notifier.onDaySelected(selectedDay, focusedDay);
          },
          holidayPredicate: (day) {
            return day.weekday == DateTime.friday ||
                day.weekday == DateTime.saturday;
          },
          daysOfWeekHeight: 40,
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: AppColors.optionalColor),
            weekendStyle: TextStyle(color: Colors.red),
          ),
          onFormatChanged: notifier.onFormatChanged,
          onPageChanged: notifier.onPageChanged,
          calendarStyle: CalendarStyle(
              markerSize: 0,
              outsideDaysVisible: false,
              canMarkersOverflow: false,
              selectedTextStyle: const TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: AppColors.appbarColor.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              defaultDecoration: const BoxDecoration(
                shape: BoxShape.circle,
              )),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isNotEmpty && day != state.selectedDay) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    padding: day.day < 10
                        ? const EdgeInsets.all(16.0)
                        : const EdgeInsets.all(12.0),
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
              return null;
            },
            selectedBuilder: (context, day, focusedDay) {
              return Center(
                child: Container(
                  decoration: state.selectedDay == day
                      ? BoxDecoration(
                          //color: AppColors.kPending.withOpacity(0.4),
                          border: Border.all(color: AppColors.appbarColor),
                          shape: BoxShape.circle,
                        )
                      : const BoxDecoration(
                          color: AppColors.appbarColor,
                          shape: BoxShape.circle,
                        ),
                  padding: day.day < 10
                      ? const EdgeInsets.all(16.0)
                      : const EdgeInsets.all(12.0),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                        color: state.selectedDay == day
                            ? AppColors.appbarColor
                            : AppColors.whiteColor),
                  ),
                ),
              );
            },
            holidayBuilder: (context, day, focusedDay) {
              if (day.weekday == DateTime.friday ||
                  day.weekday == DateTime.saturday) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    padding: day.day < 10
                        ? const EdgeInsets.all(16.0)
                        : const EdgeInsets.all(12.0),
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
              return null; // Default rendering for other days
            },
          ),
          // ... plus your styling/calendarBuilders ...
        ),
      ),
    );
  }

  Widget _buildSelectedDate(HolidayCalendarNotifier notifier) {
    final resultedDate = notifier.getSelectedDayFormatted();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppColors.appbarColor.withOpacity(.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/icons/img.png", width: 14, color: AppColors.blackColor.withOpacity(.6)),
            SizedBox(width: 5),
            Text(
              resultedDate,
              style: getCustomTextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(HolidayCalendarState state) {
    final events = state.selectedEvents;
    return Expanded(
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.appbarColor.withOpacity(.2),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.holidayEn,
                  style: getCustomTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                Text(
                  event.holidayBn,
                  style: getCustomTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: AppColors.titleColor,
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayButton(
    HolidayCalendarState state,
    HolidayCalendarNotifier notifier,
  ) {
    if (!state.showResetButton) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: InkWell(
            onTap: notifier.resetToCurrentDay,
            child: Container(
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: AppColors.appbarColor.withOpacity(.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.3),
                    offset: const Offset(0.0, 3.0),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
