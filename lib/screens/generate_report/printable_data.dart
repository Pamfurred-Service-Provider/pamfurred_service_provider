import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

buildPrintableData(image, Map<String, dynamic> serviceProviderData,
        List<dynamic> revenueData, String startDate, String endDate) =>
    pw.Padding(
      padding: const pw.EdgeInsets.all(25.00),
      child: pw.Column(children: [
        // Establishment name only (no image in the header)
        pw.Text(
          serviceProviderData['establishment_name'],
          style: pw.TextStyle(fontSize: 25.00, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10.00),
        pw.Divider(),
        pw.Column(
          children: [
            // Container for Revenue Report title with date range
            pw.Container(
              color: PdfColor(0.62745, 0.24314, 0.02353, 1.0),
              width: double.infinity,
              height: 36.00,
              child: pw.Center(
                child: pw.Text(
                  "Revenue Report",
                  style: pw.TextStyle(
                      color: PdfColor(1.0, 1.0, 1.0),
                      fontSize: 20.00,
                      fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.SizedBox(height: 5.00),
            // Date range under the Revenue Report
            pw.Text(
              "From: $startDate to $endDate",
              style: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 16.00,
                  fontWeight: pw.FontWeight.normal),
            ),
            pw.SizedBox(height: 10.00),
            // Table for revenue data with column names as headers
            pw.Table(
              border: pw.TableBorder.all(width: 1.0),
              children: [
                pw.TableRow(
                  children: [
                    _buildTableHeader('Appointment ID'),
                    _buildTableHeader('Appointment Date'),
                    _buildTableHeader('Pet Owner'),
                    _buildTableHeader('Total Amount'),
                  ],
                ),
                for (var i = 0; i < revenueData.length; i++)
                  pw.TableRow(
                    children: [
                      _buildTableCell(
                          revenueData[i]['appointment_id'].toString()),
                      _buildTableCell(revenueData[i]['appointment_date']),
                      _buildTableCell(revenueData[i]['pet_owner_name']),
                      _buildTableCell('PHP${revenueData[i]['total_amount']}'),
                    ],
                  ),
              ],
            ),
            pw.SizedBox(height: 10.00),
            // Total amount row
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 25.0),
              child: pw.Container(
                width: double.infinity,
                height: 36.00,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      "Total: PHP${revenueData.fold(0, (num sum, item) => sum + item['total_amount'])}",
                      style: pw.TextStyle(
                        fontSize: 22.00,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor(0.62745, 0.24314, 0.02353, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 15.00),
          ],
        ),
        // Image as the footer
        pw.SizedBox(height: 20.00),
        pw.Align(
          alignment: pw.Alignment.bottomCenter,
          child: pw.Image(
            image,
            height: 30,
          ),
        ),
      ]),
    );

// Helper function to build table header
pw.Widget _buildTableHeader(String title) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(5.0),
    child: pw.Text(
      title,
      style: pw.TextStyle(
          fontSize: 14.00,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black),
    ),
  );
}

// Helper function to build table cell
pw.Widget _buildTableCell(String content) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(5.0),
    child: pw.Text(
      content,
      style: pw.TextStyle(fontSize: 12.00),
    ),
  );
}
