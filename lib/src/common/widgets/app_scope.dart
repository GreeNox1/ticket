import 'package:flutter/material.dart';
import 'package:ticket/src/common/dependencies/dependencies.dart';

class TicketAppScope extends StatefulWidget {
  const TicketAppScope({
    super.key,
    required this.dependencies,
    required this.child,
  });

  final AppDependencies dependencies;
  final Widget child;

  @override
  State<TicketAppScope> createState() => TicketAppScopeState();
}

class TicketAppScopeState extends State<TicketAppScope> {
  late final AppDependencies dependencies;

  @override
  void initState() {
    super.initState();
    dependencies = widget.dependencies;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
