import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holiday_calendar/model/models/event_model.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../view_model/providers/holiday_calendar_provider.dart';
import '../../view_model/providers/holiday_calendar_notifier.dart';
import '../../view_model/providers/holiday_calendar_state.dart';
import '../../component/app_colors.dart';
import '../../component/app_styles.dart';
import '../../widgets/custom_app_bar.dart';

class HolidayCalendarScreen extends ConsumerWidget {
  const HolidayCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(holidayCalendarProvider);
    final calendarNotifier = ref.read(holidayCalendarProvider.notifier);

    return Scaffold(
      appBar: CustomAppBarWithShadow(
        title: 'Holiday ${calendarState.focusedDay.year}',
      ),
      body: Column(
        children: [
          _buildTableCalendar(calendarState, calendarNotifier),
          _buildSelectedDate(calendarNotifier),
          _buildEventList(calendarState, calendarNotifier),
          _buildTodayButton(calendarState, calendarNotifier),
          _buildAddEventButton(calendarState, context, calendarNotifier),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  Widget _buildTableCalendar(
    HolidayCalendarState state,
    HolidayCalendarNotifier notifier,
  ) {
    final kToday = DateTime.now();
    final kFirstDay = DateTime(kToday.year, 1, 1);
    final kLastDay = DateTime(kToday.year + 2, kToday.month, kToday.day);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: TableCalendar(
        locale: 'en_US',
        headerStyle: HeaderStyle(
            headerPadding: const EdgeInsets.only(left: 8, right: 8),
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle:
                const TextStyle(fontSize: 16, color: AppColors.blackColor),
            decoration: BoxDecoration(
              color: AppColors.appbarColor.withOpacity(.15),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(5),
                topLeft: Radius.circular(5),
              ),
            )),
        focusedDay: state.focusedDay,
        firstDay: kFirstDay,
        lastDay: kLastDay,
        calendarFormat: state.calendarFormat,
        formatAnimationCurve: Curves.bounceInOut,
        weekNumbersVisible: false,
        selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),
        eventLoader: notifier.getHolidays,
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
            ),
            disabledTextStyle: TextStyle(color: AppColors.disableColor)),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty && day != state.selectedDay) {
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  padding: day.day < 10
                      ? const EdgeInsets.all(15.5)
                      : const EdgeInsets.all(12.0),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
            return null;
          },
          holidayBuilder: (context, day, focusedDay) {
            if (day.weekday == DateTime.friday ||
                day.weekday == DateTime.saturday) {
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
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
          color: AppColors.appbarColor.withOpacity(.15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/icons/img.png",
                width: 14, color: AppColors.optionalColor.withOpacity(.8)),
            SizedBox(width: 5),
            Text(
              resultedDate,
              style: getCustomTextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.optionalColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(
      HolidayCalendarState state, HolidayCalendarNotifier notifier) {
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
              color: AppColors.appbarColor.withOpacity(.15),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      notifier.deleteEventForSelectedDay(event);
                    },
                  ),
                ],
              ),
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

  Widget _buildAddEventButton(
    HolidayCalendarState state,
    BuildContext context,
    HolidayCalendarNotifier notifier,
  ) {
    if (!state.showResetButton) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          _showAddEventDialog(context, notifier);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
    );
  }

  void _showAddEventDialog(
    BuildContext context,
    HolidayCalendarNotifier notifier,
  ) {
    final enController = TextEditingController();
    final bnController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: enController,
                decoration: const InputDecoration(labelText: 'Event (English)'),
              ),
              TextField(
                controller: bnController,
                decoration: const InputDecoration(labelText: 'Event (Bangla)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final enText = enController.text.trim();
                final bnText = bnController.text.trim();
                if (enText.isNotEmpty && bnText.isNotEmpty) {
                  await notifier.addEventForSelectedDay(Event(bnText, enText));
                }
                // Dismiss dialog
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
