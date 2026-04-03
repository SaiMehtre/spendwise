import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> generateProfessionalPdf(List expenses, String filterTitle) async {
  final pdf = pw.Document();

  /// ✅ LOAD FONTS (UNICODE FIX)
  final fontRegular = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  final fontBold = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");

  final ttfRegular = pw.Font.ttf(fontRegular);
  final ttfBold = pw.Font.ttf(fontBold);

  final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  

  /// 🔥 OPTIONAL LOGO (COMMENTED)
  // final logo = await rootBundle.load('assets/images/logo.png');
  // final logoBytes = logo.buffer.asUint8List();

  double total = 0;
  for (var e in expenses) {
    total += e.amount;
  }

  double maxExpense = 0;
  for (var e in expenses) {
    if (e.amount > maxExpense) maxExpense = e.amount;
  }

  double avg = expenses.isEmpty ? 0 : total / expenses.length;

  pdf.addPage(
    pw.MultiPage(
      theme: pw.ThemeData.withFont(
        base: ttfRegular,
        bold: ttfBold,
      ),
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return [

          /// 🔥 HEADER
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // pw.Image(pw.MemoryImage(logoBytes), width: 50),

                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Expense Report",
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      filterTitle,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),

                pw.Text(
                  DateFormat('dd MMM yyyy').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [

              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text("Total\n${formatter.format(total)}"),
              ),

              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text("Max\n${formatter.format(maxExpense)}"),
              ),

              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text("Avg\n${formatter.format(avg)}"),
              ),

              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.purple100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text("Entries\n${expenses.length}"),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          /// 🔥 TABLE
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
            },
            children: [

              /// HEADER ROW
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Date", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Category", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Amount", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),

              /// DATA ROWS
              ...(expenses.isEmpty
              ? [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        alignment: pw.Alignment.center,
                        // Make it span visually by setting width to all columns combined
                        child: pw.Center(
                          child: pw.Text(
                            "No expenses found for selected filters",
                            style: pw.TextStyle(
                              fontStyle: pw.FontStyle.italic,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ),
                      ),
                      pw.Container(), // Empty cells to balance table columns
                      pw.Container(),
                    ],
                  ),
                ]
              : expenses.map((e) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          DateFormat('dd MMM yyyy').format(e.date),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.category),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(formatter.format(e.amount)),
                        ),
                      ),
                    ],
                  );
                }).toList()
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          /// 🔥 TOTAL BOX
          pw.Container(
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              "Total: ${formatter.format(total)}",
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ];
      },
    ),
  );

  return pdf.save();
}