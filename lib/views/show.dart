import 'package:flutter/material.dart';
import 'package:screamoclock/components/model.dart';
import 'package:screamoclock/components/formatduration.dart';

Widget showView(DateTime now) {
  final slots = buildSlots(now);
  final slot = currentSlot(slots, now);

  if (slot == null) {
    return Text(
      'No active slot',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'GoogleSans',
        fontSize: 30,
        color: Colors.white70,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // map positions to names
  final items = <MapEntry<String, Status>>[
    MapEntry('A', slot.statusA),
    MapEntry('B', slot.statusB),
    MapEntry('C', slot.statusC),
  ];

  final onSet = items
      .where((e) => e.value == Status.onSet)
      .map((e) => e.key)
      .toList();
  final offSet = items
      .where((e) => e.value == Status.offSet)
      .map((e) => e.key)
      .toList();
  final meal = items
      .where((e) => e.value == Status.meal)
      .map((e) => e.key)
      .toList();

  String joinWithAmpersand(List<String> names) {
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]} & ${names[1]}';
    return 'You are not supposed to see this message';
  }

  final onSetLine = onSet.isNotEmpty
      ? '${joinWithAmpersand(onSet)} on set'
      : null;
  final offSetLine = offSet.isNotEmpty
      ? '${joinWithAmpersand(offSet)} off set'
      : null;
  final mealLine = meal.isNotEmpty
      ? '${joinWithAmpersand(meal)} on meal'
      : null;

  final children = <Widget>[];
  if (onSetLine != null) {
    children.add(
      Text(
        onSetLine,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'GoogleSans',
          fontWeight: FontWeight.w400,
          fontSize: 40,
          color: Colors.white,
        ),
      ),
    );
  }
  if (offSetLine != null) {
    children.add(const SizedBox(height: 6));
    children.add(
      Text(
        offSetLine,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'GoogleSans',
          fontWeight: FontWeight.w400,
          fontSize: 30,
          color: Colors.redAccent,
        ),
      ),
    );
  }
  if (mealLine != null) {
    children.add(const SizedBox(height: 6));
    children.add(
      Text(
        mealLine,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'GoogleSans',
          fontWeight: FontWeight.w400,
          fontSize: 30,
          color: Colors.orangeAccent,
        ),
      ),
    );
  }

  final timeRemaining = slot.end.difference(now);
  children.add(const SizedBox(height: 6));
  children.add(
    Text(
      'Next rotation in ${formatDuration(timeRemaining)}',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'GoogleSans',
        fontWeight: FontWeight.w300,
        fontSize: 25,
        color: Colors.white54,
      ),
    ),
  );

  return Column(
    spacing: 10,
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: children,
  );
}
