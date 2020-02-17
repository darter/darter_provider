import 'dart:async';

import 'package:flutter/material.dart';
import 'package:darter_bloc/darter_bloc.dart';

import 'example_bloc.dart';
import 'example_provider.dart';
import 'example_scaffold.dart';

/// All [BaseException] thrown by the logic inside of the BLoC are shown as a
/// [SnackBar] inside the [ExampleScaffold]. The lifecycle of the [ExampleBloc]
/// declared inside of [ExampleProvider] is automatically handled, and will
/// remain even if the widget tree is reconstructed, only to be disposed of
/// when we are truly done with it (instead of whenever the state changes).
///
/// All [StreamSubscription] created when connecting other (theoretical) BLoC
/// outputs to the [ExampleBloc] inputs and the latter's [LenientSubject] are
/// closed or disposed of when the [ExampleProvider] is destroyed.
///
/// Furthermore, the [ExampleBloc] would only make calls to the database methods
/// when some of the inputs have actually changed, thanks to [LenientSubject]
/// having been configured to ignore repeated additions.
class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExampleProvider(
      child: ExampleScaffold(
        body: Container(),
        appBar: AppBar(
          title: StreamBuilder(
            stream: ExampleProvider.bloc(context).outputStream,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot != null) {
                return Text(snapshot.data);
              } else return Container();
            },
          ),
        ),
      ),
    );
  }
}
