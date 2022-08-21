import 'package:manager/service/cloud/transaction_entry.dart';
import 'package:manager/service/pdf/data/header_doc.dart';
import 'package:manager/service/pdf/data/header_transaction.dart';
import '../../cloud/cloud_item.dart';

class PdfTransaction {
  final HeaderTransaction header;
  final List<TransactionEntry> allTransactions;

  const PdfTransaction({
    required this.header,
    required this.allTransactions,
  });
}
