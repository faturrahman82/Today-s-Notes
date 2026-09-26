import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jurnalhariini/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('pengguna dapat menyimpan satu kalimat hari ini', (tester) async {
    await initializeDateFormatting('id_ID');
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(JurnalApp(preferences: preferences));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(find.text('Simpan satu hal\ndari hari ini.'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Hari ini aku akhirnya berani mulai.',
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.byType(FilledButton), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Catatan hari ini tersimpan.'), findsOneWidget);
    expect(preferences.getString('journal_entries'), isNotNull);
  });
}
