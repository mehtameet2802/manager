import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'cloud_constants.dart';

@immutable
class CloudItem {
  final String documentId;
  final String itemName;
  final int cost;
  final int minQuantity;
  final int stock;
  final bool isLess;

  const CloudItem({
    required this.documentId,
    required this.itemName,
    required this.cost,
    required this.minQuantity,
    required this.stock,
    required this.isLess,
  });

  CloudItem.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.data()[docId] as String,
        itemName = snapshot.data()[name] as String,
        cost = snapshot.data()[buyingCost],
        minQuantity = snapshot.data()[quantity],
        stock = snapshot.data()[available],
        isLess = snapshot.data()[status] as bool;
}
