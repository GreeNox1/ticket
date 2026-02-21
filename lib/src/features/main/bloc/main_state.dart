part of 'main_bloc.dart';

class MainState extends Equatable {
  const MainState({
    this.blocStatus = BlocStatus.initial,
    this.seats = const <SeatModel>[],
  });

  final BlocStatus blocStatus;
  final List<SeatModel> seats;

  MainState copyWith({BlocStatus? blocStatus, List<SeatModel>? seats}) {
    return MainState(
      blocStatus: blocStatus ?? this.blocStatus,
      seats: seats ?? this.seats,
    );
  }

  @override
  List<Object?> get props => [blocStatus, seats];
}
