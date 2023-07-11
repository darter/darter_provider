import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

// ignore: must_be_immutable
abstract class ExritedWidget extends InheritedWidget {
  // ignore: close_sinks
  PublishSubject<BaseException?>? exception;

  ExritedWidget({
    required Widget child,
  }) : super(child: child);

  void init() => exception = PublishSubject();
}
