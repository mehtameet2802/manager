import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/helpers/loading/loading_screen.dart';
import 'package:manager/service/cloud/cloud_item.dart';
import 'package:manager/service/cloud/firebase_cloud_storage.dart';
import 'package:velocity_x/velocity_x.dart';

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final formKey = GlobalKey<FormState>();
  late final FirebaseCloudStorage itemService;
  late final TextEditingController _name;
  late final TextEditingController _cost;
  late final TextEditingController _min;
  late final TextEditingController _avl;

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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Add Item'),
        actions: [
          IconButton(
              onPressed: () {
                formKey.currentState?.reset();
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
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Item Name',
                  ),
                  validator: (value) {
                    if (value.isEmptyOrNull) {
                      return 'PLease enter item name';
                    } else {
                      return null;
                    }
                  },
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
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Item Cost',
                  ),
                  validator: (value) {
                    if (value.isEmptyOrNull) {
                      return 'Please enter cost of item';
                    } else {
                      return null;
                    }
                  },
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
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Min Quantity',
                  ),
                  validator: (value) {
                    if (value.isEmptyOrNull) {
                      return 'Please enter minimum quantity';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
                child: TextFormField(
                  controller: _avl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.inventory),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'In Stock',
                  ),
                  validator: (value) {
                    if (value.isEmptyOrNull) {
                      return 'Please enter available inventory';
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  } else {
                    LoadingScreen().show(
                      context: context,
                      text: 'Saving new item',
                    );
                    CloudItem item = CloudItem(
                      documentId: '',
                      itemName: _name.text,
                      cost: int.parse(_cost.text),
                      minQuantity: int.parse(_min.text),
                      stock: int.parse(_avl.text),
                      isLess: (int.parse(_avl.text) < int.parse(_min.text))
                          ? true
                          : false,
                    );
                    addItemToFirebase(item);
                  }
                },
                child: Text(
                  'Save',
                  style: GoogleFonts.lato(fontSize: 17.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addItemToFirebase(CloudItem item) async {
    await itemService.createItem(item: item).then((value) {
      if (value) {
        Fluttertoast.showToast(msg: 'New item saved');
        LoadingScreen().hide();
      } else {
        Fluttertoast.showToast(msg: 'Some error occurred, please try again');
      }
      Navigator.of(context).pop();
    });
  }
}
