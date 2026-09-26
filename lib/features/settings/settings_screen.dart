import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_colors.dart';
import '../../services/journal_controller.dart';
import '../../services/journal_export_service.dart';
import '../../services/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    required this.settings,
  });

  final JournalController controller;
  final SettingsController settings;

  Future<void> _copyExport(BuildContext context) async {
    final payload = const JsonEncoder.withIndent('  ')
        .convert(controller.entries.map((entry) => entry.toJson()).toList());
    await Clipboard.setData(ClipboardData(text: payload));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salinan jurnal sudah ada di clipboard.')),
    );
  }

  Future<void> _saveFile(BuildContext context) async {
    final payload = const JsonEncoder.withIndent('  ')
        .convert(controller.entries.map((entry) => entry.toJson()).toList());
    try {
      final path = await saveJournalJson(payload);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('File tersimpan di $path')));
    } on UnsupportedError {
      if (!context.mounted) return;
      await _copyExport(context);
    }
  }

  Future<void> _confirmClear(BuildContext context) async {
    if (controller.entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada catatan yang perlu dihapus.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus semua catatan?'),
        content: const Text(
          'Tindakan ini menghapus seluruh jurnal dari perangkat dan tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: terracotta),
            child: const Text('Hapus semua'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final success = await controller.clearAll();
    if (!context.mounted) return;
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final entries = controller.entries;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 34),
        children: [
          Text(
            'Data jurnal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            icon: Icons.ios_share_outlined,
            title: 'Salin data jurnal',
            detail: '${entries.length} catatan dalam format JSON',
            onTap: () => _copyExport(context),
            trailing: const Icon(Icons.chevron_right),
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            icon: Icons.save_alt_outlined,
            title: 'Simpan sebagai file',
            detail: 'Buat file JSON di penyimpanan aplikasi',
            onTap: () => _saveFile(context),
            trailing: const Icon(Icons.chevron_right),
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            icon: Icons.delete_outline,
            title: 'Hapus semua catatan',
            detail: 'Bersihkan data yang tersimpan di perangkat ini',
            onTap: () => _confirmClear(context),
            titleColor: terracotta,
            trailing: const Icon(Icons.chevron_right),
          ),
          const SizedBox(height: 28),
          Text(
            'Tampilan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: line),
            ),
            child: Row(
              children: [
                const Icon(Icons.dark_mode_outlined, color: moss),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Mode gelap',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Switch(
                  value: settings.isDarkMode,
                  onChanged: settings.setDarkMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Tentang jurnal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: paperDeep.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Jurnal Hari Ini menyimpan satu kalimat per hari secara offline. Data tetap berada di perangkatmu sampai kamu memilih untuk menghapusnya.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
    required this.trailing,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;
  final Widget trailing;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: line),
          ),
          child: Row(
            children: [
              Icon(icon, color: titleColor ?? moss),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color:
                            titleColor ??
                            Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
              IconTheme(
                data: IconThemeData(
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.68),
                ),
                child: trailing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
