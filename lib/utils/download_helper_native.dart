import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadFile(List<int> bytes, String filename, String mimeType) async {
  try {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/$filename';
    final file = File(path);
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(path, mimeType: mimeType)], text: 'Exported $filename');
  } catch (e) {
    // ignore: avoid_print
    print('Error saving/sharing file: $e');
  }
}
