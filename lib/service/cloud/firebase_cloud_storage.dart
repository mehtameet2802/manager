import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manager/service/cloud/cloud_item.dart';
import 'cloud_constants.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _shared;

  final items = FirebaseFirestore.instance.collection('items');

  Stream<Iterable<CloudItem>> allItems() {
    final allItems = items
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudItem.fromSnapshot(doc)));
    return allItems;
  }

  Future<Iterable<CloudItem>> downloadItems() async {
    List<CloudItem> list = List.empty(growable: true);
    items.snapshots().map((event) =>
        event.docs.map((doc) => list.add(CloudItem.fromSnapshot(doc))));

    // await items.get().then((value) =>
    //     value.docs.map((doc) => list.add(CloudItem.fromSnapshot(doc))));
    return list;
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

  Future<CloudItem> getItem({required String documentId}) async {
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

  Future<bool> incrementStock(CloudItem item) async {
    final cloudItem = CloudItem(
      documentId: item.documentId,
      itemName: item.itemName,
      cost: item.cost,
      minQuantity: item.minQuantity,
      stock: item.stock + 1,
      isLess: (item.stock < item.minQuantity) ? true : false,
    );

    return updateStock(item.documentId, cloudItem, "increment");
  }

  Future<bool> decrementStock(CloudItem item) {
    final cloudItem = CloudItem(
      documentId: item.documentId,
      itemName: item.itemName,
      cost: item.cost,
      minQuantity: item.minQuantity,
      stock: item.stock - 1,
      isLess: (item.stock < item.minQuantity) ? true : false,
    );

    return updateStock(item.documentId, cloudItem, "decrement");
  }

  Future<bool> updateStock(String id, CloudItem item, String action) async {
    final bool val = await updateItem(id: id, item: item);
    return val;
  }
}
