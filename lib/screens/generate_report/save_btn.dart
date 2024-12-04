import 'package:flutter/material.dart';
import 'package:service_provider/components/custom_padded_button.dart';
import 'package:service_provider/providers/global_providers.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_provider/providers/report_providers.dart';
import 'package:service_provider/providers/sp_details_provider.dart';

class SaveBtnBuilder extends ConsumerWidget {
  const SaveBtnBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return customFloatingActionButton(
      context,
      buttonText: 'Generate PDF',
      onPressed: () async {
        await _printDoc(ref, context);
      },
      key: ValueKey<bool>(true),
      icon: Icon(
        Icons.print,
        color: Colors.white,
      ),
    );
  }

  // This function is responsible for creating the PDF document and printing it
  Future<void> _printDoc(WidgetRef ref, BuildContext context) async {
    // Asynchronously load the logo image
    final image = await imageFromAssetBundle(
      "assets/pamfurred_logo.png",
    );

    // Fetch service provider data
    final serviceProviderData = await ref.read(serviceProviderProvider.future);
    // Fetch revenue data
    final revenueData = await _fetchRevenueData(ref);

    final startDate = ref.watch(reportStartDateProvider);
    final endDate = ref.watch(reportEndDateProvider);

    // Create a list of widgets to be added to the PDF document
    List<p.Widget> widgets = [];

    // Profile image widget (image from asset)
    final profileImage = p.Image(
      image,
      height: 40,
    );

    // Add the profile image container to the widgets list
    widgets.add(p.Center(
      child: profileImage,
    ));

    // Add the establishment name
    widgets.add(p.SizedBox(height: 20));
    widgets.add(p.Text(
      serviceProviderData['establishment_name'],
      style: p.TextStyle(fontSize: 25.00, fontWeight: p.FontWeight.bold),
    ));
    widgets.add(p.SizedBox(height: 10));

    // Revenue Report title and date range
    widgets.add(p.Container(
      color: PdfColor(0.62745, 0.24314, 0.02353, 1.0),
      width: double.infinity,
      height: 36.00,
      child: p.Center(
        child: p.Text(
          "Revenue Report",
          style: p.TextStyle(
            color: PdfColor(1.0, 1.0, 1.0),
            fontSize: 20.00,
            fontWeight: p.FontWeight.bold,
          ),
        ),
      ),
    ));

    widgets.add(p.SizedBox(height: 5));
    widgets.add(p.Text(
      "From: $startDate to $endDate",
      style: p.TextStyle(
          color: PdfColors.black,
          fontSize: 16.00,
          fontWeight: p.FontWeight.bold),
    ));

    widgets.add(p.SizedBox(height: 10));

    // Add a single table with all revenue data
    widgets.add(
      p.Table(
        border: p.TableBorder.all(width: 1.0),
        children: [
          p.TableRow(
            children: [
              _buildTableCell('Appointment ID', isTitle: true),
              _buildTableCell('Appointment Date', isTitle: true),
              _buildTableCell('Pet Owner', isTitle: true),
              _buildTableCell('Total Amount', isTitle: true),
            ],
          ),
          // Loop through the revenue data and add rows
          for (var i = 0; i < revenueData.length; i++)
            p.TableRow(
              children: [
                _buildTableCell(revenueData[i]['appointment_id'].toString(),
                    isTitle: false),
                _buildTableCell(revenueData[i]['appointment_date'],
                    isTitle: false),
                _buildTableCell(revenueData[i]['pet_owner_name'],
                    isTitle: false),
                _buildTableCell('PHP${revenueData[i]['total_amount']}',
                    isTitle: false),
              ],
            ),
        ],
      ),
    );

    // Total amount row
    widgets.add(p.Align(
      alignment: p.Alignment.centerRight,
      child: p.Text(
        "Total: PHP${revenueData.fold(0, (num sum, item) => sum + item['total_amount'])}",
        style: p.TextStyle(
          fontSize: 22.00,
          fontWeight: p.FontWeight.bold,
          color: PdfColor(0.62745, 0.24314, 0.02353, 1.0),
        ),
      ),
    ));

    widgets.add(p.SizedBox(height: 15.00));

    // Generate the PDF document
    final pdf = p.Document();
    pdf.addPage(
      p.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (p.Context context) => widgets, // Pass the list of widgets
      ),
    );

    // Layout and print the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Helper function to build a table cell
  p.Widget _buildTableCell(String content, {required bool isTitle}) {
    return p.Padding(
      padding: const p.EdgeInsets.all(5.0),
      child: p.Text(
        content,
        style: p.TextStyle(
            fontSize: 12.00,
            fontWeight: isTitle ? p.FontWeight.bold : p.FontWeight.normal),
      ),
    );
  }

  // Fetch revenue data from the provider
  Future<List<dynamic>> _fetchRevenueData(WidgetRef ref) async {
    final userId = ref.read(userIdProvider);
    final startDate = ref.read(reportStartDateProvider);
    final endDate = ref.read(reportEndDateProvider);

    return await ref.read(revenueByDateRangeProvider({
      'spId': userId,
      'startDate': startDate,
      'endDate': endDate,
    }).future);
  }
}
