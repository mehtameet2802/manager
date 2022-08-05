import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TotalWidget extends StatefulWidget {
  const TotalWidget({Key? key, required this.total}) : super(key: key);

  final int total;

  @override
  State<TotalWidget> createState() => _TotalWidgetState();
}

class _TotalWidgetState extends State<TotalWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(), color: Colors.white),
      child: Center(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
              child: Text(
                'Total Amount  :',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
              child: Text(
                widget.total.toString(),
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
