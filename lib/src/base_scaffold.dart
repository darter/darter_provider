import 'dart:async';

import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'base_provider/exrited_widget.dart';

typedef ShowFunction = dynamic Function(BuildContext context, String message);

/// A [Scaffold] designed to handle [BaseException] in the user interface.
/// The new parameter [showFunction] can be used to customize how this happens.
/// When extending the class, the type of the [ExritedWidget] must be specified.
abstract class BaseScaffold<T extends ExritedWidget> extends Scaffold {
  BaseScaffold({
    Key key,
    PreferredSizeWidget appBar,
    Widget body,
    Widget floatingActionButton,
    FloatingActionButtonLocation floatingActionButtonLocation,
    FloatingActionButtonAnimator floatingActionButtonAnimator,
    List<Widget> persistentFooterButtons,
    Widget drawer,
    Widget endDrawer,
    Widget bottomNavigationBar,
    Widget bottomSheet,
    Color backgroundColor,
    bool resizeToAvoidBottomPadding,
    bool resizeToAvoidBottomInset,
    bool primary = true,
    DragStartBehavior drawerDragStartBehavior = DragStartBehavior.start,
    bool extendBody = false,
    Color drawerScrimColor,
    double drawerEdgeDragWidth,
    ShowFunction showFunction,
  }) : super(
    key: key,
    appBar: appBar,
    body: ExceptionWidget<T>(child: body, showFunction: showFunction),
    floatingActionButton: floatingActionButton,
    floatingActionButtonLocation: floatingActionButtonLocation,
    floatingActionButtonAnimator: floatingActionButtonAnimator,
    persistentFooterButtons: persistentFooterButtons,
    drawer: drawer,
    endDrawer: endDrawer,
    bottomNavigationBar: bottomNavigationBar,
    bottomSheet: bottomSheet,
    backgroundColor: backgroundColor,
    resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    primary: primary,
    drawerDragStartBehavior: drawerDragStartBehavior,
    extendBody: extendBody,
    drawerScrimColor: drawerScrimColor,
    drawerEdgeDragWidth: drawerEdgeDragWidth,
  );
}

class ExceptionWidget<T extends ExritedWidget> extends StatefulWidget {

  final PublishSubject<BaseException> Function(BuildContext context) _exceptionFunction =
      (BuildContext context) => (context.inheritFromWidgetOfExactType(T) as T).exception;

  final Widget child;
  final ShowFunction showFunction;

  ExceptionWidget({this.child, this.showFunction});

  @override
  _ExceptionWidgetState createState() => _ExceptionWidgetState();
}

class _ExceptionWidgetState extends State<ExceptionWidget> {
  StreamSubscription exceptions;

  final ShowFunction defaultFunction = (BuildContext context, String message) {
    ScaffoldState scaffold = Scaffold.of(context);
    scaffold.removeCurrentSnackBar();
    scaffold.showSnackBar(SnackBar(content: Text(message)));
  };

  @override
  void didChangeDependencies() {
    exceptions?.cancel();
    // ignore: close_sinks
    PublishSubject<BaseException> subject = widget._exceptionFunction(context);
    exceptions = subject.stream.listen((e) => e != null ? (widget.showFunction != null
        ? widget.showFunction(context, e.message) : defaultFunction(context, e.message)) : null);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    exceptions?.cancel();
    super.dispose();
  }
}

