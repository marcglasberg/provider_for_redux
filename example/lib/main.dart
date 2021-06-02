import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_for_redux/provider_for_redux.dart';

import 'actions.dart';
import 'app_state.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/provider_for_redux

late Store<AppState> store;

/// This example shows how to use `Provider.of` to access the Redux store.
///
/// Note: This example uses http. It was configured to work in Android, debug mode only.
/// If you use iOS, please see:
/// https://flutter.dev/docs/release/breaking-changes/network-policy-ios-android
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
        child: const MaterialApp(home: MyHomePage()),
      );
}

///////////////////////////////////////////////////////////////////////////////

/// The screen has a counter, a text description, and a button.
/// When the button is tapped, the counter will increment synchronously,
/// while an async process downloads some text description.
class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  int? counter(BuildContext ctx) => Provider.of<AppState>(ctx).counter;

  String description(BuildContext ctx) => Provider.of<AppState>(ctx).description;

  VoidCallback onIncrement(BuildContext ctx) =>
      () => Provider.of<Dispatch<AppState>>(ctx, listen: false)(IncrementAndGetDescriptionAction());

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
        appBar: AppBar(title: const Text('Increment Example (1)')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("You've pushed the button:"),
              Text('${counter(ctx)}', style: const TextStyle(fontSize: 30)),
              Text(description(ctx), style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onIncrement(ctx),
          child: const Icon(Icons.add),
        ));
  }
}
