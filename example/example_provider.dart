import 'dart:async';

import 'package:flutter/material.dart';
import 'package:darter_bloc/darter_bloc.dart';
import 'package:darter_provider/darter_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'example_bloc.dart';

class ExampleProvider extends StatelessWidget {
  final Widget child;

  // Normally the constructor would also take as parameters whatever the BLoC
  // might need, in the form of its constructor parameters, or other BLoCs.
  ExampleProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    return BaseProvider.create(
      key: Key("Example"),
      inherited: ExampleInherited(
        child: child,
        bloc: ExampleBloc(),
      ),
      initialize: (ExampleBloc? bloc, Set<StreamSubscription?>? subscriptions) {
        // The initialization process takes place only the first time the
        // widget is built, and won't happen again until it's destroyed
        // and build once again. It's a good place to connect the outputs
        // of other BLoCs to the one in this provider. If the resulting
        // subscriptions are added to this method's parameter, they will
        // be automatically closed once the widget is destroyed.
        bloc?.firstSink.add("some_data");
        bloc?.secondSink.add("some_data");
        bloc?.thirdSink.add("some_data");
      },
      update: (ExampleBloc? bloc, Set<StreamSubscription?>? subscriptions) {
        // The update process takes place every time the widget is rebuilt.
        // It's the ideal place to update the BLoC's inputs that come directly
        // from this class constructor. It's a good idea to check here if the
        // new value is different from the previous one, and only forward it
        // to one of the BLoC's sinks if that is the case.
        bloc?.secondSink.add("some_data");
      },
    );
  }

  // It's important to set the inherited widget type for the static methods,
  // else the framework won't know what to look for in the widget tree.

  static ExampleBloc bloc(BuildContext context) =>
      BaseProvider.bloc<ExampleInherited>(context) as ExampleBloc;

  static PublishSubject<BaseException?> exception(BuildContext context) =>
      BaseProvider.exception<ExampleInherited>(context)
          as PublishSubject<BaseException?>;
}

// ignore: must_be_immutable
class ExampleInherited extends BaseInherited<ExampleBloc> {
  ExampleInherited({
    required Widget child,
    required ExampleBloc bloc,
  }) : super(child: child, bloc: bloc);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
