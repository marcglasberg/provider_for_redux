import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'app_state.dart';

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/async_redux

///////////////////////////////////////////////////////////////////////////////

/// This action increments the counter by 1,
/// and then gets some description text relating to the new counter number.
class IncrementAndGetDescriptionAction extends ReduxAction<AppState> {
  //
  // Async reducer.
  // To make it async we simply return Future<AppState> instead of AppState.
  @override
  Future<AppState> reduce() async {
    // First, we increment the counter, synchronously.
    dispatch(IncrementAction(amount: 1));

    // Then, we start and wait for some asynchronous process.
    String description = await read("http://numbersapi.com/${state.counter}");

    // After we get the response, we can modify the state with it,
    // without having to dispatch another action.
    return state.copy(description: description);
  }
}

///////////////////////////////////////////////////////////////////////////////

/// This action increments the counter by [amount]].
class IncrementAction extends ReduxAction<AppState> {
  final int amount;

  IncrementAction({@required this.amount}) : assert(amount != null);

  // Synchronous reducer.
  @override
  AppState reduce() => state.copy(counter: state.counter + amount);
}

///////////////////////////////////////////////////////////////////////////////
