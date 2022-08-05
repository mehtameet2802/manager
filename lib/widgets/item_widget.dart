import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemWidget extends StatefulWidget {
  const ItemWidget({Key? key}) : super(key: key);

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  String? itemName;
  int? quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      // child: Container(
      child: SizedBox(
        height: 65,
        child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: [
              SizedBox(
                width: 225,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
                  child: Text(
                    'Item Name',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(fontSize: 18),
                  ),
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
              Text(
                quantity.toString(),
                style: const TextStyle(fontSize: 18),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.add))
            ],
          ),
        ),
      ),
    );
  }
}
