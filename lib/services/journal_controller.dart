import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';

String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

class JournalController extends ChangeNotifier {
  JournalController(this.preferences) {
    _load();
  }

  final SharedPreferences preferences;
  static const _storageKey = 'journal_entries';
  final Map<String, JournalEntry> _entries = {};

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  List<JournalEntry> get entries =>
      _entries.values.toList()..sort((a, b) => a.date.compareTo(b.date));

  int get currentStreak {
    final savedDates = _entries.keys.toSet();
    var day = DateTime.now();
    var streak = 0;
    while (savedDates.contains(dateKey(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get longestStreak {
    if (_entries.isEmpty) return 0;
    final dates = _entries.keys.map(DateTime.parse).toList()..sort();
    var longest = 1;
    var running = 1;
    for (var index = 1; index < dates.length; index++) {
      final difference = dates[index].difference(dates[index - 1]).inDays;
      if (difference == 1) {
        running++;
        if (running > longest) longest = running;
      } else if (difference > 1) {
        running = 1;
      }
    }
    return longest;
  }

  JournalEntry? entryFor(DateTime date) => _entries[dateKey(date)];

  Future<void> _load() async {
    try {
      final raw = preferences.getString(_storageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          final entry = JournalEntry.fromJson(
            Map<String, dynamic>.from(item as Map),
          );
          _entries[entry.date] = entry;
        }
      }
    } catch (_) {
      errorMessage = 'Catatan tersimpan tidak dapat dibaca.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveEntry({
    required String sentence,
    required int mood,
    required String theme,
  }) {
    return saveEntryForDate(
      date: DateTime.now(),
      sentence: sentence,
      mood: mood,
      theme: theme,
    );
  }

  Future<bool> saveEntryForDate({
    required DateTime date,
    required String sentence,
    required int mood,
    required String theme,
  }) async {
    final key = dateKey(date);
    final entry = JournalEntry(
      date: key,
      sentence: sentence.trim(),
      mood: mood,
      theme: theme,
    );

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      _entries[key] = entry;
      final payload = jsonEncode(
        _entries.values.map((item) => item.toJson()).toList(),
      );
      final saved = await preferences.setString(_storageKey, payload);
      if (!saved) throw Exception('Storage rejected write');
      return true;
    } catch (_) {
      errorMessage = 'Catatan belum tersimpan. Coba lagi.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> clearAll() async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final removed = await preferences.remove(_storageKey);
      if (!removed && _entries.isNotEmpty) {
        throw Exception('Storage rejected delete');
      }
      _entries.clear();
      return true;
    } catch (_) {
      errorMessage = 'Catatan belum berhasil dihapus.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEntry(DateTime date) async {
    final key = dateKey(date);
    final removed = _entries.remove(key);
    if (removed == null) return true;

    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final payload = jsonEncode(
        _entries.values.map((item) => item.toJson()).toList(),
      );
      final saved = await preferences.setString(_storageKey, payload);
      if (!saved) throw Exception('Storage rejected delete');
      return true;
    } catch (_) {
      _entries[key] = removed;
      errorMessage = 'Catatan belum berhasil dihapus.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  List<JournalEntry> entriesOn(DateTime day) {
    final entry = entryFor(day);
    return entry == null ? const [] : [entry];
  }
}
