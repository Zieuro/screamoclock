import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GoogleSans',
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.red,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.grey[900],
        elevation: 5,
      ),
      body: Center(
        child: Text(
          'Settings coming HOS 2026!',
          style: TextStyle(
            fontFamily: 'GoogleSans',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
