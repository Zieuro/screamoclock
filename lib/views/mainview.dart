import 'package:flutter/material.dart';
import 'package:screamoclock/views/postshow.dart';
import 'package:screamoclock/views/preshow.dart';
import 'package:screamoclock/views/show.dart';

Widget mainView(
  DateTime now,
  DateTime calltime,
  DateTime starttime,
  DateTime endtime,
) {
  if (now.isAfter(starttime) && now.isBefore(endtime)) {
    return Center(child: showView(now));
  } else if (now.isBefore(starttime)) {
    return Center(child: preShowView(now, calltime, starttime));
  } else {
    return Center(child: postShowView(now, endtime));
  }
}
