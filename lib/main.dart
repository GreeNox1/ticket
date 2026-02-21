import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ticket/src/common/utils/extensions/context_extension.dart';
import 'package:ticket/src/common/widgets/app_scope.dart';
import 'package:ticket/src/common/widgets/initialize_app.dart';
import 'package:ticket/src/features/main/bloc/main_bloc.dart';

import 'src/common/widgets/ticket_app.dart';

Future<void> main() async {
  final dependencies = await InitializeApp().initialize();

  runApp(
    TicketAppScope(
      dependencies: dependencies,
      child: BlocProvider(
        create: (context) {
          return MainBloc(database: context.dependencies.database)
            ..add(MainEvent$InitialSeats());
        },
        child: TicketApp(),
      ),
    ),
  );
}
