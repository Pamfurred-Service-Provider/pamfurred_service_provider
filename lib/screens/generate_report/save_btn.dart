import 'package:flutter/material.dart';
import 'package:service_provider/components/custom_padded_button.dart';
import 'package:service_provider/providers/global_providers.dart';
import 'printable_data.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_provider/providers/report_providers.dart';
import 'package:service_provider/providers/sp_details_provider.dart';

class SaveBtnBuilder extends ConsumerWidget {
  const SaveBtnBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return customFloatingActionButton(
      context,
      buttonText: 'Save as PDF',
      onPressed: () => printDoc(ref),
      key: ValueKey<bool>(true),
      icon: Icon(
        Icons.print,
        color: Colors.white,
      ),
    );
  }

  Future<void> printDoc(WidgetRef ref) async {
    final image = await imageFromAssetBundle(
      "assets/pamfurred_logo.png",
    );

    // Fetch service provider data
    final serviceProviderData = await ref.read(serviceProviderProvider.future);
    // Fetch revenue data
    final revenueData = await _fetchRevenueData(ref);

    final startDate = ref.watch(reportStartDateProvider);
    final endDate = ref.watch(reportEndDateProvider);

    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return buildPrintableData(
            image, serviceProviderData, revenueData, startDate, endDate);
      },
    ));

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

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
