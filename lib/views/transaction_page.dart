import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/service/cloud/cloud_item.dart';
import 'package:manager/service/cloud/transaction_entry.dart';
import 'package:manager/utilities/dialogs/error_dialog.dart';
import '../helpers/loading/loading_screen.dart';
import '../service/cloud/firebase_cloud_storage.dart';
import 'package:manager/service/cloud/cloud_constants.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({
    Key? key,
  }) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late final FirebaseCloudStorage _itemService;
  late TextEditingController _updateBy;
  List<String> allItems = List.empty(growable: true);
  late List<dynamic> items;
  String dropdownValue = "None";
  String actionValue = "None";

  @override
  void initState() {
    _itemService = FirebaseCloudStorage();
    _updateBy = TextEditingController();
    getItems();
    super.initState();
  }

  @override
  void dispose() {
    _updateBy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Transaction'),
      ),
      body: Column(
        children: [
          Container(
            width: 500,
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                value: dropdownValue,
                items: allItems.map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
              ),
            ),
          ),
          Container(
            width: 500,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                value: actionValue,
                items: ["None", "Buy", "Sell"].map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    actionValue = newValue!;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: TextField(
              controller: _updateBy,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 0.0),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: "Quantity"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: ElevatedButton(
              onPressed: () {
                if (dropdownValue == "None" || actionValue == "None") {
                  if (dropdownValue == "None") {
                    errorDialog(context, "Please select the item first");
                  } else {
                    errorDialog(context, "Please select the action first");
                  }
                } else {
                  String id = "";
                  for (var i in items) {
                    if (i[name] == dropdownValue) {
                      id = i[docId];
                    }
                  }
                  doTransaction(id);
                  LoadingScreen().show(context: context, text: "Processing");
                }
              },
              child: Text(
                'Done',
                style: GoogleFonts.lato(fontSize: 17.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getItems() async {
    items = await _itemService.downloadItems();
    List<String> list = List.empty(growable: true);
    list.add("None");
    for (var i in items) {
      list.add(i[name]);
    }
    setState(() {
      allItems = list;
    });
    debugPrint("all items = $allItems");
  }

  void doTransaction(String id) async {
    bool value = false;
    int finalStock = 0;
    CloudItem item = (await _itemService.getItem(documentId: id)) as CloudItem;
    if (actionValue == "Buy") {
      value = await _itemService.incrementStock(
        item,
        int.parse(_updateBy.text),
      );
      finalStock = item.stock + int.parse(_updateBy.text);
    } else {
      value = await _itemService.decrementStock(
        item,
        int.parse(_updateBy.text),
      );
      finalStock = item.stock - int.parse(_updateBy.text);
    }

    createTransaction(item, finalStock);

    LoadingScreen().hide();
    if (value) {
      Navigator.of(context).pop();
    } else {
      errorDialog(context, 'Could not do the transaction');
    }
  }

  void createTransaction(CloudItem item, int finalStock) async {
    String dateStr = DateTime.now().millisecondsSinceEpoch.toString();

    TransactionEntry transaction = TransactionEntry(
      transactionId: '',
      itemName: item.itemName,
      action: actionValue,
      quantity: int.parse(_updateBy.text),
      itemCost: item.cost,
      stock: finalStock,
      dateTime: dateStr,
    );
    await _itemService.createTransaction(transaction: transaction);
  }
}
