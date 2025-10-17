import 'package:flutter/material.dart';

Widget postShowView(DateTime now, DateTime endtime) {
  if (now.isAfter(endtime)) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 35,
        children: [
          Text(
            'FEED THE FEAR!! NOURISH THE TERROR!!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'GoogleSans',
              fontSize: 25,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          Text(
            'Event closed! Great job everyone!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'GoogleSans',
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  } else {
    return const Text(
      'You shouldn\'t be seeing this. If you are, something went wrong and the app has glitched.',
    );
  }
}
