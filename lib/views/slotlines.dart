import 'package:screamoclock/Components/model.dart';

//easy helpers for notifications and alarms
class SlotLines {
  final String? onSet;
  final String? offSet;
  final String? meal;
  SlotLines({this.onSet, this.offSet, this.meal});
}

/// Return human-readable lines for the current slot at [now].
/// Example: SlotLines(onSet: 'A & B ON SET', offSet: 'C OFF SET', meal: null)
SlotLines currentSlotLines(DateTime now) {
  final slots = buildSlots(now);
  final slot = currentSlot(slots, now);
  if (slot == null) return SlotLines();

  final items = <MapEntry<String, Status>>[
    MapEntry('A', slot.statusA),
    MapEntry('B', slot.statusB),
    MapEntry('C', slot.statusC),
  ];

  List<String> namesFor(Status s) =>
      items.where((e) => e.value == s).map((e) => e.key).toList();

  String joinWithAmpersand(List<String> names) {
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]} & ${names[1]}';
    final last = names.last;
    return '${names.sublist(0, names.length - 1).join(', ')} & $last';
  }

  final on = namesFor(Status.onSet);
  final off = namesFor(Status.offSet);
  final meal = namesFor(Status.meal);

  final onLine = on.isNotEmpty ? '${joinWithAmpersand(on)} on SET' : null;
  final offLine = off.isNotEmpty ? '${joinWithAmpersand(off)} off SET' : null;
  final mealLine = meal.isNotEmpty
      ? '${joinWithAmpersand(meal)} on MEAL'
      : null;

  return SlotLines(onSet: onLine, offSet: offLine, meal: mealLine);
}
