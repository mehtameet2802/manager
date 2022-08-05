import 'package:manager/service/pdf/data/header_doc.dart';
import '../../cloud/cloud_item.dart';

class PdfDoc {
  final HeaderDoc header;
  final Iterable<CloudItem> allItems;

  const PdfDoc({
    required this.header,
    required this.allItems,
  });
}
