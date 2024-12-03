import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';

class InvoiceBuilder extends StatelessWidget {
  const InvoiceBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header(),
        const SizedBox(height: tertiarySizedBox),
        tableHeader(),
        for (var i = 0; i < 3; i++) buildTableData(i),
        buildTotal(),
      ],
    );
  }

  Widget header() => const Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            Icons.file_open,
            color: Colors.indigo,
            size: 35.00,
          ),
          const SizedBox(
            width: tertiarySizedBox,
          ),
          Text(
            "Invoice",
            style: TextStyle(fontSize: 23.00, fontWeight: FontWeight.bold),
          )
        ],
      );

  Widget tableHeader() => Container(
        color: const Color.fromARGB(255, 189, 255, 191),
        width: double.infinity,
        height: 36.00,
        child: const Center(
          child: Text(
            "Approvals",
            style: TextStyle(
                color: Color.fromARGB(255, 0, 107, 4),
                fontSize: 20.00,
                fontWeight: FontWeight.bold),
          ),
        ),
      );

  Widget buildTableData(int i) => Container(
        color: i % 2 != 0
            ? const Color.fromARGB(255, 236, 236, 236)
            : const Color.fromARGB(255, 255, 251, 251),
        width: double.infinity,
        height: 36.00,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              i == 2
                  ? const Text(
                      "Tax",
                      style: TextStyle(
                          fontSize: 18.00, fontWeight: FontWeight.bold),
                    )
                  : Text(
                      "Item ${i + 1}",
                      style: const TextStyle(
                          fontSize: 18.00, fontWeight: FontWeight.bold),
                    ),
              i == 2
                  ? const Text(
                      "\$ 2.50",
                      style: TextStyle(
                          fontSize: 18.00, fontWeight: FontWeight.normal),
                    )
                  : Text(
                      "\$ ${(i + 1) * 7}.00",
                      style: const TextStyle(
                          fontSize: 18.00, fontWeight: FontWeight.normal),
                    ),
            ],
          ),
        ),
      );

  Widget buildTotal() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Container(
          color: const Color.fromARGB(255, 255, 251, 251),
          width: double.infinity,
          height: 36.00,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "\$ 23.50",
                style: TextStyle(
                  fontSize: 22.00,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 107, 4),
                ),
              ),
            ],
          ),
        ),
      );
}
