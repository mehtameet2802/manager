import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/utilities/dialogs/delete_dialog.dart';
import 'package:manager/utilities/dialogs/error_dialog.dart';
import 'package:manager/utilities/generics/arguments.dart';
import '../helpers/loading/loading_screen.dart';
import '../service/cloud/cloud_item.dart';
import '../service/cloud/firebase_cloud_storage.dart';

class UpdateItem extends StatefulWidget {
  const UpdateItem({Key? key}) : super(key: key);

  @override
  State<UpdateItem> createState() => _UpdateItemState();
}

class _UpdateItemState extends State<UpdateItem> {
  final formKey = GlobalKey<FormState>();
  CloudItem? _item;
  late final FirebaseCloudStorage itemService;
  late final TextEditingController _name;
  late final TextEditingController _cost;
  late final TextEditingController _min;
  late final TextEditingController _avl;

  void loadItem() async {
    final widgetItem = context.getArgument<CloudItem>();
    if (widgetItem != null) {
      _item = widgetItem;
      _name.text = widgetItem.itemName;
      _avl.text = widgetItem.stock.toString();
      _cost.text = widgetItem.cost.toString();
      _min.text = widgetItem.minQuantity.toString();
    }
  }

  @override
  void initState() {
    itemService = FirebaseCloudStorage();
    _name = TextEditingController();
    _cost = TextEditingController();
    _min = TextEditingController();
    _avl = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _cost.dispose();
    _min.dispose();
    _avl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    loadItem();
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Add Item'),
        actions: [
          IconButton(
              onPressed: () {
                deleteItem(_item!.documentId);
              },
              icon: const Icon(Icons.delete)),
          IconButton(
              onPressed: () {
                formKey.currentState?.reset();
                _name.text = "";
                _min.text = "";
                _cost.text = "";
                _avl.text = "";
              },
              icon: const Icon(Icons.clear))
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.edit),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    hintText: 'Item Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: TextFormField(
                  controller: _cost,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    hintText: 'Item Cost',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: TextFormField(
                  controller: _min,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.production_quantity_limits),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    hintText: 'Min Quantity',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: TextFormField(
                  controller: _avl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.inventory),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    hintText: 'In Stock',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    } else if (_name.text == "") {
                      Fluttertoast.showToast(msg: "Could not update the item");
                      Navigator.of(context).pop();
                    } else {
                      LoadingScreen().show(
                        context: context,
                        text: 'Updating the item',
                      );
                      CloudItem item = CloudItem(
                        documentId: _item!.documentId,
                        itemName: _name.text,
                        cost: int.parse(_cost.text.toString()),
                        minQuantity: int.parse(_min.text.toString()),
                        stock: int.parse(_avl.text.toString()),
                        isLess: (int.parse(_avl.text) <
                                int.parse(_min.text))
                            ? true
                            : false,
                      );
                      updateItem(_item!.documentId, item);
                    }
                  },
                  child: Text(
                    'Update',
                    style: GoogleFonts.lato(fontSize: 17.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteItem(String id) async {
    final result = await deleteDialog(context);
    if (result) {
      await itemService.deleteItem(id: id).then(
        (value) {
          if (value) {
            Navigator.of(context).pop();
          } else {
            errorDialog(context, 'Could not delete item');
          }
        },
      );
    }
  }

  void updateItem(String id, CloudItem item) async {
    await itemService.updateItem(id: id, item: item).then(
      (value) {
        if (value) {
          _item = item;
          LoadingScreen().hide();
          Navigator.of(context).pop();
        } else {
          errorDialog(context, 'Could not update item');
        }
      },
    );
  }
}
