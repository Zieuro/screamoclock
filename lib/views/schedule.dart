import 'package:flutter/material.dart';
import 'package:screamoclock/components/model.dart';

Widget scheduleView() {
  final now = DateTime.now();
  final slots = buildSlots(now);

  Color statusColor(Status s) {
    switch (s) {
      case Status.onSet:
        return Colors.green.shade400;
      case Status.offSet:
        return Colors.red.shade400;
      case Status.meal:
        return Colors.orange.shade400;
    }
  }

  String statusLabel(Status s) {
    switch (s) {
      case Status.onSet:
        return '';
      case Status.offSet:
        return 'OFF';
      case Status.meal:
        return 'MEAL';
    }
  }

  String spotLabel(Spot p) {
    switch (p) {
      case Spot.pos1:
        return '1';
      case Spot.pos2:
        return '2';
      case Spot.off:
        return '';
    }
  }

  String fmtTimeRange(Slot s) {
    String fmt(DateTime t) {
      final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
      final minute = t.minute.toString().padLeft(2, '0');
      final ampm = t.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $ampm';
    }

    return '${fmt(s.start)}\n– ${fmt(s.end)}';
  }

  final rows = <TableRow>[];

  // Header
  rows.add(
    TableRow(
      decoration: BoxDecoration(color: Colors.grey[850]),
      children: [
        _tableCell('Time', isHeader: true, align: Alignment.centerLeft),
        _tableCell('A', isHeader: true, align: Alignment.centerLeft),
        _tableCell('B', isHeader: true, align: Alignment.centerLeft),
        _tableCell('C', isHeader: true, align: Alignment.centerLeft),
      ],
    ),
  );

  for (final s in slots) {
    rows.add(
      TableRow(
        decoration: BoxDecoration(
          color: now.isAfter(s.start) && now.isBefore(s.end)
              ? Colors.grey[800]
              : Colors.grey[900],
          border: Border(
            bottom: BorderSide(color: Colors.grey[800]!, width: 0.6),
          ),
        ),
        children: [
          _tableCell(fmtTimeRange(s), align: Alignment.centerLeft),
          _statusCell(
            'A',
            s.statusA,
            s.spotA,
            statusColor(s.statusA),
            statusLabel(s.statusA),
            spotLabel(s.spotA),
          ),
          _statusCell(
            'B',
            s.statusB,
            s.spotB,
            statusColor(s.statusB),
            statusLabel(s.statusB),
            spotLabel(s.spotB),
          ),
          _statusCell(
            'C',
            s.statusC,
            s.spotC,
            statusColor(s.statusC),
            statusLabel(s.statusC),
            spotLabel(s.spotC),
          ),
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: SingleChildScrollView(
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
          },
          children: rows,
        ),
      ),
    ),
  );
}

// helper cells
Widget _tableCell(
  String text, {
  bool isHeader = false,
  Alignment align = Alignment.center,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
    child: Align(
      alignment: align,
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontFamily: 'GoogleSans',
          color: isHeader ? Colors.white : Colors.white70,
          fontWeight: FontWeight.w400,
          fontSize: isHeader ? 14 : 13,
        ),
      ),
    ),
  );
}

Widget _statusCell(
  String label,
  Status status,
  Spot spot,
  Color bg,
  String shortLabel,
  String spotLabel,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Container(
        //   width: 10,
        //   height: 10,
        //   decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        // ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            shortLabel == '' ? spotLabel : shortLabel,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontFamily: 'GoogleSans',
              color: bg,
              fontSize: shortLabel == '' ? 16 : 13,
              fontWeight: shortLabel == '' ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}
