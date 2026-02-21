part of 'main_bloc.dart';

sealed class MainEvent {}

final class MainEvent$InitialSeats extends MainEvent {
  MainEvent$InitialSeats();
}

final class MainEvent$LockedSeat extends MainEvent {
  MainEvent$LockedSeat({required this.index, required this.userId});

  final String userId;
  final int index;
}

final class MainEvent$ConfirmSeat extends MainEvent {
  MainEvent$ConfirmSeat({required this.index, required this.userId});

  final String userId;
  final int index;
}

final class MainEvent$BotAction extends MainEvent {
  MainEvent$BotAction();
}

final class MainEvent$CheckExpiration extends MainEvent {
  MainEvent$CheckExpiration();
}

final class MainEvent$ClearDB extends MainEvent {
  MainEvent$ClearDB();
}

final class MainEvent$PauseTimer extends MainEvent {
  MainEvent$PauseTimer();
}

final class MainEvent$ResumeTimer extends MainEvent {
  MainEvent$ResumeTimer();
}
