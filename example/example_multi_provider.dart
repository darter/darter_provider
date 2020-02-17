import 'dart:async';

import 'package:flutter/material.dart';
import 'package:darter_bloc/darter_bloc.dart';
import 'package:darter_provider/darter_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'example_bloc.dart';

class ExampleMultiProvider extends StatelessWidget {
  final Widget child;

  // Normally the constructor would also take as parameters whatever the BLoCs
  // might need, in the form of its constructor parameters, or other BLoCs.
  ExampleMultiProvider({this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBaseProvider.create(
      key: Key("Example"),
      inherited: ExampleMultiInherited(
        child: child,
        blocs: {
          "left": ExampleBloc(),
          "right": ExampleBloc(),
        },
      ),
      initialize: (Map<String, BaseBloc> blocs, Set<StreamSubscription> subscriptions) {
        // The initialization process takes place only the first time the
        // widget is built, and won't happen again until it's destroyed
        // and build once again. It's a good place to connect the outputs
        // of other BLoCs to the ones in this provider. If the resulting
        // subscriptions are added to this method's parameter, they will
        // be automatically closed once the widget is destroyed.
        ExampleBloc left = blocs["left"];
        left.firstSink.add("some_data");
        left.secondSink.add("some_data");
        left.thirdSink.add("some_data");
        ExampleBloc right = blocs["right"];
        right.firstSink.add("some_data");
        right.secondSink.add("some_data");
        right.thirdSink.add("some_data");
      },
      update: (Map<String, BaseBloc> blocs, Set<StreamSubscription> subscriptions) {
        // The update process takes place every time the widget is rebuilt.
        // It's the ideal place to update the BLoC's inputs that come directly
        // from this class constructor. It's a good idea to check here if the
        // new value is different from the previous one, and only forward it
        // to one of the BLoCs sinks if that is the case.
        ExampleBloc left = blocs["left"];
        left.secondSink.add("some_data");
        ExampleBloc right = blocs["right"];
        right.secondSink.add("some_data");
      },
    );
  }

  // It's important to set the inherited widget type for the static methods,
  // else the framework won't know what to look for in the widget tree.

  // The key used to retrieve the correct BLoC in this manner must be the same
  // as the one used when feeding the BLoCs to the inherited widget constructor.

  static ExampleBloc leftBloc(BuildContext context) =>
      MultiBaseProvider.bloc<ExampleMultiInherited>(context, "left");

  static ExampleBloc rightBloc(BuildContext context) =>
      MultiBaseProvider.bloc<ExampleMultiInherited>(context, "right");

  static PublishSubject<BaseException> exception(BuildContext context) =>
      MultiBaseProvider.exception<ExampleMultiInherited>(context);
}

// ignore: must_be_immutable
class ExampleMultiInherited extends MultiBaseInherited {

  ExampleMultiInherited({
    @required Widget child,
    @required Map<String, BaseBloc> blocs,
  }) : super(child: child, blocs: blocs);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}