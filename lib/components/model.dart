enum Status { onSet, offSet, meal }

enum Spot { pos1, pos2, off }

class Slot {
  final DateTime start;
  final DateTime end;
  final Status statusA;
  final Status statusB;
  final Status statusC;
  final Spot spotA;
  final Spot spotB;
  final Spot spotC;

  const Slot({
    required this.start,
    required this.end,
    required this.statusA,
    required this.statusB,
    required this.statusC,
    required this.spotA,
    required this.spotB,
    required this.spotC,
  });
}

DateTime _t(int hour12, int minute, bool isPM, DateTime now) {
  // Today at midnight (local)
  final base = DateTime(now.year, now.month, now.day);
  // Convert 12h -> 24h
  int hour24 = hour12 % 12 + (isPM ? 12 : 0);
  if (hour12 == 12 && !isPM) hour24 = 0; // 12 AM
  if (hour12 == 12 && isPM) hour24 = 12; // 12 PM
  return DateTime(base.year, base.month, base.day, hour24, minute);
}

Slot _s(DateTime start, Status a, Spot posA, Status b, Spot posB, Status c, Spot posC) {
  return Slot(
    start: start,
    end: start.add(const Duration(minutes: 20)),
    statusA: a,
    statusB: b,
    statusC: c,
    spotA: posA,
    spotB: posB,
    spotC: posC,
  );
}

List<Slot> buildSlots(DateTime now) {
  final n = now;
  return [
    _s(_t(7, 0, true, n), Status.onSet, Spot.pos1, Status.onSet, Spot.pos2, Status.offSet, Spot.off),
    _s(_t(7, 20, true, n), Status.onSet, Spot.pos2, Status.offSet, Spot.off, Status.onSet, Spot.pos1),
    _s(_t(7, 40, true, n), Status.meal, Spot.off,Status.onSet, Spot.pos1,Status.onSet, Spot.pos2),
    _s(_t(8, 0, true, n), Status.meal, Spot.off, Status.onSet, Spot.pos2,Status.onSet, Spot.pos1),
    _s(_t(8, 20, true, n), Status.onSet, Spot.pos2, Status.onSet, Spot.pos1, Status.offSet, Spot.off),
    _s(_t(8, 40, true, n), Status.onSet, Spot.pos1, Status.meal, Spot.off,Status.onSet, Spot.pos2),
    _s(_t(9, 0, true, n), Status.onSet, Spot.pos2, Status.meal, Spot.off, Status.onSet, Spot.pos1),
    _s(_t(9, 20, true, n), Status.offSet, Spot.off, Status.onSet, Spot.pos1, Status.onSet, Spot.pos2),
    _s(_t(9, 40, true, n), Status.onSet, Spot.pos1, Status.onSet, Spot.pos2, Status.meal, Spot.off),
    _s(_t(10, 0, true, n), Status.onSet, Spot.pos2, Status.onSet, Spot.pos1, Status.meal, Spot.off),
    _s(_t(10, 20, true, n), Status.onSet, Spot.pos1, Status.offSet, Spot.off, Status.onSet, Spot.pos2),
    _s(_t(10, 40, true, n), Status.offSet, Spot.off,Status.onSet, Spot.pos2, Status.onSet, Spot.pos1),
    _s(_t(11, 0, true, n), Status.onSet, Spot.pos2, Status.onSet, Spot.pos1, Status.offSet, Spot.off),
    _s(_t(11, 20, true, n), Status.onSet, Spot.pos1, Status.offSet, Spot.off, Status.onSet, Spot.pos2),
    _s(_t(11, 40, true, n), Status.offSet, Spot.off, Status.onSet, Spot.pos2, Status.onSet, Spot.pos1),
    _s(_t(12, 0, false, n), Status.onSet, Spot.pos2, Status.onSet, Spot.pos1, Status.offSet, Spot.off),
    _s(_t(12, 20, false, n), Status.onSet, Spot.pos1, Status.offSet, Spot.off, Status.onSet, Spot.pos2),
    _s(_t(12, 40, false, n), Status.offSet, Spot.off, Status.onSet, Spot.pos2, Status.onSet, Spot.pos1),
  ];
}

Slot? currentSlot(List<Slot> slots, DateTime now) {
  for (final s in slots) {
    final starts = !now.isBefore(s.start); // now >= start
    final ends = now.isBefore(s.end); // now < end
    if (starts && ends) return s;
  }
  return null;
}

Slot? nextSlot(List<Slot> slots, DateTime now) {
  //Find the index of the current slot
  final currentIndex = slots.indexWhere(
    (s) => !now.isBefore(s.start) && now.isBefore(s.end),
  );

  //If there is a following slot, return it
  if (currentIndex != -1 && currentIndex + 1 < slots.length) {
    return slots[currentIndex + 1];
  }
  // Otherwise return the first upcoming slot
  for (final s in slots) {
    if (s.start.isAfter(now)) return s;
  }
  return null;
}
