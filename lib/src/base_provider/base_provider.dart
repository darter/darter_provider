import 'dart:async';

import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'exrited_widget.dart';

typedef BaseFunction<T extends BaseBloc> = void Function(T bloc, Set<StreamSubscription> subscriptions);

/// A provider designed to work with [BaseBloc] in an efficient way. The main
/// idea behind it is to avoid rebuilding the BLoC every time the build method
/// of a [Widget] up in the widget tree is called. It is not meant to be directly
/// extended as a class. For more details on it's use, see the example.
class BaseProvider<T extends BaseBloc> extends StatefulWidget {

  static Map<Key, BaseProvider> _instances = Map();
  final Set<StreamSubscription> _subscriptions;
  final BaseInherited<T> _inherited;

  factory BaseProvider.create({
    @required Key key,
    @required BaseInherited<T> inherited,
    BaseFunction<T> initialize,
    BaseFunction<T> update,
  }) {
    if (_instances[key] == null) {
      _instances[key] = BaseProvider<T>._init(key: key, inherited: inherited);
      if (initialize != null) initialize(_instances[key]._inherited._bloc, _instances[key]._subscriptions);
      _instances[key]._subscriptions.add(_instances[key]._inherited._bloc.exceptionStream
          .listen((e) => _instances[key]._inherited.exception.add(e)));
    } else {
      if (update != null) {
        update(_instances[key]._inherited._bloc, _instances[key]._subscriptions);
      } _instances[key] = BaseProvider<T>._copy(key: key, inherited: inherited);
    } return _instances[key];
  }

  BaseProvider._init({
    @required Key key,
    @required BaseInherited<T> inherited,
  })  : _inherited = inherited..init(),
        _subscriptions = Set(),
        super(key: key);

  BaseProvider._copy({
    @required Key key,
    @required BaseInherited<T> inherited,
  })  : _inherited = inherited.._bloc = _instances[key]._inherited._bloc
          ..exception = _instances[key]._inherited.exception,
        _subscriptions = _instances[key]._subscriptions,
        super(key: key);

  static BaseBloc bloc<R extends BaseInherited>(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(R) as R)._bloc;

  static PublishSubject<BaseException> exception<R extends BaseInherited>(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(R) as R).exception;

  @override
  _BaseProviderState createState() => _BaseProviderState();

  static Future<dynamic> _dispose(Key key) async {
    if (_instances[key] != null) {
      List<Future> futures = List();
      futures.add(_instances[key]._inherited._bloc?.dispose() ?? Future.value());
      futures.add(_instances[key]._inherited.exception?.close() ?? Future.value());
      if (_instances[key]._subscriptions != null) {
        for (StreamSubscription subscription in _instances[key]._subscriptions)
          futures.add(subscription?.cancel() ?? Future.value());
      } _instances[key] = null;
      await Future.wait(futures);
    }
  }
}

class _BaseProviderState extends State<BaseProvider> {
  @override
  Widget build(BuildContext context) {
    return widget._inherited;
  }

  @override
  void dispose() {
    BaseProvider._dispose(widget.key);
    super.dispose();
  }
}

/// An inherited widget with a few tweaks. In order for the framework to be able
/// to differentiate between several [BaseProvider] it must be extended and
/// named differently, when provided to the constructors of said providers.
// ignore: must_be_immutable
abstract class BaseInherited<T extends BaseBloc> extends ExritedWidget {

  T _bloc;

  BaseInherited({
    @required Widget child,
    @required T bloc,
  }) :  _bloc = bloc,
        super(child: child);

  @override
  void init() {
    super.init();
    _bloc?.initialize();
  }
}