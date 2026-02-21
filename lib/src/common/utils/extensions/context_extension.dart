import 'package:flutter/material.dart';
import 'package:ticket/src/common/dependencies/dependencies.dart';
import 'package:ticket/src/common/widgets/app_scope.dart';

extension ContextX on BuildContext {
  AppDependencies get dependencies {
    return findAncestorStateOfType<TicketAppScopeState>()!.dependencies;
  }
}
