import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/constants/routes.dart';
import 'package:manager/service/bloc/auth_bloc.dart';
import 'package:manager/service/bloc/auth_event.dart';
import 'package:manager/utilities/dialogs/logout_dialog.dart';
import '../service/bloc/auth_bloc.dart';

class MyDrawerList extends StatefulWidget {
  const MyDrawerList({Key? key}) : super(key: key);

  @override
  State<MyDrawerList> createState() => _MyDrawerListState();
}

class _MyDrawerListState extends State<MyDrawerList> {
  @override
  void initState() {
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
                leading: const Icon(Icons.currency_exchange),
                title: Text(
                  'Transact',
                  style: GoogleFonts.lato(fontSize: 20),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(transactionRoute);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(
                  'History',
                  style: GoogleFonts.lato(fontSize: 20),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(historyRoute);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload),
                title: Text(
                  "Upload file",
                  style: GoogleFonts.lato(fontSize: 20),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(uploadFileRoute);
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
}
