import 'package:flutter/material.dart';


class groupInformationPage extends StatefulWidget {
  const groupInformationPage({super.key});

  @override
  State<groupInformationPage> createState() => _groupInformationPageState();
}

class _groupInformationPageState extends State<groupInformationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            "Grupos",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );;
  }
}