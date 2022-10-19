import 'package:flutter/material.dart';
import 'package:riquenanucleus/functions.dart';
import 'package:riquenanucleus/styles/colors.dart';
import 'package:riquenanucleus/pages/contact/createContact.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:riquenanucleus/pages/contact/listContact.dart";

class LoadScreen extends StatefulWidget {
  const LoadScreen({Key? key}) : super(key: key);

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  @override
  void initState() {
    initDb();
    super.initState();
  }

// Start the Local Database and make the necessary checks
  initDb() async {
    var data = await getLocalDb();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (data != null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const ListContact()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const CreateContact()));
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
        child: Scaffold(
            body: Stack(children: [
      Container(
        height: media.height * 1,
        width: media.width * 1,
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Minha Agenda',
                style: GoogleFonts.poppins(
                    fontSize: media.width * 0.08,
                    fontWeight: FontWeight.w600,
                    color: titleColor)),
            Text('made with ❤ for Nucleus.eti',
                style: GoogleFonts.poppins(
                    fontSize: media.width * 0.04, color: titleColor)),
          ],
        ),
      ),
    ])));
  }
}
