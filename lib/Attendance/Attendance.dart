import 'package:flutter/material.dart';

import '../Adminscreen.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.cyan,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "Attendace",
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.home, size: 25, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Adminscreen()),
                );
              },
            ),
          ]),
    );
  }
}
