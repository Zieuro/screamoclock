import 'package:flutter/material.dart';
import 'package:screamoclock/views/schedule.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'Schedule',
          style: TextStyle(
            fontFamily: 'GoogleSans',
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.red,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.grey[900],
        elevation: 5,
      ),
      body: SafeArea(
        child: Center(child: SingleChildScrollView(child: scheduleView())),
      ),
    );
  }
}
