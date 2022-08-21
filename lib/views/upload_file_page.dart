import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/helpers/loading/loading_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import '../service/cloud/cloud_item.dart';
import '../service/cloud/firebase_cloud_storage.dart';
import '../utilities/dialogs/error_dialog.dart';
import '../utilities/dialogs/informationDialog.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({Key? key}) : super(key: key);

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  late TextEditingController fileNameController;
  String dropdownValue = "None";

  @override
  void initState() {
    fileNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    fileNameController.dispose();
    super.dispose();
  }

  String? filePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Upload File'),
        centerTitle: true,
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
                items: ["None", "csv", "xlsx"].map((String item) {
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: TextField(
              controller: fileNameController,
              enabled: false,
              decoration: const InputDecoration(
                  hintText: "Select a csv or xlsx file",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(13)),
                  )),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (dropdownValue == "None") {
                errorDialog(context, "First select file type");
              } else {
                openFileExplorer(dropdownValue);
              }
            },
            child: Text(
              "Select file",
              style: GoogleFonts.lato(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (!filePath.isEmptyOrNull) {
                if (dropdownValue == "csv") {
                  readCsvFile();
                } else {
                  readXlsxFile();
                }
              } else {
                errorDialog(context, "First select a csv file");
              }
            },
            child: Text(
              "Upload file",
              style: GoogleFonts.lato(),
            ),
          )
        ],
      ),
    );
  }

  void openFileExplorer(String fileType) async {
    final result = await informationDialog(context,
        "Only upload files containing item name,cost,min quantity and stock");
    List<PlatformFile>? paths;
    var mounted = false;
    debugPrint(result.toString());
    if (result) {
      try {
        String? extension = fileType;
        paths = (await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: (extension.isNotEmpty)
              ? extension.replaceAll('', '').split(',')
              : null,
        ))
            ?.files;
        mounted = true;
      } on PlatformException catch (e) {
        debugPrint("Unsupported operation ${e.toString()}");
      } catch (ex) {
        debugPrint(ex.toString());
      }
    }
    if (mounted) {
      fileNameController.text = paths![0].name;
      filePath = paths[0].path;
    }
  }

  void readCsvFile() async {
    LoadingScreen().show(context: context, text: "Adding new items");
    final FirebaseCloudStorage itemService = FirebaseCloudStorage();
    File file = File(filePath!);
    final input = file.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    for (int i = 0; i < fields.length; i++) {
      CloudItem item = CloudItem(
        documentId: '',
        itemName: fields[i][0],
        cost: fields[i][1],
        minQuantity: fields[i][2],
        stock: fields[i][3],
        isLess: (fields[i][3] < fields[i][2]) ? true : false,
      );
      await itemService.createItem(item: item);
    }
    LoadingScreen().hide();
    Navigator.pop(context);
  }

  void readXlsxFile() async {
    LoadingScreen().show(context: context, text: "Adding new items");
    final FirebaseCloudStorage itemService = FirebaseCloudStorage();
    File file = File(filePath!);
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      debugPrint(table);
      for (var row in excel.tables[table]!.rows) {
        debugPrint("$row");
        CloudItem item = CloudItem(
          documentId: '',
          itemName: row[0]?.value as String,
          cost: row[1]?.value as int,
          minQuantity: row[2]?.value as int,
          stock: row[3]?.value as int,
          isLess: (row[3]?.value < row[2]?.value) ? true : false,
        );
        await itemService.createItem(item: item);
      }
    }
    LoadingScreen().hide();
    Navigator.pop(context);
  }
}
