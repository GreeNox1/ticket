import 'package:ticket/src/common/models/seat_model.dart';

extension SeatModelExtension on SeatModel {
  int? get timer {
    if (status == .locked && lockExpirationTime != null) {
      final diff = lockExpirationTime!.difference(DateTime.now()).inSeconds;
      return diff > 0 ? diff : 0;
    }
    return null;
  }
}