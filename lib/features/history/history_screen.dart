import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_colors.dart';
import '../../core/app_options.dart';
import '../../models/journal_entry.dart';
import '../../services/journal_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.controller,
    required this.onGoHome,
  });

  final JournalController controller;
  final VoidCallback onGoHome;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  Future<void> _editEntry(JournalEntry entry) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EntryEditorSheet(
        controller: widget.controller,
        date: DateTime.parse(entry.date),
        entry: entry,
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan catatan tersimpan.')),
    );
  }

  Future<void> _addEntryForSelectedDay() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          EntryEditorSheet(controller: widget.controller, date: selectedDay),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan untuk tanggal ini tersimpan.')),
    );
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus catatan ini?'),
        content: const Text('Catatan ini akan dihapus dari riwayatmu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: terracotta),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await widget.controller.deleteEntry(
      DateTime.parse(entry.date),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Catatan dihapus.' : 'Catatan belum terhapus.'),
        backgroundColor: success ? moss : terracotta,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedEntry = widget.controller.entryFor(selectedDay);
    final selectedDate = DateFormat('d MMMM y', 'id_ID').format(selectedDay);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 34),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Riwayat kecilmu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Pilih tanggal untuk membaca kembali satu kalimatmu.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.68),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: line),
          ),
          child: TableCalendar<JournalEntry>(
            locale: 'id_ID',
            firstDay: DateTime(2020),
            lastDay: DateTime.now(),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            eventLoader: widget.controller.entriesOn,
            onDaySelected: (selected, focused) => setState(() {
              selectedDay = selected;
              focusedDay = focused;
            }),
            onPageChanged: (focused) => focusedDay = focused,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              weekendTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.68),
              ),
              todayDecoration: BoxDecoration(
                color: moss.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: moss,
                fontWeight: FontWeight.w800,
              ),
              selectedDecoration: const BoxDecoration(
                color: moss,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              markerDecoration: const BoxDecoration(
                color: terracotta,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          selectedDate,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.68),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        if (selectedEntry == null)
          EmptyHistory(
            onGoHome: widget.onGoHome,
            onAddEntry: _addEntryForSelectedDay,
          )
        else
          EntryCard(
            entry: selectedEntry,
            onEdit: () => _editEntry(selectedEntry),
            onDelete: () => _deleteEntry(selectedEntry),
          ),
      ],
    );
  }
}

class EmptyHistory extends StatelessWidget {
  const EmptyHistory({
    super.key,
    required this.onGoHome,
    required this.onAddEntry,
  });

  final VoidCallback onGoHome;
  final VoidCallback onAddEntry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: paperDeep.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belum ada kalimat di tanggal ini.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kalau kemarin terlupa, kamu tetap bisa menulisnya sekarang.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onAddEntry,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Tulis tanggal ini'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  backgroundColor: terracotta,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton(
                onPressed: onGoHome,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  foregroundColor: moss,
                  side: const BorderSide(color: moss),
                ),
                child: const Text('Ke hari ini'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final JournalEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.sentence,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              EntryTag(label: moodLabels[entry.mood - 1], color: paperDeep),
              EntryTag(label: entry.theme, color: const Color(0xFFE4EBDD)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    foregroundColor: moss,
                    side: const BorderSide(color: moss),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Hapus catatan',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: terracotta,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EntryEditorSheet extends StatefulWidget {
  const EntryEditorSheet({
    super.key,
    required this.controller,
    required this.date,
    this.entry,
  });

  final JournalController controller;
  final DateTime date;
  final JournalEntry? entry;

  @override
  State<EntryEditorSheet> createState() => _EntryEditorSheetState();
}

class _EntryEditorSheetState extends State<EntryEditorSheet> {
  late final TextEditingController sentenceController;
  late final FocusNode sentenceFocus;
  late int selectedMood;
  late String selectedTheme;

  @override
  void initState() {
    super.initState();
    sentenceController = TextEditingController(
      text: widget.entry?.sentence ?? '',
    );
    sentenceFocus = FocusNode();
    selectedMood = widget.entry?.mood ?? 3;
    selectedTheme = widget.entry?.theme ?? journalThemes.first;
  }

  @override
  void dispose() {
    sentenceController.dispose();
    sentenceFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final sentence = sentenceController.text.trim();
    if (sentence.isEmpty) {
      sentenceFocus.requestFocus();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tulis satu kalimat dulu.')));
      return;
    }

    final success = await widget.controller.saveEntryForDate(
      date: widget.date,
      sentence: sentence,
      mood: selectedMood,
      theme: selectedTheme,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan belum tersimpan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final date = DateFormat('d MMMM y', 'id_ID').format(widget.date);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.entry == null ? 'Tulis catatan' : 'Edit catatan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.68),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: sentenceController,
                focusNode: sentenceFocus,
                maxLength: 160,
                minLines: 4,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Kalimatmu',
                  alignLabelWithHint: true,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Suasana hati',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(moodLabels.length, (index) {
                  final mood = index + 1;
                  final selected = selectedMood == mood;
                  return ChoiceChip(
                    label: Text(moodLabels[index]),
                    selected: selected,
                    onSelected: (_) => setState(() => selectedMood = mood),
                    selectedColor: paperDeep,
                    side: BorderSide(color: selected ? moss : line),
                  );
                }),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: selectedTheme,
                decoration: const InputDecoration(labelText: 'Tema'),
                items: journalThemes
                    .map(
                      (theme) =>
                          DropdownMenuItem(value: theme, child: Text(theme)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedTheme = value);
                },
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: widget.controller.isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: terracotta,
                    foregroundColor: Colors.white,
                  ),
                  child: widget.controller.isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.entry == null
                              ? 'Simpan catatan'
                              : 'Simpan perubahan',
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

class EntryTag extends StatelessWidget {
  const EntryTag({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
