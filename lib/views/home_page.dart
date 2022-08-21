import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:manager/constants/routes.dart';
import 'package:manager/service/cloud/firebase_cloud_storage.dart';
import 'package:manager/widgets/drawer_list_widget.dart';
import 'package:manager/widgets/items_list_widget.dart';
import 'package:manager/widgets/total_widget.dart';
import '../helpers/loading/loading_screen.dart';
import '../service/cloud/cloud_item.dart';
import '../service/pdf/api/pdf_api.dart';
import '../service/pdf/api/pdf_doc_api.dart';
import '../service/pdf/data/header_doc.dart';
import '../service/pdf/data/pdf_doc.dart';
import '../utilities/dialogs/error_dialog.dart';
import '../widgets/drawer_header_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FirebaseCloudStorage _itemService;
  late final TextEditingController _search;
  Iterable<CloudItem>? allItems;
  Iterable<CloudItem> searchItems = List.empty();
  Iterable<CloudItem> downloadItems = List.empty();
  int sum = 0;
  bool isNull = true;

  @override
  void initState() {
    _itemService = FirebaseCloudStorage();
    _search = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text("All Items"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(addItemRoute);
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                downloadItems = (isNull) ? List.empty() : allItems!;
              });
              downloadList(downloadItems);
            },
            icon: const Icon(Icons.download),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 15),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.all(Radius.circular(30.0))
              ),
              height: 40,
              width: double.infinity,
              child: TextField(
                onChanged: (value) => searchItem(value),
                controller: _search,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search here',
                    prefixIcon: Icon(Icons.search)),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: const [
            MyDrawerHeader(),
            MyDrawerList(),
          ],
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: _itemService.allItems(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    isNull = false;
                    allItems = snapshot.data as Iterable<CloudItem>;
                    return ItemsListWidget(
                      items: (searchItems.length < allItems!.length &&
                                  _search.text.isNotEmpty ||
                              _search.text.isNotEmpty && searchItems.isEmpty)
                          ? searchItems
                          : allItems!,
                      onTap: (item) {
                        Navigator.of(context).pushNamed(
                          updateItemRoute,
                          arguments: item,
                        );
                      },
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                calculateTotal(allItems!);
              },
              child: SizedBox(
                height: 50,
                child: TotalWidget(total: sum),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void calculateTotal(Iterable<CloudItem> cloudItem) {
    var total = 0;
    for (var item in cloudItem) {
      total = total + (item.stock * item.cost);
    }
    setState(() {
      sum = total;
    });
  }

  void searchItem(String text) {
    if (text.isEmpty) {
      setState(() {
        searchItems = List.empty();
        allItems = allItems!;
      });
    } else {
      setState(() {
        searchItems = allItems!.where((element) =>
            element.itemName.toLowerCase().contains(text.toLowerCase()));
      });
    }
  }

  void downloadList(Iterable<CloudItem> items) async {
    // loadData(false);
    debugPrint("items length ${items.length}");
    if (items.isEmpty) {
      errorDialog(context, 'First add items');
    } else {
      LoadingScreen().show(context: context, text: 'Downloading pdf');
      final doc = PdfDoc(
        allItems: items,
        header: HeaderDoc(
          user: FirebaseAuth.instance.currentUser!.email.toString(),
          heading: 'All Items',
        ),
      );
      final pdf = await PdfDocApi.generate(doc);
      LoadingScreen().hide();
      PdfApi.openFile(pdf);
    }
  }
}
