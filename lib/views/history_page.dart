import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:manager/service/cloud/cloud_constants.dart';
import 'package:manager/service/cloud/firebase_cloud_storage.dart';
import 'package:manager/service/cloud/transaction_entry.dart';
import 'package:manager/service/pdf/data/header_transaction.dart';
import 'package:manager/service/pdf/data/pdf_transaction.dart';
import 'package:manager/utilities/dialogs/error_dialog.dart';
import '../helpers/loading/loading_screen.dart';
import '../service/pdf/api/pdf_api.dart';
import '../service/pdf/api/pdf_transaction_api.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final FirebaseCloudStorage _itemServices;
  late final TextEditingController _startDate;
  late final TextEditingController _endDate;
  DateTimeRange? newDateRange;

  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  @override
  void initState() {
    _itemServices = FirebaseCloudStorage();
    _startDate = TextEditingController();
    _endDate = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _startDate.dispose();
    _endDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text("Transaction History"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Text(
                "Select Dates",
                style: GoogleFonts.lato(fontSize: 25.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0),
            child: TextField(
              enabled: false,
              style: GoogleFonts.lato(fontSize: 16.0),
              decoration: InputDecoration(
                hintText: "Start Date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13.0),
                ),
              ),
              controller: _startDate,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: TextField(
              enabled: false,
              style: GoogleFonts.lato(fontSize: 16.0),
              decoration: InputDecoration(
                hintText: "End Date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13.0),
                ),
              ),
              controller: _endDate,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: ElevatedButton(
              onPressed: () {
                pickDate();
              },
              child: Text(
                "Select Dates",
                style: GoogleFonts.lato(fontSize: 17.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: ElevatedButton(
              onPressed: () {
                if (_startDate.text.isEmpty || _endDate.text.isEmpty) {
                  errorDialog(context, "Please select start and end date");
                } else {
                  printTransactions(dateRange);
                }
              },
              child: Text(
                "Download",
                style: GoogleFonts.lato(fontSize: 17.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future pickDate() async {
    newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (newDateRange == null) return;
    setState(() {
      _startDate.text = DateFormat('dd/MM/yyyy').format(newDateRange!.start);
      _endDate.text = DateFormat('dd/MM/yyyy').format(newDateRange!.end);
    });
  }

  void printTransactions(DateTimeRange dateRange) async {
    List<dynamic> transactions =
        (await _itemServices.downloadTransactions(newDateRange!));
    List<TransactionEntry> allTransactions = List.empty(growable: true);
    if (transactions.isNotEmpty) {
      for (var i in transactions) {
        allTransactions.add(
          TransactionEntry(
            dateTime: i[transDateTime],
            itemName: i[name],
            stock: i[finalStock],
            itemCost: i[buyingCost],
            action: i[type],
            quantity: i[updateBy],
            transactionId: i[transId],
          ),
        );
      }
      LoadingScreen().show(context: context, text: 'Downloading pdf');
      final doc = PdfTransaction(
        allTransactions: allTransactions,
        header: HeaderTransaction(
          user: FirebaseAuth.instance.currentUser!.email.toString(),
          heading: 'Transactions History',
          startDate: _startDate.text,
          endDate: _endDate.text,
        ),
      );
      final pdf = await PdfTransactionApi.generate(doc);
      LoadingScreen().hide();
      PdfApi.openFile(pdf);
    } else {
      errorDialog(context, "No transaction in given date");
    }
  }
}
