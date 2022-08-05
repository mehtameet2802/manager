import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/cloud/cloud_item.dart';
import '../service/cloud/firebase_cloud_storage.dart';
import '../utilities/dialogs/error_dialog.dart';

typedef ItemCallback = void Function(CloudItem item);

class ItemsListWidget extends StatefulWidget {
  const ItemsListWidget({Key? key, required this.items, required this.onTap})
      : super(key: key);

  final Iterable<CloudItem> items;
  final ItemCallback onTap;

  @override
  State<ItemsListWidget> createState() => _ItemsListWidgetState();
}

class _ItemsListWidgetState extends State<ItemsListWidget> {
  late final FirebaseCloudStorage itemService;
  var st = 0;

  @override
  void initState() {
    itemService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items.elementAt(index);
        st = item.stock;
        return GestureDetector(
          onTap: () {
            widget.onTap(item);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            // child: Container(
            child: SizedBox(
              height: 65,
              child: Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 5, 0),
                        child: Text(
                          item.itemName,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(fontSize: 18),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          decrementStock(item);
                        },
                        icon: const Icon(Icons.remove)),
                    Text(
                      st.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          color: (item.stock < item.minQuantity)
                              ? Colors.red
                              : Colors.black),
                    ),
                    IconButton(
                        onPressed: () {
                          incrementStock(item);
                        },
                        icon: const Icon(Icons.add))
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void incrementStock(CloudItem item) {
    setState(() {
      st += 1;
    });

    final cloudItem = CloudItem(
      documentId: item.documentId,
      itemName: item.itemName,
      cost: item.cost,
      minQuantity: item.minQuantity,
      stock: item.stock + 1,
      isLess: (item.stock < item.minQuantity) ? true : false,
    );

    updateItem(item.documentId, cloudItem, "increment");
  }

  void decrementStock(CloudItem item) {
    if (st > 0) {
      setState(() {
        st -= 1;
      });

      final cloudItem = CloudItem(
        documentId: item.documentId,
        itemName: item.itemName,
        cost: item.cost,
        minQuantity: item.minQuantity,
        stock: item.stock - 1,
        isLess: (item.stock < item.minQuantity) ? true : false,
      );

      updateItem(item.documentId, cloudItem, "decrement");
    }
  }

  void updateItem(String id, CloudItem item, String action) async {
    await itemService.updateItem(id: id, item: item).then(
      (value) {
        if (value) {
          debugPrint("action : $action of item done");
        } else {
          errorDialog(context, 'Could not $action item stock');
        }
      },
    );
  }
}
