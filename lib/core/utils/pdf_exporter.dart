import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:html' as html;

Future<void> saveAndOpenPdf(Uint8List bytes) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "expense_report.pdf")
    ..click();

  html.Url.revokeObjectUrl(url);
}

Future<Uint8List> generateProfessionalPdf(List expenses, String filterTitle) async {
  final pdf = pw.Document();

  final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  // 🔥 Load Logo (optional)
  final logo = await rootBundle.load('assets/images/logo.png');
  final logoBytes = logo.buffer.asUint8List();

  double total = 0;
  for (var e in expenses) {
    total += e.amount;
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            // 🔥 HEADER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(pw.MemoryImage(logoBytes), width: 50),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Expense Report",
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text(filterTitle),
                    pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
                  ],
                )
              ],
            ),

            pw.SizedBox(height: 20),

            // 🔥 TABLE HEADER
            pw.Container(
              color: PdfColors.grey300,
              padding: pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Expanded(child: pw.Text("Date")),
                  pw.Expanded(child: pw.Text("Category")),
                  pw.Expanded(child: pw.Text("Amount")),
                ],
              ),
            ),

            // 🔥 TABLE DATA
            ...expenses.map((e) {
              return pw.Container(
                padding: pw.EdgeInsets.all(8),
                child: pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text(DateFormat('dd-MM-yyyy').format(e.date))),
                    pw.Expanded(child: pw.Text(e.category)),
                    pw.Expanded(child: pw.Text(formatter.format(e.amount))),
                  ],
                ),
              );
            }),

            pw.Divider(),

            // 🔥 TOTAL
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Total: ${formatter.format(total)}",
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}