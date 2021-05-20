import 'dart:typed_data';

import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<Uint8List> saveDocument(Document pdf) async {
    final bytes = await pdf.save();
    return bytes;
  }
}
