import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Widget buildPrintableData({
  required pw.ImageProvider logoImage,
  required String reportTitle,
  required String dateRange,
  required List<Map<String, dynamic>> revenueItems,
  required double totalRevenue,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(25.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo and Header
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              reportTitle,
              style: pw.TextStyle(
                fontSize: 24.0,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Image(
              logoImage,
              width: 50,
              height: 50,
            ),
          ],
        ),
        pw.SizedBox(height: 10.0),
        pw.Divider(),

        // Date Range
        pw.Text(
          "Date Range: $dateRange",
          style: pw.TextStyle(
            fontSize: 16.0,
            color: const PdfColor(0.3, 0.3, 0.3),
          ),
        ),
        pw.SizedBox(height: 20.0),

        // Revenue Details Header
        pw.Container(
          width: double.infinity,
          color: const PdfColor(0.9, 0.9, 0.9),
          padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "Item",
                style: pw.TextStyle(
                  fontSize: 14.0,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                "Amount (PHP)",
                style: pw.TextStyle(
                  fontSize: 14.0,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Revenue Items
        ...revenueItems.map(
          (item) => pw.Container(
            width: double.infinity,
            color: revenueItems.indexOf(item) % 2 == 0
                ? const PdfColor(1.0, 1.0, 1.0)
                : const PdfColor(0.95, 0.95, 0.95),
            padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  item['name'] ?? 'N/A',
                  style: const pw.TextStyle(fontSize: 14.0),
                ),
                pw.Text(
                  "PHP ${item['amount'].toStringAsFixed(2)}",
                  style: const pw.TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
        ),

        pw.SizedBox(height: 10.0),
        pw.Divider(),

        // Total Revenue
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Total Revenue:",
              style: pw.TextStyle(
                fontSize: 16.0,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              "PHP ${totalRevenue.toStringAsFixed(2)}",
              style: pw.TextStyle(
                fontSize: 16.0,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor(0.0, 0.5, 0.0),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20.0),

        // Footer
        pw.Text(
          "This report is generated automatically.",
          style: pw.TextStyle(
            fontSize: 12.0,
            color: const PdfColor(0.5, 0.5, 0.5),
          ),
        ),
        pw.Text(
          "For any discrepancies, please contact support.",
          style: pw.TextStyle(
            fontSize: 12.0,
            color: const PdfColor(0.5, 0.5, 0.5),
          ),
        ),
      ],
    ),
  );
}
