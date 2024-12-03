import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_provider/components/custom_padded_button.dart';
import 'package:service_provider/providers/global_providers.dart';
import 'package:service_provider/providers/report_providers.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'printable_data.dart';

class SaveBtnBuilder extends ConsumerWidget {
  const SaveBtnBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return customFloatingActionButton(context,
        buttonText: 'Save as PDF',
        onPressed: () => _printDoc(context, ref),
        key: ValueKey<bool>(true),
        icon: Icon(
          Icons.print,
          color: Colors.white,
        ));
  }

  Future<void> _printDoc(BuildContext context, WidgetRef ref) async {
    print("Save as PDF button clicked"); // Debugging log
    // Get the date range
    final startDate = ref.watch(reportStartDateProvider);
    final endDate = ref.watch(reportEndDateProvider);

    print("Start Date: $startDate, End Date: $endDate");

    // Fetch the revenue data
    final revenueData = await ref
        .read(revenueByDateRangeProvider({
      'startDate': startDate,
      'endDate': endDate,
    }).future)
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $error")),
      );
      return <Map<String, dynamic>>[];
    });
    print("Revenue Data: $revenueData"); // Log the fetched data

    // If no data is available, show a message and return
    if (revenueData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No data available for the selected range.")),
      );
      return;
    }

    // Load the logo image
    final image =
        await imageFromAssetBundle("assets/pamfurred_secondarylogo.png");

    // Generate the PDF
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        final totalRevenue = revenueData.fold<double>(
          0.0,
          (sum, item) => sum + (item['amount'] ?? 0.0),
        );
        return buildPrintableData(
          logoImage: image,
          reportTitle: "Revenue Report",
          dateRange: "$startDate to $endDate",
          revenueItems: revenueData,
          totalRevenue: totalRevenue,
        );
      },
    ));

    // Show the print dialog or save PDF
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }
}
