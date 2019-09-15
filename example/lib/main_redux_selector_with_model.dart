import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:provider_for_redux/provider_for_redux.dart';
import 'package:tuple/tuple.dart';

import 'actions.dart';
import 'app_state.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/provider_for_redux

Store<AppState> store;

/// This example shows how to use `ReduxSelector` to access the Redux store,
/// and how the selector may return a model class (in this case a `Tuple2`)
/// to control when the widget rebuilds.
///
void main() {
  var state = AppState.initialState();
  store = Store<AppState>(initialState: state);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AsyncReduxProvider<AppState>.value(
        value: store,
        child: MaterialApp(home: MyHomePage()),
      );
}

///////////////////////////////////////////////////////////////////////////////

/// The screen has a counter, a text description, and a button.
/// When the button is tapped, the counter will increment synchronously,
/// while an async process downloads some text description.
class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return ReduxSelector<AppState, Tuple2<int, String>>(
        //
        selector: (ctx, state) => Tuple2(
              state.counter,
              state.description,
            ),
        //
        builder: (ctx, store, state, dispatch, model, child) => Scaffold(
            appBar: AppBar(title: Text('Increment Example')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("You've pushed the button:"),
                  Text('${state.counter}', style: TextStyle(fontSize: 30)),
                  Text('${state.description}', style: TextStyle(fontSize: 15)),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => dispatch(IncrementAndGetDescriptionAction()),
              child: Icon(Icons.add),
            )));
  }
}
