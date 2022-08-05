import 'dart:io';
import 'package:manager/service/pdf/api/pdf_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import '../../../utilities/Utils.dart';
import '../data/pdf_doc.dart';

class PdfDocApi {
  static Future<File> generate(PdfDoc doc) async {
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
    return PdfApi.savePdf(name: 'ManagerDoc$datetime', pdf: pdf);
  }

  static Widget buildHeader(PdfDoc pdfDoc) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pdfDoc.header.heading,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
          Text("User - ${pdfDoc.header.user}"),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static buildTable(PdfDoc pdfDoc) {
    final headers = ['Item Name', 'Cost ', 'Minimum', 'In Stock', 'Total'];

    final data = pdfDoc.allItems.map(
      (item) {
        final total = item.stock * item.cost;

        return [
          item.itemName,
          'Rs ${item.cost}',
          '${item.minQuantity}',
          '${item.stock}',
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
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(PdfDoc pdfDoc) {
    final total = pdfDoc.allItems.map((item) => item.stock * item.cost);
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
                  title: 'Inventory Value',
                  value: Utils.formatPrice(double.parse(total.first.toString())),
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
