import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/app_options.dart';
import '../../models/journal_entry.dart';
import '../../services/journal_controller.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key, required this.controller});

  final JournalController controller;

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  int selectedRange = 30;

  List<JournalEntry> _entriesForRange() {
    final entries = widget.controller.entries;
    if (selectedRange == 0 || entries.isEmpty) return entries;

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: selectedRange - 1));
    return entries.where((entry) {
      final date = DateTime.parse(entry.date);
      return !date.isBefore(start);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entriesForRange();
    final average = entries.isEmpty
        ? null
        : entries.map((entry) => entry.mood).reduce((a, b) => a + b) /
              entries.length;
    final themeCounts = <String, int>{};
    for (final entry in entries) {
      themeCounts.update(entry.theme, (count) => count + 1, ifAbsent: () => 1);
    }
    final sortedThemes = themeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mostCommonTheme = sortedThemes.isEmpty ? null : sortedThemes.first;
    final targetDays = selectedRange == 0 ? null : selectedRange;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 34),
      children: [
        Text(
          'Jeda untuk melihat kembali',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih rentang waktu untuk melihat pola dari catatanmu sendiri.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.68),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              const [
                _RangeChoice(label: '7 hari', days: 7),
                _RangeChoice(label: '30 hari', days: 30),
                _RangeChoice(label: 'Semua', days: 0),
              ].map((choice) {
                return _ReflectionRangeChip(
                  choice: choice,
                  selected: selectedRange == choice.days,
                  onSelected: () => setState(() => selectedRange = choice.days),
                );
              }).toList(),
        ),
        const SizedBox(height: 22),
        if (entries.isEmpty)
          const ReflectionEmpty()
        else ...[
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'Catatan',
                  value: '${entries.length}',
                  detail: targetDays == null
                      ? 'semua catatan'
                      : '$targetDays hari terakhir',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricTile(
                  label: 'Mood rata-rata',
                  value: average!.toStringAsFixed(1),
                  detail: moodLabels[(average.round() - 1).clamp(0, 4)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (targetDays != null)
            _CoverageBar(count: entries.length, target: targetDays),
          const SizedBox(height: 18),
          SectionSurface(
            title: 'Kebiasaan menulis',
            child: Row(
              children: [
                Expanded(
                  child: _HabitStat(
                    label: 'Streak saat ini',
                    value: '${widget.controller.currentStreak} hari',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _HabitStat(
                    label: 'Streak terpanjang',
                    value: '${widget.controller.longestStreak} hari',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionSurface(
            title: 'Pergerakan mood',
            child: entries.length < 2
                ? const Text(
                    'Tulis satu hari lagi untuk melihat garis perubahan mood.',
                  )
                : SizedBox(height: 210, child: MoodChart(entries: entries)),
          ),
          const SizedBox(height: 18),
          SectionSurface(
            title: 'Tema yang sering muncul',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mostCommonTheme != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Paling sering: ${mostCommonTheme.key}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ...sortedThemes
                    .take(4)
                    .map(
                      (item) => _ThemeBar(
                        label: item.key,
                        count: item.value,
                        total: entries.length,
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionSurface(
            title: 'Kalimat terbaru',
            child: Column(
              children: entries.reversed.take(3).map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat(
                          'd MMM',
                          'id_ID',
                        ).format(DateTime.parse(entry.date)),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: terracotta,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.sentence,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.35,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _RangeChoice {
  const _RangeChoice({required this.label, required this.days});

  final String label;
  final int days;
}

class _ReflectionRangeChip extends StatelessWidget {
  const _ReflectionRangeChip({
    required this.choice,
    required this.selected,
    required this.onSelected,
  });

  final _RangeChoice choice;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(choice.label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: paperDeep,
      labelStyle: TextStyle(
        color: selected
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(color: selected ? moss : line),
    );
  }
}

class _CoverageBar extends StatelessWidget {
  const _CoverageBar({required this.count, required this.target});

  final int count;
  final int target;

  @override
  Widget build(BuildContext context) {
    final progress = (count / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: paperDeep.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Konsistensi',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$count/$target hari',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white,
              color: moss,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeBar extends StatelessWidget {
  const _ThemeBar({
    required this.label,
    required this.count,
    required this.total,
  });

  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: count / total,
              minHeight: 7,
              backgroundColor: paperDeep,
              color: terracotta,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitStat extends StatelessWidget {
  const _HabitStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: moss, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.68),
          ),
        ),
      ],
    );
  }
}

class ReflectionEmpty extends StatelessWidget {
  const ReflectionEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: paperDeep.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'Belum ada catatan di rentang ini. Mulai dengan satu kalimat hari ini.',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            detail,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionSurface extends StatelessWidget {
  const SectionSurface({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class MoodChart extends StatelessWidget {
  const MoodChart({super.key, required this.entries});

  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final spots = entries
        .asMap()
        .entries
        .map((item) => FlSpot(item.key.toDouble(), item.value.mood.toDouble()))
        .toList();
    final maxX = spots.length == 1 ? 1.0 : (spots.length - 1).toDouble();

    return LineChart(
      LineChartData(
        minY: 1,
        maxY: 5,
        minX: 0,
        maxX: maxX,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: line, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: terracotta,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: terracotta.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
