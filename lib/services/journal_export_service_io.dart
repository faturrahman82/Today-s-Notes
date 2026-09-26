import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> saveJournalJson(String contents) async {
  final directory = await getApplicationDocumentsDirectory();
  final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final file = File('${directory.path}/jurnal-hari-$stamp.json');
  await file.writeAsString(contents);
  return file.path;
}
