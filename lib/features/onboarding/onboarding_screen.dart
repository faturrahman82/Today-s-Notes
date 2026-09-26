import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int page = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (page == 2) {
      widget.onDone();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _OnboardingPage(
        icon: Icons.edit_note_outlined,
        eyebrow: 'Satu kalimat cukup',
        title: 'Simpan bagian kecil dari harimu.',
        detail: 'Tidak perlu menulis panjang. Satu kalimat bisa menjadi cara sederhana untuk berhenti sejenak.',
      ),
      const _OnboardingPage(
        icon: Icons.mood_outlined,
        eyebrow: 'Kenali polanya',
        title: 'Tambahkan mood dan tema.',
        detail: 'Setelah beberapa hari, kamu bisa melihat suasana hati dan hal yang sering memenuhi pikiranmu.',
      ),
      const _OnboardingPage(
        icon: Icons.calendar_month_outlined,
        eyebrow: 'Tetap fleksibel',
        title: 'Lupa kemarin? Tidak masalah.',
        detail: 'Kamu tetap bisa memilih tanggal yang sudah lewat dan mengisi catatan kapan saja.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onDone,
                  child: const Text('Lewati'),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  onPageChanged: (value) => setState(() => page = value),
                  children: pages,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == page ? terracotta : paperDeep,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: terracotta,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(page == 2 ? 'Mulai menulis' : 'Lanjut'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: paperDeep,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(icon, size: 58, color: moss),
            ),
            const SizedBox(height: 34),
            Text(
              eyebrow.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: terracotta,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.68),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
