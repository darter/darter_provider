import 'dart:async';

import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'exrited_widget.dart';

typedef MultiBaseFunction = void Function(Map<String, BaseBloc> blocs, Set<StreamSubscription> subscriptions);

/// A provider designed to work with several [BaseBloc] in an efficient way.
/// The main idea behind it is to avoid rebuilding the BLoCs every time the build
/// method of a [Widget] up in the widget tree is called. It is not meant to be
/// directly extended as a class. For more details on it's use, see the example.
class MultiBaseProvider extends StatefulWidget {

  static Map<Key, MultiBaseProvider> _instances = Map();
  final Set<StreamSubscription> _subscriptions;
  final MultiBaseInherited _inherited;

  factory MultiBaseProvider.create({
    @required Key key,
    @required MultiBaseInherited inherited,
    MultiBaseFunction initialize,
    MultiBaseFunction update,
  }) {
    if (_instances[key] == null) {
      _instances[key] = MultiBaseProvider._init(key: key, inherited: inherited);
      if (initialize != null) initialize(_instances[key]._inherited._blocs, _instances[key]._subscriptions);
      for (BaseBloc bloc in _instances[key]._inherited._blocs.values)
        _instances[key]._subscriptions.add(bloc.exceptionStream
            .listen((e) => _instances[key]._inherited.exception.add(e)));
    } else {
      if (update != null) {
        update(_instances[key]._inherited._blocs, _instances[key]._subscriptions);
      } _instances[key] = MultiBaseProvider._copy(key: key, inherited: inherited);
    } return _instances[key];
  }

  MultiBaseProvider._init({
    @required Key key,
    @required MultiBaseInherited inherited,
  })  : _inherited = inherited..init(),
        _subscriptions = Set(),
        super(key: key);

  MultiBaseProvider._copy({
    @required Key key,
    @required MultiBaseInherited inherited,
  })  : _inherited = inherited.._blocs = _instances[key]._inherited._blocs
          ..exception = _instances[key]._inherited.exception,
        _subscriptions = _instances[key]._subscriptions,
        super(key: key);

  static BaseBloc bloc<R extends MultiBaseInherited>(BuildContext context, String key) =>
      (context.inheritFromWidgetOfExactType(R) as R)._blocs[key];

  static PublishSubject<BaseException> exception<R extends MultiBaseInherited>(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(R) as R).exception;

  @override
  _MultiBaseProviderState createState() => _MultiBaseProviderState();

  static Future<dynamic> _dispose(Key key) async {
    if (_instances[key] != null) {
      List<Future> futures = List();
      for (BaseBloc bloc in _instances[key]._inherited._blocs.values)
        futures.add(bloc?.dispose() ?? Future.value());
      futures.add(_instances[key]._inherited.exception?.close() ?? Future.value());
      if (_instances[key]._subscriptions != null) {
        for (StreamSubscription subscription in _instances[key]._subscriptions)
          futures.add(subscription?.cancel() ?? Future.value());
      } _instances[key] = null;
      await Future.wait(futures);
    }
  }
}

class _MultiBaseProviderState extends State<MultiBaseProvider> {
  @override
  Widget build(BuildContext context) {
    return widget._inherited;
  }

  @override
  void dispose() {
    MultiBaseProvider._dispose(widget.key);
    super.dispose();
  }
}

/// An inherited widget with a few tweaks. In order for the framework to be able
/// to differentiate between several [MultiBaseProvider] they must be extended
/// and named differently, when provided to the constructors of said providers.
// ignore: must_be_immutable
abstract class MultiBaseInherited extends ExritedWidget {

  Map<String, BaseBloc> _blocs;

  MultiBaseInherited({
    @required Widget child,
    @required Map<String, BaseBloc> blocs,
  }) :  _blocs = blocs,
        super(child: child);

  @override
  void init() {
    super.init();
    if (_blocs?.isNotEmpty ?? false) {
      for (BaseBloc bloc in _blocs.values) {
        bloc.initialize();
      }
    }
  }
}