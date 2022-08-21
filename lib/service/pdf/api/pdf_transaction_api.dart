import 'dart:io';
import 'package:intl/intl.dart';
import 'package:manager/service/pdf/api/pdf_api.dart';
import 'package:manager/service/pdf/data/pdf_transaction.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import '../../../utilities/Utils.dart';

class PdfTransactionApi {
  static Future<File> generate(PdfTransaction doc) async {
    final pdf = Document();

    pdf.addPage(
      MultiPage(
        build: (context) => [
          buildHeader(doc),
          SizedBox(height: 1 * PdfPageFormat.cm),
          buildTable(doc),
          Divider(),
          buildTotal(doc),
        ],
      ),
    );
    String datetime = DateTime.now().toString();
    return PdfApi.savePdf(name: 'ManagerTransaction_$datetime', pdf: pdf);
  }

  static Widget buildHeader(PdfTransaction pdfDoc) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pdfDoc.header.heading,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text("User - ${pdfDoc.header.user}"),
          Text("Transaction Dates"),
          Text("${pdfDoc.header.startDate} - ${pdfDoc.header.endDate}"),
          SizedBox(
            height: 0.8 * PdfPageFormat.cm,
          ),
          Text(
            "Transaction Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );

  static buildTable(PdfTransaction pdfDoc) {
    final headers = [
      'Item Name',
      'Type ',
      'Quant ',
      'Cost ',
      'Final Stock ',
      'Date   ',
      'Time   ',
      'Total'
    ];

    final data = pdfDoc.allTransactions.map(
      (item) {
        final total = item.quantity * item.itemCost;
        var dt = DateTime.fromMillisecondsSinceEpoch(int.parse(item.dateTime));
        return [
          item.itemName,
          item.action,
          '${item.quantity}',
          'Rs ${item.itemCost}',
          '${item.stock}',
          DateFormat('dd/MM').format(dt),
          DateFormat('HH:mm').format(dt),
          'Rs ${total.toStringAsFixed(2)}'
        ];
      },
    ).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.center,
        3: Alignment.centerRight,
        4: Alignment.center,
        5: Alignment.center,
        6: Alignment.center,
        7: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(PdfTransaction pdfDoc) {
    // final total = pdfDoc.allTransactions.map((item) => item.quantity * item.itemCost);
    var total = 0;
    pdfDoc.allTransactions.map((transaction) {
      if (transaction.action == "Buy") {
        total = total + (transaction.quantity * transaction.itemCost);
      } else {
        total = total - (transaction.quantity * transaction.itemCost);
      }
    });
    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Transaction Value',
                  value: Utils.formatPrice(double.parse(total.toString())),
                  unite: true,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    bool unite = false,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
