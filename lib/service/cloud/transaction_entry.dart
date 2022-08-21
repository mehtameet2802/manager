import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloud_constants.dart';

class TransactionEntry {
  final String transactionId;
  final String itemName;
  final String action;
  final int quantity;
  final int itemCost;
  final int stock;
  final String dateTime;

  const TransactionEntry(
      {required this.transactionId,
      required this.itemName,
      required this.action,
      required this.quantity,
      required this.itemCost,
      required this.stock,
      required this.dateTime});

  TransactionEntry.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : transactionId = snapshot.data()[transId] as String,
        itemName = snapshot.data()[name] as String,
        action = snapshot.data()[type] as String,
        quantity = snapshot.data()[updateBy],
        itemCost = snapshot.data()[buyingCost],
        stock = snapshot.data()[finalStock],
        dateTime = snapshot.data()[transDateTime] as String;
}
