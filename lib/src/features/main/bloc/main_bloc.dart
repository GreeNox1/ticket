import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logbook/logbook.dart';
import 'package:sqflite/sqflite.dart';

import 'package:ticket/src/common/constants/constants.dart';
import 'package:ticket/src/common/models/seat_model.dart';
import 'package:ticket/src/common/utils/enums/bloc_status_enum.dart';
import 'package:ticket/src/common/utils/enums/seat_status_enum.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc({required final Database database})
    : _database = database,
      super(const MainState()) {
    on<MainEvent>(
      (event, emit) => switch (event) {
        MainEvent$InitialSeats _ => _initialSeat(event, emit),
        MainEvent$LockedSeat _ => _lockedSeat(event, emit),
        MainEvent$ConfirmSeat _ => _confirmSeat(event, emit),
        MainEvent$BotAction _ => _botAction(event, emit),
        MainEvent$CheckExpiration _ => _checkExpiration(event, emit),
        MainEvent$ClearDB _ => _clearDB(event, emit),
        MainEvent$PauseTimer _ => _pause(event, emit),
        MainEvent$ResumeTimer _ => _resume(event, emit),
      },
    );

    add(MainEvent$ResumeTimer());

    l.i('Bloc yuklandi. Botni ishga tushirildi!');
  }

  final Database _database;
  final Random _random = Random();
  final String _botUserId = 'bot-123';
  Timer? _timerForBotAction;
  Timer? _timerForCheckExpiration;

  void _pause(MainEvent$PauseTimer event, Emitter<MainState> emit) {
    if (_timerForBotAction != null) {
      _timerForBotAction?.cancel();
      _timerForBotAction = null;
    }
    if (_timerForCheckExpiration != null) {
      _timerForCheckExpiration?.cancel();
      _timerForCheckExpiration = null;
    }

    l.i('Botni vaqtinchalik pause qilindi!');
  }

  void _resume(MainEvent$ResumeTimer event, Emitter<MainState> emit) {
    _timerForBotAction = Timer.periodic(const Duration(seconds: 4), (_) {
      add(MainEvent$BotAction());
    });

    _timerForCheckExpiration = Timer.periodic(const Duration(seconds: 1), (_) {
      add(MainEvent$CheckExpiration());
    });

    l.i('Botni yana ishga tushirildi!');
  }

  Future<void> _initialSeat(
    MainEvent$InitialSeats event,
    Emitter<MainState> emit,
  ) async {
    emit(state.copyWith(blocStatus: .loading));

    l.i("Ma'lumotlar yuklanmoqda!");

    try {
      List<SeatModel> seats = [];

      await _database.transaction((txn) async {
        List<Map<String, Object?>> data = await _readDataFromDB(txn);

        l.i("Ma'lumotlar databasedan o'qildi");

        seats = List.from(data.map((e) => SeatModel.fromJson(e)));
      });

      l.i("Ma'lumotlar yuklandi!");

      emit(state.copyWith(blocStatus: .success, seats: seats));
    } on Object catch (e, s) {
      debugPrint('Error (MainEvent\$InitialSeats): $e');
      debugPrint('$s');

      emit(state.copyWith(blocStatus: .error));
    }
  }

  Future<void> _lockedSeat(
    MainEvent$LockedSeat event,
    Emitter<MainState> emit,
  ) async {
    final seats = List<SeatModel>.from(state.seats);

    if (seats.isEmpty) return;

    SeatModel seat = seats[event.index];

    if (seat.status == .locked &&
        seat.lockExpirationTime != null &&
        DateTime.now().isAfter(seat.lockExpirationTime!)) {
      seat = seat.copyWith(
        status: .available,
        lockedBy: null,
        lockExpirationTime: null,
      );

      l.i("Seat ${seat.seatId} unlock qilindi (timeout)!");
    }

    if (seat.status != SeatStatus.available) return;

    seats[event.index] = seat.copyWith(
      status: SeatStatus.locked,
      lockedBy: event.userId,
      lockExpirationTime: DateTime.now().add(const Duration(seconds: 10)),
    );

    emit(state.copyWith(seats: seats));
    l.i("${event.userId} seat ${seat.seatId} lock qildi");
  }

  Future<void> _confirmSeat(
    MainEvent$ConfirmSeat event,
    Emitter<MainState> emit,
  ) async {
    final seats = List<SeatModel>.from(state.seats);

    if (seats.isEmpty) return;

    SeatModel seat = seats[event.index];

    if (seat.status != SeatStatus.locked) return;
    if (seat.lockedBy != event.userId) return;

    if (seat.lockExpirationTime == null ||
        DateTime.now().isAfter(seat.lockExpirationTime!)) {
      seats[event.index] = seat.copyWith(
        status: .available,
        lockedBy: null,
        lockExpirationTime: null,
      );

      emit(state.copyWith(seats: seats));
      l.i("Seat ${seat.seatId} unlock bo'ldi (timeout)");

      return;
    }

    seats[event.index] = seat.copyWith(
      status: .reserved,
      lockedBy: null,
      lockExpirationTime: null,
    );

    emit(state.copyWith(seats: seats));
    l.i("${event.userId} seat ${seat.seatId} reserved qildi");

    await _database.transaction((txn) async {
      await _updateDataFromDB(txn, event.index);
      l.i("Seat ${seat.seatId} database-ga reserved holatda saqlandi");
    });
  }

  // Botni ishga tushirish uchun
  Future<void> _botAction(
    MainEvent$BotAction event,
    Emitter<MainState> emit,
  ) async {
    final index = _random.nextInt(64);

    add(MainEvent$LockedSeat(index: index, userId: _botUserId));
    l.i("Bot seat $index lock qildi");

    if (_random.nextBool()) {
      add(MainEvent$ConfirmSeat(index: index, userId: _botUserId));
      l.i("Bot seat $index confirm qildi");
    }
  }

  Future<void> _checkExpiration(
    MainEvent$CheckExpiration event,
    Emitter<MainState> emit,
  ) async {
    emit(state.copyWith(blocStatus: .initial));

    final seats = List<SeatModel>.from(state.seats);

    for (int i = 0; i < seats.length; i++) {
      final seat = seats[i];

      if (seat.status == .locked &&
          seat.lockExpirationTime != null &&
          DateTime.now().isAfter(seat.lockExpirationTime!)) {
        seats[i] = seat.copyWith(
          status: .available,
          lockedBy: null,
          lockExpirationTime: null,
        );
        l.i("Seat ${seat.seatId} timeout orqali unlock qilindi");
      }
    }

    emit(state.copyWith(seats: seats, blocStatus: .success));
  }

  Future<void> _clearDB(
    MainEvent$ClearDB event,
    Emitter<MainState> emit,
  ) async {
    emit(state.copyWith(blocStatus: .loading));

    List<SeatModel> seats = [];

    await _database.transaction((txn) async {
      await _updateAllDataFromDB(txn);
      List<Map<String, Object?>> data = await _readDataFromDB(txn);
      seats = List.from(data.map((e) => SeatModel.fromJson(e)));
      l.i("Database barcha seats clear qilindi");
    });

    emit(state.copyWith(blocStatus: .success, seats: seats));
  }

  // Yordamchi funksiyalar

  /// Seats database dan ma'lumotlarni o'qish
  Future<List<Map<String, Object?>>> _readDataFromDB(Transaction txn) async {
    return await txn.rawQuery('''
            SELECT *
            FROM ${Constants.seatTableName};
            ''');
  }

  /// Seats database dagi ma'lumotlardan birini o'zgartirish
  Future<int> _updateDataFromDB(Transaction txn, int id) async {
    return await txn.rawUpdate('''
      UPDATE ${Constants.seatTableName}
      SET status = 'reserved'
      WHERE id = $id;
      ''');
  }

  /// Seats database dagi ma'lumotlardan birini o'zgartirish
  Future<int> _updateAllDataFromDB(Transaction txn) async {
    return await txn.rawUpdate('''
      UPDATE ${Constants.seatTableName}
      SET status = 'available'
      WHERE status = 'reserved' OR status = 'locked';
      ''');
  }
}
