import 'package:blessing_share/features/catalog/domain/calendar_occasion.dart';

/// Built-in festival / solar-term dates for the demo calendar card.
abstract final class CalendarOccasionCatalog {
  /// The 24 solar terms, in traditional order (calendar markers).
  static const List<String> solarTerms = [
    '立春',
    '雨水',
    '惊蛰',
    '春分',
    '清明',
    '谷雨',
    '立夏',
    '小满',
    '芒种',
    '夏至',
    '小暑',
    '大暑',
    '立秋',
    '处暑',
    '白露',
    '秋分',
    '寒露',
    '霜降',
    '立冬',
    '小雪',
    '大雪',
    '冬至',
    '小寒',
    '大寒',
  ];

  static const _weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];

  static String weekdayLabel(DateTime date) =>
      _weekdayLabels[date.weekday - 1];

  /// Monday of the week containing [day] (local date, time stripped).
  static DateTime startOfWeek(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Fourteen days: current week + next week.
  static List<CalendarDay> twoWeekDays({DateTime? now}) {
    final today = now ?? DateTime.now();
    final start = startOfWeek(today);
    return List<CalendarDay>.generate(14, (index) {
      final date = start.add(Duration(days: index));
      return CalendarDay(
        date: date,
        occasions: occasionsOn(date),
      );
    });
  }

  static List<CalendarOccasion> occasionsOn(DateTime date) {
    final key = _key(date);
    return List.unmodifiable(_occasionsByDate[key] ?? const []);
  }

  static String _key(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static CalendarOccasion _festival(String label, {String? filterTag}) {
    return CalendarOccasion(
      label: label,
      kind: CalendarOccasionKind.festival,
      categoryId: 'festival',
      filterTag: filterTag ?? label,
    );
  }

  static CalendarOccasion _solar(String label) {
    return CalendarOccasion(
      label: label,
      kind: CalendarOccasionKind.solarTerm,
      categoryId: 'solar_term',
      filterTag: label,
    );
  }

  /// Gregorian anchors for 2025–2027 demos (major festivals + 24 solar terms).
  static final Map<String, List<CalendarOccasion>> _occasionsByDate = {
    // —— 2025 ——
    '2025-01-01': [_festival('元旦')],
    '2025-01-05': [_solar('小寒')],
    '2025-01-20': [_solar('大寒')],
    '2025-01-29': [_festival('春节')],
    '2025-02-03': [_solar('立春')],
    '2025-02-12': [_festival('元宵', filterTag: '元宵节')],
    '2025-02-14': [_festival('情人节')],
    '2025-02-18': [_solar('雨水')],
    '2025-03-05': [_solar('惊蛰')],
    '2025-03-08': [_festival('妇女节')],
    '2025-03-12': [_festival('植树节')],
    '2025-03-20': [_solar('春分')],
    '2025-04-04': [_solar('清明'), _festival('清明', filterTag: '清明节')],
    '2025-04-20': [_solar('谷雨')],
    '2025-05-01': [_festival('劳动节')],
    '2025-05-04': [_festival('青年节')],
    '2025-05-05': [_solar('立夏')],
    '2025-05-11': [_festival('母亲节')],
    '2025-05-21': [_solar('小满')],
    '2025-05-31': [_festival('端午', filterTag: '端午节')],
    '2025-06-01': [_festival('儿童节')],
    '2025-06-05': [_solar('芒种')],
    '2025-06-15': [_festival('父亲节')],
    '2025-06-21': [_solar('夏至')],
    '2025-07-01': [_festival('建党节')],
    '2025-07-07': [_solar('小暑')],
    '2025-07-22': [_solar('大暑')],
    '2025-08-01': [_festival('建军节')],
    '2025-08-07': [_solar('立秋')],
    '2025-08-23': [_solar('处暑')],
    '2025-09-07': [_solar('白露')],
    '2025-09-10': [_festival('教师节')],
    '2025-09-23': [_solar('秋分')],
    '2025-10-01': [_festival('国庆', filterTag: '国庆节')],
    '2025-10-06': [_festival('中秋', filterTag: '中秋节')],
    '2025-10-08': [_solar('寒露')],
    '2025-10-23': [_solar('霜降')],
    '2025-11-07': [_solar('立冬')],
    '2025-11-22': [_solar('小雪')],
    '2025-11-27': [_festival('感恩节')],
    '2025-12-07': [_solar('大雪')],
    '2025-12-21': [_solar('冬至')],
    '2025-12-25': [_festival('圣诞', filterTag: '圣诞节')],

    // —— 2026 ——
    '2026-01-01': [_festival('元旦')],
    '2026-01-05': [_solar('小寒')],
    '2026-01-20': [_solar('大寒')],
    '2026-02-04': [_solar('立春')],
    '2026-02-14': [_festival('情人节')],
    '2026-02-17': [_festival('春节')],
    '2026-02-19': [_solar('雨水')],
    '2026-03-03': [_festival('元宵', filterTag: '元宵节')],
    '2026-03-05': [_solar('惊蛰')],
    '2026-03-08': [_festival('妇女节')],
    '2026-03-12': [_festival('植树节')],
    '2026-03-20': [_solar('春分')],
    '2026-04-05': [_solar('清明'), _festival('清明', filterTag: '清明节')],
    '2026-04-20': [_solar('谷雨')],
    '2026-05-01': [_festival('劳动节')],
    '2026-05-04': [_festival('青年节')],
    '2026-05-05': [_solar('立夏')],
    '2026-05-10': [_festival('母亲节')],
    '2026-05-21': [_solar('小满')],
    '2026-06-01': [_festival('儿童节')],
    '2026-06-05': [_solar('芒种')],
    '2026-06-19': [_festival('端午', filterTag: '端午节')],
    '2026-06-21': [_festival('父亲节'), _solar('夏至')],
    '2026-07-01': [_festival('建党节')],
    '2026-07-07': [_solar('小暑')],
    '2026-07-23': [_solar('大暑')],
    '2026-08-01': [_festival('建军节')],
    '2026-08-07': [_solar('立秋')],
    '2026-08-23': [_solar('处暑')],
    '2026-09-07': [_solar('白露')],
    '2026-09-10': [_festival('教师节')],
    '2026-09-23': [_solar('秋分')],
    '2026-09-25': [_festival('中秋', filterTag: '中秋节')],
    '2026-10-01': [_festival('国庆', filterTag: '国庆节')],
    '2026-10-08': [_solar('寒露')],
    '2026-10-18': [_festival('重阳', filterTag: '重阳节')],
    '2026-10-23': [_solar('霜降')],
    '2026-11-07': [_solar('立冬')],
    '2026-11-22': [_solar('小雪')],
    '2026-11-26': [_festival('感恩节')],
    '2026-12-07': [_solar('大雪')],
    '2026-12-22': [_solar('冬至')],
    '2026-12-25': [_festival('圣诞', filterTag: '圣诞节')],

    // —— 2027 ——
    '2027-01-01': [_festival('元旦')],
    '2027-01-05': [_solar('小寒')],
    '2027-01-20': [_solar('大寒')],
    '2027-02-04': [_solar('立春')],
    '2027-02-06': [_festival('春节')],
  };
}
