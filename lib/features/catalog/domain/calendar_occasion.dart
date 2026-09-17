enum CalendarOccasionKind { festival, solarTerm }

/// A festival or solar-term marker on a Gregorian date.
class CalendarOccasion {
  const CalendarOccasion({
    required this.label,
    required this.kind,
    required this.categoryId,
    this.filterTag,
  });

  /// Short label shown under the day number (e.g. 中秋 / 秋分).
  final String label;
  final CalendarOccasionKind kind;

  /// Catalog category to open: `festival` or `solar_term`.
  final String categoryId;

  /// Optional chip filter on [CategoryPage].
  final String? filterTag;
}

class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.occasions,
  });

  final DateTime date;
  final List<CalendarOccasion> occasions;

  bool get hasOccasion => occasions.isNotEmpty;
  CalendarOccasion? get primaryOccasion =>
      occasions.isEmpty ? null : occasions.first;
}
