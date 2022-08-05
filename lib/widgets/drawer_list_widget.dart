import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/constants/routes.dart';
import 'package:manager/service/bloc/auth_bloc.dart';
import 'package:manager/service/bloc/auth_event.dart';
import 'package:manager/utilities/dialogs/logout_dialog.dart';
import '../service/bloc/auth_bloc.dart';
import '../service/cloud/firebase_cloud_storage.dart';

class MyDrawerList extends StatefulWidget {
  const MyDrawerList({Key? key})
      : super(key: key);

  @override
  State<MyDrawerList> createState() => _MyDrawerListState();
}

class _MyDrawerListState extends State<MyDrawerList> {
  late final FirebaseCloudStorage itemService;

  @override
  void initState() {
    // itemService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        children: [
          Material(
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    menuItem(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget menuItem(BuildContext context) {
  return Material(
    child: InkWell(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.inventory_outlined),
              title: Text(
                'Inventory Status',
                style: GoogleFonts.lato(fontSize: 20),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(inventoryRoute);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(
                'Logout',
                style: GoogleFonts.lato(fontSize: 20),
              ),
              onTap: () async {
                final shouldLogout = await logoutDialog(context);
                Navigator.of(context).pop();
                if (shouldLogout) {
                  context.read<AuthBloc>().add(const AuthEventLogout());
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

// ListTile(
//   leading: const Icon(Icons.download),
//   title: Text(
//     'Download All Items',
//     style: GoogleFonts.lato(
//       fontSize: 17,
//     ),
//   ),
//   onTap: () async {
//     Navigator.of(context).pop();
//     // loadData(false);
//     debugPrint("items length ${widget.items.length}");
//     if (widget.items.isEmpty) {
//       errorDialog(context, 'First add items');
//     } else {
//       LoadingScreen()
//           .show(context: context, text: 'Downloading pdf');
//       final doc = PdfDoc(
//         allItems: widget.items,
//         header: HeaderDoc(
//           user: FirebaseAuth.instance.currentUser!.email
//               .toString(),
//           heading: 'All Items',
//         ),
//       );
//       final pdf = await PdfDocApi.generate(doc);
//       LoadingScreen().hide();
//       PdfApi.openFile(pdf);
//     }
//   },
// ),
// ListTile(
//   leading: const Icon(Icons.inventory),
//   title: Text(
//     'Download Low Items',
//     style: GoogleFonts.lato(
//       fontSize: 17,
//     ),
//   ),
//   onTap: () async {
//     // loadData(true);
//     Navigator.of(context).pop();
//     var list =
//         widget.items.where((element) => element.isLess == true);
//     if (list.isEmpty) {
//       errorDialog(context, 'First add items');
//     } else {
//       LoadingScreen()
//           .show(context: context, text: 'Downloading pdf');
//       final doc = PdfDoc(
//         allItems: list,
//         header: HeaderDoc(
//           user: FirebaseAuth.instance.currentUser!.email
//               .toString(),
//           heading: 'Required Items',
//         ),
//       );
//       final pdf = await PdfDocApi.generate(doc);
//       LoadingScreen().hide();
//       PdfApi.openFile(pdf);
//     }
//   },
// ),
