import 'package:flutter/material.dart';
import 'package:screamoclock/components/model.dart';

Widget showNext(DateTime now) {
  final slots = buildSlots(now);
  final slot = currentSlot(slots, now);
  final next = nextSlot(slots, now);

  if (next == null) {
    return Text(
      'Everybody will be off set next',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'GoogleSans',
        fontSize: 20,
        color: Colors.white70,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  final nextItems = <MapEntry<String, Status>>[
    MapEntry('A', next.statusA),
    MapEntry('B', next.statusB),
    MapEntry('C', next.statusC),
  ];

  final nextOffSet = nextItems
      .where((e) => e.value == Status.offSet)
      .map((e) => e.key)
      .toList();
  final nextMeal = nextItems
      .where((e) => e.value == Status.meal)
      .map((e) => e.key)
      .toList();

  String nextNames(List<String> names) {
    if (names.isEmpty) return 'nobody';
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]} & ${names[1]}';
    return 'This message should not be displayed';
  }

  final currentHasMeal =
      slot != null &&
      (slot.statusA == Status.meal ||
          slot.statusB == Status.meal ||
          slot.statusC == Status.meal);

  final nextOffSetLine = nextOffSet.isNotEmpty
      ? '${nextNames(nextOffSet)} off set'
      : null;
  final nextMealLine = nextMeal.isNotEmpty
      ? '${nextNames(nextMeal)} on meal'
      : null;
  final stillMealLine = (nextMeal.isNotEmpty && currentHasMeal) ? '' : null;

  final children = <Widget>[
    Text(
      'Next:',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'GoogleSans',
        fontWeight: FontWeight.w400,
        fontSize: 25,
        color: Colors.white54,
      ),
    ),
  ];

  if (nextOffSetLine != null) {
    children.add(const SizedBox(height: 6));
    children.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(
          nextOffSetLine,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'GoogleSans',
            fontWeight: FontWeight.w400,
            fontSize: 25,
            color: Colors.white60,
          ),
        ),
      ),
    );
  }
  if (stillMealLine != null) {
    children.add(const SizedBox(height: 6));
    children.add(
      Text(
        stillMealLine,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'GoogleSans',
          fontWeight: FontWeight.w400,
          fontSize: 25,
          color: Colors.orangeAccent,
        ),
      ),
    );
  } else if (nextMealLine != null) {
    children.add(const SizedBox(height: 6));
    children.add(
      Text(
        nextMealLine,
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

  return Padding(
    padding: const EdgeInsets.only(bottom: 100.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    ),
  );
}
