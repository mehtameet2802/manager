import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helpers/loading/loading_screen.dart';
import '../service/cloud/cloud_item.dart';
import '../service/cloud/firebase_cloud_storage.dart';
import '../service/pdf/api/pdf_api.dart';
import '../service/pdf/api/pdf_doc_api.dart';
import '../service/pdf/data/header_doc.dart';
import '../service/pdf/data/pdf_doc.dart';
import '../utilities/dialogs/error_dialog.dart';
import '../widgets/items_list_widget.dart';

class InventoryStatusPage extends StatefulWidget {
  const InventoryStatusPage({Key? key}) : super(key: key);

  @override
  State<InventoryStatusPage> createState() => _InventoryStatusPageState();
}

class _InventoryStatusPageState extends State<InventoryStatusPage> {
  late final FirebaseCloudStorage _itemService;
  Iterable<CloudItem> selectedItems = List.empty();
  Iterable<CloudItem> downloadItems = List.empty();
  bool isNull = true;

  @override
  void initState() {
    _itemService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text("Low Stock"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                downloadItems = (isNull) ? List.empty() : selectedItems;
              });
              downloadList(downloadItems);
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _itemService.selectedItems(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                isNull = false;
                selectedItems = snapshot.data as Iterable<CloudItem>;
                return ItemsListWidget(
                  items: selectedItems,
                  onTap: (item) {},
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }

  void downloadList(Iterable<CloudItem> items) async {
    if (items.isEmpty) {
      errorDialog(context, 'First add items');
    } else {
      LoadingScreen().show(context: context, text: 'Downloading pdf');
      final doc = PdfDoc(
        allItems: items,
        header: HeaderDoc(
          user: FirebaseAuth.instance.currentUser!.email.toString(),
          heading: 'Required Items',
        ),
      );
      final pdf = await PdfDocApi.generate(doc);
      LoadingScreen().hide();
      PdfApi.openFile(pdf);
    }
  }
}
