import 'package:flutter/material.dart';
import 'package:service_provider/components/custom_padded_button.dart';
import 'printable_data.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SaveBtnBuilder extends StatelessWidget {
  const SaveBtnBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return customFloatingActionButton(context,
        buttonText: 'Save as PDF',
        onPressed: () => printDoc(),
        key: ValueKey<bool>(true),
        icon: Icon(
          Icons.print,
          color: Colors.white,
        ));
  }

  Future<void> printDoc() async {
    final image = await imageFromAssetBundle(
      "assets/pamfurred_secondarylogo.png",
    );
    final doc = pw.Document();
    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return buildPrintableData(image);
        }));
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }
}
