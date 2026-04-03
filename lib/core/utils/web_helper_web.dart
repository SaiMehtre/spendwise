// web_helper_web.dart
import 'dart:html' as html;
import 'dart:typed_data';

void saveAndOpenPdf(Uint8List bytes) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "expense_report.pdf")
    ..click();

  html.Url.revokeObjectUrl(url);
}