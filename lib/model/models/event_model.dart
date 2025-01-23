class Event {
  final String holidayBn;
  final String holidayEn;

  /// A flag to indicate if this is a built-in holiday
  /// or a user-created event
  final bool isHoliday;

  const Event(this.holidayBn, this.holidayEn, {this.isHoliday = true});
}
