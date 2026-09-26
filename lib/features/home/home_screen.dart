import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../core/app_options.dart';
import '../../services/journal_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller, this.onOpenSettings});

  final JournalController controller;
  final VoidCallback? onOpenSettings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController sentenceController;
  late final FocusNode sentenceFocus;
  int selectedMood = 3;
  String selectedTheme = journalThemes.first;

  @override
  void initState() {
    super.initState();
    sentenceController = TextEditingController();
    sentenceFocus = FocusNode();
    _loadToday();
  }

  void _loadToday() {
    final entry = widget.controller.entryFor(DateTime.now());
    if (entry == null) return;
    sentenceController.text = entry.sentence;
    selectedMood = entry.mood;
    selectedTheme = entry.theme;
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

    final success = await widget.controller.saveEntry(
      sentence: sentence,
      mood: selectedMood,
      theme: selectedTheme,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Catatan hari ini tersimpan.' : 'Catatan belum tersimpan.',
        ),
        backgroundColor: success ? moss : terracotta,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM y', 'id_ID').format(now);
    final existingEntry = widget.controller.entryFor(now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 34),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jurnal Hari Ini',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.68),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onOpenSettings != null)
                  IconButton(
                    tooltip: 'Buka pengaturan',
                    onPressed: widget.onOpenSettings,
                    icon: const Icon(Icons.settings_outlined),
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.68),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ProgressStamp(
                  dayCount: widget.controller.entries.length,
                  currentStreak: widget.controller.currentStreak,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 34),
        Text(
          'Simpan satu hal\ndari hari ini.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Tidak perlu lengkap. Cukup sesuatu yang ingin kamu ingat.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.68),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 26),
        TextField(
          controller: sentenceController,
          focusNode: sentenceFocus,
          maxLength: 160,
          minLines: 4,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Kalimatmu hari ini',
            hintText: 'Contoh: Hari ini aku akhirnya berani mulai.',
            alignLabelWithHint: true,
            counterText: '',
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: sentenceController,
            builder: (context, value, _) => Text(
              '${value.text.length}/160',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.68),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
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
              labelStyle: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.68),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(color: selected ? moss : line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: selectedTheme,
          decoration: const InputDecoration(labelText: 'Tema hari ini'),
          items: journalThemes
              .map(
                (theme) => DropdownMenuItem(value: theme, child: Text(theme)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => selectedTheme = value);
          },
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: widget.controller.isSaving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: widget.controller.isSaving
                  ? const SizedBox(
                      key: ValueKey('saving'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      key: const ValueKey('idle'),
                      existingEntry == null
                          ? 'Simpan catatan'
                          : 'Perbarui catatan',
                    ),
            ),
          ),
        ),
        if (existingEntry != null) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Catatan hari ini sudah ada. Kamu masih bisa memperbaruinya.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.68),
              ),
            ),
          ),
        ],
        if (widget.controller.errorMessage != null) ...[
          const SizedBox(height: 14),
          MessageBox(message: widget.controller.errorMessage!),
        ],
      ],
    );
  }
}

class ProgressStamp extends StatelessWidget {
  const ProgressStamp({
    super.key,
    required this.dayCount,
    required this.currentStreak,
  });

  final int dayCount;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final shownCount = dayCount.clamp(0, 30);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: paperDeep,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$shownCount/30',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'hari tersimpan',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.68),
            ),
          ),
          if (currentStreak > 0) ...[
            const SizedBox(height: 3),
            Text(
              '$currentStreak hari berturut-turut',
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: moss, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

class MessageBox extends StatelessWidget {
  const MessageBox({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8E0D8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
