class DateUtilsHelper {
  static bool isBetween(DateTime date, DateTime start, DateTime end) {
    return (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
        date.isBefore(end);
  }

  static DateTime startOfDay(DateTime now) =>
      DateTime(now.year, now.month, now.day);

  static DateTime startOfWeek(DateTime now) =>
      DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));

  static DateTime startOfMonth(DateTime now) =>
      DateTime(now.year, now.month, 1);

  static DateTime startOfYear(DateTime now) =>
      DateTime(now.year, 1, 1);
}