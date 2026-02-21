import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ticket/src/common/models/seat_model.dart';
import 'package:ticket/src/common/utils/extensions/seat_model_extension.dart';
import 'package:ticket/src/common/utils/helpers/debouncing_throttling.dart';
import 'package:ticket/src/features/main/bloc/main_bloc.dart';
import 'package:ticket/src/features/main/widgets/sead_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final String userId = "greenox";
  final debouncing = Debouncing(duration: Duration(milliseconds: 300));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      debugPrint("Pause");
      context.read<MainBloc>().add(MainEvent$PauseTimer());
    } else if (state == AppLifecycleState.resumed) {
      debugPrint("Resume");
      context.read<MainBloc>().add(MainEvent$ResumeTimer());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket'),
        actions: [
          IconButton(
            onPressed: () {
              debouncing.call(() {
                context.read<MainBloc>().add(MainEvent$ClearDB());
              });
            },
            icon: Icon(Icons.clear),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: BlocBuilder<MainBloc, MainState>(
            builder: (context, state) {
              if (state.blocStatus.isLoading || state.seats.isEmpty) {
                return _isLoading();
              } else if (state.blocStatus.isError) {
                return _isError();
              } else {
                return _isSuccess(state.seats);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _isLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _isError() {
    return const Center(child: Text("Qandaydir hatolik ro'y berdi"));
  }

  Widget _isSuccess(List<SeatModel> seats) {
    return GridView.builder(
      itemCount: 64,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final seat = seats[index];
        String text = seat.seatId;

        if (seat.status == .locked) {
          final second = seat.timer ?? 0;
          text = '${seat.seatId}\n$second s';
        }

        return SeatButton(
          onPressed: () {
            debouncing.call(() {
              context.read<MainBloc>().add(
                MainEvent$LockedSeat(index: index, userId: userId),
              );
            });
            bottomSheet(index);
          },
          text: text,
          status: seats[index].status,
        );
      },
    );
  }

  void bottomSheet(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(150)),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: ColoredBox(
              color: Colors.white,
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                children: [
                  Text('Sizning kinoteartdagi joyingiz: ${index + 1}'),
                  ElevatedButton(
                    onPressed: () {
                      debouncing.call(() {
                        context.read<MainBloc>().add(
                          MainEvent$ConfirmSeat(index: index, userId: userId),
                        );
                        Navigator.pop(context);
                      });
                    },
                    child: Text('Joyni band qilish'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
