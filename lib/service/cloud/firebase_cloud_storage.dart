import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manager/service/cloud/cloud_item.dart';
import 'package:manager/service/cloud/transaction_entry.dart';
import 'cloud_constants.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _shared;

  final items = FirebaseFirestore.instance.collection('items');
  final transactions = FirebaseFirestore.instance.collection('transactions');

  Stream<Iterable<CloudItem>> allItems() {
    final allItems = items
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudItem.fromSnapshot(doc)));
    return allItems;
  }

  Stream<Iterable<CloudItem>> selectedItems() {
    final selectedItems = items
        .where(status, isEqualTo: true)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudItem.fromSnapshot(doc)));
    return selectedItems;
  }

  Future<bool> updateItem({required String id, required CloudItem item}) async {
    try {
      await items.doc(id).update({
        name: item.itemName,
        quantity: item.minQuantity,
        available: item.stock,
        buyingCost: item.cost,
        status: item.isLess,
      });
      return true;
    } catch (e) {
      // throw CouldNotUpdateItemException();
      return false;
    }
  }

  Future<bool> deleteItem({required String id}) async {
    try {
      await items.doc(id).delete();
      return true;
    } catch (e) {
      // throw CouldNotDeleteItemException();
      return false;
    }
  }

  Future<bool> createItem({required CloudItem item}) async {
    try {
      final document = await items.add({
        name: item.itemName,
        quantity: item.minQuantity,
        available: item.stock,
        buyingCost: item.cost,
        status: item.isLess,
      });

      final fetchedItem = await document.get();

      await items.doc(fetchedItem.id).update({
        docId: fetchedItem.id,
        name: item.itemName,
        quantity: item.minQuantity,
        available: item.stock,
        buyingCost: item.cost,
        status: item.isLess,
      });
      return true;
    } catch (e) {
      // throw CouldNotCreateItemException();
      return false;
    }
  }

  Future<dynamic> getItem({required String documentId}) async {
    final doc = await items.doc(documentId).get();
    return CloudItem(
      documentId: doc[docId],
      itemName: doc[name],
      cost: doc[buyingCost],
      minQuantity: doc[quantity],
      stock: doc[available],
      isLess: doc[status],
    );
  }

  Future<bool> incrementStock(CloudItem item, int incrementBy) async {
    final cloudItem = CloudItem(
      documentId: item.documentId,
      itemName: item.itemName,
      cost: item.cost,
      minQuantity: item.minQuantity,
      stock: item.stock + incrementBy,
      isLess: (item.stock < item.minQuantity) ? true : false,
    );

    return updateStock(item.documentId, cloudItem, "increment");
  }

  Future<bool> decrementStock(CloudItem item, int decrementBy) {
    final cloudItem = CloudItem(
      documentId: item.documentId,
      itemName: item.itemName,
      cost: item.cost,
      minQuantity: item.minQuantity,
      stock: item.stock - decrementBy,
      isLess: (item.stock < item.minQuantity) ? true : false,
    );

    return updateStock(item.documentId, cloudItem, "decrement");
  }

  Future<bool> updateStock(String id, CloudItem item, String action) async {
    final bool val = await updateItem(id: id, item: item);
    return val;
  }

  Future<List<dynamic>> downloadItems() async {
    List<dynamic> list = List.empty(growable: true);

    QuerySnapshot query = await items.get();
    final allData = query.docs.map((doc) => doc.data()).toList();
    list = allData;

    debugPrint("list = $list");
    return list;
  }

  Future<bool> createTransaction(
      {required TransactionEntry transaction}) async {
    try {
      final transact = await transactions.add({
        name: transaction.itemName,
        transId: transaction.transactionId,
        finalStock: transaction.stock,
        type: transaction.action,
        transDateTime: transaction.dateTime,
        updateBy: transaction.quantity,
        buyingCost: transaction.itemCost,
      });

      final fetchedTransaction = await transact.get();

      await transactions.doc(fetchedTransaction.id).update({
        transId: fetchedTransaction.id,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> downloadTransactions(DateTimeRange dateRange) async {
    List<dynamic> list = List.empty(growable: true);
    QuerySnapshot query = await transactions
        .where(transDateTime,
            isGreaterThanOrEqualTo: dateRange.start.millisecondsSinceEpoch.toString())
        .where(transDateTime,
            isLessThanOrEqualTo: dateRange.end.millisecondsSinceEpoch.toString())
        .orderBy(transDateTime)
        .get();
    final allTransactions = query.docs.map((doc) => doc.data()).toList();
    list = allTransactions;
    debugPrint("start epoch = ${dateRange.start.millisecondsSinceEpoch}");
    debugPrint("end epoch = ${dateRange.end.millisecondsSinceEpoch}");
    debugPrint("transaction list = $list");
    return list;
  }
}
