import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helpers/loading/loading_screen.dart';
import '../service/cloud/cloud_item.dart';
import '../service/pdf/api/pdf_api.dart';
import '../service/pdf/api/pdf_doc_api.dart';
import '../service/pdf/data/header_doc.dart';
import '../service/pdf/data/pdf_doc.dart';
import '../utilities/dialogs/error_dialog.dart';

class MyDrawerHeader extends StatefulWidget {
  const MyDrawerHeader({Key? key}) : super(key: key);

  @override
  State<MyDrawerHeader> createState() => _MyDrawerHeaderState();
}

class _MyDrawerHeaderState extends State<MyDrawerHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[700],
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/account.jpg'),
              ),
            ),
          ),
          Text(
            FirebaseAuth.instance.currentUser!.email.toString(),
            style: GoogleFonts.lato(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }

  void downloadList(Iterable<CloudItem> items) async {
    var list = items.where((element) => element.isLess == true);
    if (list.isEmpty) {
      errorDialog(context, 'First add items');
    } else {
      LoadingScreen().show(context: context, text: 'Downloading pdf');
      final doc = PdfDoc(
        allItems: list,
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
