import 'package:ticket/src/common/utils/enums/seat_status_enum.dart';

class SeatModel {
  final int id;
  final String seatId;
  final SeatStatus status;
  final String? lockedBy;
  final DateTime? lockExpirationTime;

  SeatModel({
    required this.id,
    required this.status,
    required this.seatId,
    this.lockedBy,
    this.lockExpirationTime,
  });

  factory SeatModel.fromJson(Map<String, Object?> json) {
    return SeatModel(
      id: json['id'] as int,
      seatId: json['seat_id'] as String,
      status: switch (json['status'] as String) {
        'locked' => SeatStatus.locked,
        'reserved' => SeatStatus.reserved,
        _ => SeatStatus.available,
      },
      lockedBy: json['locked_by'] as String?,
      lockExpirationTime: (json['lock_expiration_time'] as int?) == null
          ? null
          : DateTime.fromMicrosecondsSinceEpoch(
              json['lock_expiration_time'] as int,
            ),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'seat_id': seatId,
      'status': status.name,
      'locked_by': lockedBy,
      'lock_expiration_time': lockExpirationTime?.millisecondsSinceEpoch,
    };
  }

  SeatModel copyWith({
    String? seatId,
    SeatStatus? status,
    String? lockedBy,
    DateTime? lockExpirationTime,
  }) {
    return SeatModel(
      id: id,
      status: status ?? this.status,
      seatId: seatId ?? this.seatId,
      lockedBy: lockedBy ?? this.lockedBy,
      lockExpirationTime: lockExpirationTime ?? this.lockExpirationTime,
    );
  }

  @override
  int get hashCode =>
      Object.hash(id, seatId, status, lockedBy, lockExpirationTime);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SeatModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            seatId == other.seatId &&
            status == other.status &&
            lockedBy == other.lockedBy &&
            lockExpirationTime == other.lockExpirationTime;
  }

  @override
  String toString() {
    return "SeatModel{id: $id, seat_id: $seatId, status: $status, locked_by: $lockedBy, lock_expiration_time: $lockExpirationTime}";
  }
}
