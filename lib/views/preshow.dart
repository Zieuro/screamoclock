import 'package:flutter/material.dart';
import 'package:screamoclock/Components/formatduration.dart';

Widget preShowView(DateTime now, DateTime calltime, DateTime starttime) {
  Widget content;
  if (now.isBefore(calltime)) {
    final calltimeRemaining = calltime.difference(now);
    content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Be at venue in',
          style: TextStyle(
            fontFamily: 'GoogleSans',
            color: Colors.white70,
            fontSize: 30,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          formatDuration(calltimeRemaining),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'GoogleSans',
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  } else if (now.isBefore(starttime)) {
    final starttimeRemaining = starttime.difference(now);
    content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Event starts in',
          style: TextStyle(
            fontFamily: 'GoogleSans',
            color: Colors.white70,
            fontSize: 30,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          formatDuration(starttimeRemaining),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'GoogleSans',
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  } else {
    content = Text(
      'It\'s showtime!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'GoogleSans',
        color: Colors.white,
        fontSize: 40,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  return content;
}
