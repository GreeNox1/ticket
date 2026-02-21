import 'package:flutter/material.dart';
import 'package:logbook/logbook.dart';

import 'package:ticket/src/features/main/screens/main_screens.dart';

class TicketApp extends StatelessWidget {
  const TicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ticket App',
      home: MainScreen(),
      builder: (context, child) => Logbook(
        config: LogbookConfig(enabled: true),
        child: child ?? SizedBox.shrink(),
      ),
    );
  }
}
