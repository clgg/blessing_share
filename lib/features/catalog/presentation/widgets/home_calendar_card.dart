import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/speakable.dart';
import 'package:blessing_share/features/catalog/data/calendar_occasion_catalog.dart';
import 'package:blessing_share/features/catalog/domain/calendar_occasion.dart';
import 'package:blessing_share/features/catalog/presentation/occasion_page.dart';
import 'package:flutter/material.dart';

/// Two-week calendar strip with festival / solar-term markers for 50+ users.
class HomeCalendarCard extends StatelessWidget {
  const HomeCalendarCard({
    this.now,
    super.key,
  });

  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    final today = now ?? DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final days = CalendarOccasionCatalog.twoWeekDays(now: todayDate);
    final yearMonthLabel = '${todayDate.year}年${todayDate.month}月';

    return Speakable(
      text: '节日节气日历，$yearMonthLabel',
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                yearMonthLabel,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 14),
              _CalendarWeekRow(
                days: days.sublist(0, 7),
                today: todayDate,
                onDayTap: (day) => _openDay(context, day),
              ),
              const SizedBox(height: 8),
              _CalendarWeekRow(
                days: days.sublist(7, 14),
                today: todayDate,
                onDayTap: (day) => _openDay(context, day),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDay(BuildContext context, CalendarDay day) {
    final occasion = day.primaryOccasion;
    if (occasion == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OccasionPage(
          occasion: occasion,
          date: day.date,
        ),
      ),
    );
  }
}

class _CalendarWeekRow extends StatelessWidget {
  const _CalendarWeekRow({
    required this.days,
    required this.today,
    required this.onDayTap,
  });

  final List<CalendarDay> days;
  final DateTime today;
  final ValueChanged<CalendarDay> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < days.length; index++) ...[
          if (index > 0) const SizedBox(width: 4),
          Expanded(
            child: _CalendarDayCell(
              day: days[index],
              today: today,
              onTap: days[index].hasOccasion
                  ? () => onDayTap(days[index])
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.today,
    this.onTap,
  });

  final CalendarDay day;
  final DateTime today;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    final date = day.date;
    final isToday = _isSameDay(date, today);
    final isPast = date.isBefore(today);
    final occasion = day.primaryOccasion;

    final Color numberColor;
    if (isToday) {
      numberColor = colors.onPrimary;
    } else if (isPast) {
                    numberColor = colors.textSecondary.withOpacity(0.55);
    } else {
      numberColor = colors.textPrimary;
    }

    final labelColor = isToday
        ? colors.primary
        : (isPast ? colors.textSecondary.withOpacity(0.5) : colors.accent);

    final weekdayColor = isToday
        ? colors.primary
        : (isPast
            ? colors.textSecondary.withOpacity(0.45)
            : colors.textSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Text(
                CalendarOccasionCatalog.weekdayLabel(date),
                style: TextStyle(
                  fontSize: 13,
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                  color: weekdayColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: isToday
                    ? BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: numberColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 18,
                child: occasion == null
                    ? const SizedBox.shrink()
                    : Text(
                        occasion.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
