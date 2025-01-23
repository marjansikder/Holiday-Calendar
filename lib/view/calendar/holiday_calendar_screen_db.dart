

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
          // TableCalendar
          _buildTableCalendar(calendarState, calendarNotifier),
          // Display selected date
          _buildSelectedDate(calendarNotifier),
          // Show events for the selected day
          _buildEventList(calendarState),
          // The "Today" button
          _buildTodayButton(calendarState, calendarNotifier),
          // The "Add Event" button
          _buildAddEventButton(context, calendarNotifier),
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
      child: TableCalendar(
        focusedDay: state.focusedDay,
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        calendarFormat: state.calendarFormat,
        selectedDayPredicate: (day) => day == state.selectedDay,
        eventLoader: (day) => [],  // We'll handle the list display ourselves.
        onDaySelected: (selectedDay, focusedDay) {
          notifier.onDaySelected(selectedDay, focusedDay);
        },
        onFormatChanged: notifier.onFormatChanged,
        onPageChanged: notifier.onPageChanged,
      ),
    );
  }

  Widget _buildSelectedDate(HolidayCalendarNotifier notifier) {
    final dateStr = notifier.getSelectedDayFormatted();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        height: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppColors.appbarColor.withOpacity(.2),
        ),
        child: Center(
          child: Text(dateStr, style: getCustomTextStyle(fontSize: 12)),
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
          return ListTile(
            title: Text(event.holidayEn),
            subtitle: Text(event.holidayBn),
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
        ElevatedButton(
          onPressed: notifier.resetToCurrentDay,
          child: const Text('Today'),
        ),
      ],
    );
  }

  Widget _buildAddEventButton(
      BuildContext context,
      HolidayCalendarNotifier notifier,
      ) {
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
