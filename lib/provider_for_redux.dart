import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/async_redux

/// `AsyncReduxProvider` lets you use <a href="https://pub.dev/packages/provider">Provider</a>
/// with <a href="https://pub.dev/packages/async_redux">AsyncRedux</a>,
/// the non-boilerplate version of Redux.
///
/// `AsyncReduxProvider` exposes to its descendants:
/// the `Store`, the store's `AppState`, and the `Dispatch` method.
///
/// For example:
///
/// ```
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return AsyncReduxProvider<AppState>.value(
///       value: store,
///       child: MaterialApp(home: MyHomePage())
///     );
///   }}
/// ```
///
/// You can then use:
///
/// ```
/// Provider.of<Store<AppState>>(context) to get the store.
/// Provider.of<AppState>(context) to get the state.
/// Provider.of<Dispatch>(context) to get the dispatch method.
/// ```
///
/// Example of using `state` and `dispatch`:
///
/// ```
///  String myName = Provider.of<AppState>(context).myName;
///  Provider.of<Dispatch>(context)(IncrementAction());
/// ```
///
/// Please note, you can also access the `state` and `dispatch` through the `store`:
/// ```
///  String myName = Provider.of<Store<AppState>>(context).state.myName;
///  Provider.of<Store<AppState>>(context).dispatch(IncrementAction());
/// ```
///
class AsyncReduxProvider<St> extends StatefulWidget {
  final ValueBuilder<Store<St>> builder;
  final Disposer<Store<St>> dispose;
  final Widget child;

  AsyncReduxProvider({
    Key key,
    @required this.builder,
    this.dispose,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  AsyncReduxProvider.value({
    Key key,
    @required Store<St> value,
    Widget child,
  }) : this(
          key: key,
          builder: (context) => value,
          child: child,
        );

  @override
  _AsyncReduxProviderState<St> createState() => _AsyncReduxProviderState<St>();
}

class _AsyncReduxProviderState<St> extends State<AsyncReduxProvider<St>> {
  Store<St> _store;

  @override
  void initState() {
    super.initState();
    _store = widget.builder(context);
  }

  @override
  void dispose() {
    widget.dispose?.call(context, _store);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          //
          // The store: ------------------------
          StreamProvider<Store<St>>(
            builder: (BuildContext context) => _store.onChange.map((x) => _store),
            initialData: _store,
            catchError: null,
            updateShouldNotify: (Store<St> previous, Store<St> current) => true,
          ),
          //
          // The store state: ------------------
          StreamProvider<St>(
            builder: (BuildContext context) => _store.onChange,
            initialData: _store.state,
            catchError: null,
            updateShouldNotify: (St previous, St current) => true,
          ),
          //
          // The dispatch method:  -------------
          Provider<Dispatch>.value(value: _store.dispatch),
          //
        ],
        //
        // This is needed for the StoreConnector. In other words, you can
        // use both StoreConnector and AsyncReduxProvider at the same time,
        // allowing for the progressive migration between them.
        child: StoreProvider<St>(
          store: _store,
          child: widget.child,
        ),
      );
}

// ////////////////////////////////////////////////////////////////////////////

/// This widget will obtain the AsyncRedux store, state and dispatch method from its ancestors,
/// and pass them to the [builder].
///
/// For more info, see https://pub.dev/documentation/provider/latest/provider/Consumer-class.html
///
/// Example:
///
/// ```
///  Widget build(BuildContext context) =>
///    ReduxConsumer<AppState>(
///      builder: (context, store, state, dispatch, child) => Scaffold(
///        appBar: AppBar(title: Text('Increment Example')),
///        body: Center(
///          child: Column(
///            mainAxisAlignment: MainAxisAlignment.center,
///            children: [
///              Text("You've pushed the button:"),
///              Text('${state.counter}', style: TextStyle(fontSize: 30)),
///              Text('${state.description}', style: TextStyle(fontSize: 15)),
///            ],
///          ),
///        ),
///        floatingActionButton: FloatingActionButton(
///          onPressed: () => dispatch(IncrementAndGetDescriptionAction()),
///          child: Icon(Icons.add),
///        )));
/// ```
///
class ReduxConsumer<St> extends Consumer3<Store<St>, St, Dispatch> {
  ReduxConsumer({
    Key key,
    @required
        Widget Function(
      BuildContext context,
      Store<St> store,
      St state,
      Dispatch dispatch,
      Widget child,
    )
            builder,
    Widget child,
  })  : assert(builder != null),
        super(
          key: key,
          builder: builder,
          child: child,
        );
}

// ////////////////////////////////////////////////////////////////////////////

/// This widget will obtain the AsyncRedux store, state and dispatch method from its ancestors,
/// and pass them to the [builder].
/// It will also prevent unnecessary widget rebuilds. To that end, the [selector] should
/// return a "model" object, and the widget will rebuild only when that model changes.
/// The model will also be available in the builder.
///
/// If the returned model is a [List], then the widget will rebuild only when any of the list
/// items change.
///
/// For more info, see https://pub.dev/documentation/provider/latest/provider/Selector-class.html
///
/// Example:
///
/// ```
/// Widget build(BuildContext context) =>
///  ReduxSelector<AppState, dynamic>(
///     selector: (context, state) => [state.counter, state.description],
///     builder: (context, store, state, dispatch, model, child) =>
///         Scaffold(
///             appBar: AppBar(title: Text('Increment Example')),
///             body: Center(
///               child: Column(
///                 mainAxisAlignment: MainAxisAlignment.center,
///                 children: [
///                   Text("You've pushed the button:"),
///                   Text('${state.counter}', style: TextStyle(fontSize: 30)),
///                   Text('${state.description}', style: TextStyle(fontSize: 15)),
///                 ])),
///             floatingActionButton: FloatingActionButton(
///               onPressed: () => dispatch(IncrementAndGetDescriptionAction()),
///               child: Icon(Icons.add),
///             )));
/// ```
///
class ReduxSelector<St, Model> extends _Selector0<St, Model> {
  ReduxSelector({
    Key key,
    @required
        Widget Function(
      BuildContext context,
      Store<St> store,
      St state,
      Dispatch dispatch,
      Model model,
      Widget child,
    )
            builder,
    @required
        Model Function(BuildContext, St) selector,
    Widget child,
  })  : assert(selector != null),
        super(
          key: key,
          builder: builder,
          selector: (context) => selector(
            context,
            Provider.of<St>(context),
          ),
          child: child,
        );
}

// ////////////////////////////////////////////////////////////////////////////

class _Selector0<St, Model> extends StatefulWidget implements SingleChildCloneableWidget {
  /// Both `builder` and `selector` must not be `null`.
  _Selector0({
    Key key,
    @required this.builder,
    @required this.selector,
    this.child,
  })  : assert(builder != null),
        assert(selector != null),
        super(key: key);

  /// A function that builds a widget tree from [child] and the last result of
  /// [selector].
  ///
  /// [builder] will be called again whenever the its parent widget asks for an
  /// update, or if [selector] return a value that is different from the
  /// previous one using [operator==].
  ///
  /// Must not be `null`.
  final Widget Function(
    BuildContext context,
    Store<St> store,
    St state,
    Dispatch dispatch,
    Model model,
    Widget child,
  ) builder;

  /// A function that obtains some [InheritedWidget] and map their content into
  /// a new object with only a limited number of properties.
  ///
  /// The returned object must implement [operator==].
  ///
  /// Must not be `null`
  final ValueBuilder<Model> selector;

  /// A cache of a widget tree that does not depend on the value of [selector].
  ///
  /// See [Consumer] for an explanation on how to use it.
  final Widget child;

  @override
  _Selector0State<St, Model> createState() => _Selector0State<St, Model>();

  @override
  _Selector0<St, Model> cloneWithChild(Widget child) {
    return _Selector0(
      key: key,
      selector: selector,
      builder: builder,
      child: child,
    );
  }
}

class _Selector0State<St, Model> extends State<_Selector0<St, Model>> {
  Model model;
  Widget cache;
  Widget oldWidget;

  @override
  Widget build(BuildContext context) {
    Model selected = widget.selector(context);

    if (oldWidget != widget || modelChanged(selected)) {
      model = selected;
      oldWidget = widget;

      cache = widget.builder(
        context,
        Provider.of<Store<St>>(context),
        Provider.of<St>(context),
        Provider.of<Dispatch>(context),
        model,
        widget.child,
      );
    }
    return cache;
  }

  /// Compare the old model with the new model.
  /// However, if the model is a list, compare each list item.
  bool modelChanged(Model selected) {
    if (selected is List && model is List)
      return !(listEquals(selected, (model as List)));
    else
      return selected != model;
  }
}

// ////////////////////////////////////////////////////////////////////////////
