import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';
import 'package:holiday_calendar/model/models/event_model.dart';


class HolidayRepository {
  // The mock event data:
  final LinkedHashMap<DateTime, List<Event>> _mockEvents = LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: (DateTime key) => key.day * 1000000 + key.month * 10000 + key.year,
  )..addAll({
    DateTime(2025, 2, 15): [const Event('শবে বরাত', 'Shab e-Barat')],
    DateTime(2025, 2, 21): [
      Event('আন্তর্জাতিক মাতৃভাষা দিবস', 'International Mother Language Day')
    ],
    DateTime(2025, 3, 26): [const Event('স্বাধীনতা দিবস', 'Independence Day')],
    DateTime(2025, 3, 28): [const Event('শবে কদর', 'Shab e-Qadr')],
    DateTime(2025, 3, 29): [const Event('ঈদুল ফিতরের ছুটি', 'Eid ul-Fitr Holiday')],
    DateTime(2025, 3, 30): [const Event('ঈদুল ফিতরের ছুটি', 'Eid ul-Fitr Holiday')],
    DateTime(2025, 3, 31): [Event('ঈদুল ফিতরের ছুটি', 'Eid ul-Fitr Holiday')],
    DateTime(2025, 4, 1): [Event('ঈদুল ফিতরের ছুটি', 'Eid ul-Fitr Holiday')],
    DateTime(2025, 4, 2): [Event('ঈদুল ফিতরের ছুটি', 'Eid ul-Fitr Holiday')],
    DateTime(2025, 4, 14): [Event('পহেলা বৈশাখ', 'Pahela Baishakh')],
    DateTime(2025, 5, 1): [Event('মে দিবস', 'May Day')],
    DateTime(2025, 5, 11): [Event('বুদ্ধ পূর্ণিমা', 'Buddha Purnima')],
    DateTime(2025, 6, 5): [Event('ঈদুল আযহার ছুটি', 'Eid al-Adha Holiday')],
    DateTime(2025, 6, 7): [Event('ঈদুল আযহার ছুটি', 'Eid al-Adha Holiday')],
    DateTime(2025, 6, 8): [Event('ঈদুল আযহার ছুটি', 'Eid al-Adha Holiday')],
    DateTime(2025, 6, 9): [Event('ঈদুল আযহার ছুটি', 'Eid al-Adha Holiday')],
    DateTime(2025, 6, 10): [Event('ঈদুল আযহার ছুটি', 'Eid al-Adha Holiday')],
    DateTime(2025, 7, 6): [Event('আশুরা', 'Ashura')],
    DateTime(2025, 8, 16): [Event('জন্মাষ্টমী', 'Janmashtami')],
    DateTime(2025, 9, 5): [Event('ঈদে মিলাদুন্নবী', 'Eid e-Milad-un Nabi')],
    DateTime(2025, 10, 1): [Event('দুর্গাপূজা', 'Durga Puja')],
    DateTime(2025, 10, 2): [Event('দুর্গাপূজা', 'Durga Puja')],
    DateTime(2025, 12, 16): [Event('বিজয় দিবস', 'Victory Day')],
    DateTime(2025, 12, 25): [Event('বড়দিন', 'Christmas Day')],
  });

  // For reading the entire event map
  LinkedHashMap<DateTime, List<Event>> getAllEvents() => _mockEvents;

  // For reading events for a specific day
  List<Event> getEventsForDay(DateTime day) {
    return _mockEvents[day] ?? [];
  }
}
