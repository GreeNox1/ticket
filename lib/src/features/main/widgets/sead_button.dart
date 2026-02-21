import 'package:flutter/material.dart';
import 'package:ticket/src/common/utils/enums/seat_status_enum.dart';

class SeatButton extends StatelessWidget {
  const SeatButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.status,
  });

  final void Function() onPressed;
  final SeatStatus status;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: status != .reserved ? onPressed : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: switch (status) {
            SeatStatus.locked => Colors.yellow,
            SeatStatus.reserved => Colors.red,
            SeatStatus.available => Colors.green,
          }.withAlpha((255 / 100 * 80).toInt()),
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          border: BoxBorder.all(color: Colors.black, width: 2),
        ),
        child: Text(text, textAlign: .center),
      ),
    );
  }
}
