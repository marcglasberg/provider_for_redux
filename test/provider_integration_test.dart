import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider_for_redux/provider_for_redux.dart';

class _Increment extends ReduxAction<int> {
  @override
  int reduce() => state + 1;
}

class _ObservedStore extends Store<int> {
  _ObservedStore() : super(initialState: 4);
  var subscriptions = 0;

  @override
  Stream<int> get onChange => Stream<int>.multi((controller) {
    subscriptions++;
    final subscription = super.onChange.listen(
      controller.addSync,
      onError: controller.addErrorSync,
      onDone: controller.closeSync,
    );
    controller.onCancel = () {
      subscriptions--;
      return subscription.cancel();
    };
  }, isBroadcast: true);
}

void main() {
  testWidgets(
    'provider exposes the same Store, propagates dispatch and cancels its subscription',
    (tester) async {
      final store = _ObservedStore();
      final seen = <int>[];
      Dispatch<int>? dispatch;
      await tester.pumpWidget(
        AsyncReduxProvider<int>.value(
          value: store,
          child: Builder(
            builder: (context) {
              expect(identical(Provider.of<Store<int>>(context), store), isTrue);
              seen.add(Provider.of<int>(context));
              dispatch = Provider.of<Dispatch<int>>(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(seen.last, 4);
      expect(store.subscriptions, greaterThan(0));
      dispatch!(_Increment());
      expect(store.state, 5);
      await tester.pump();
      await tester.pump();
      expect(seen.last, 5);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(store.subscriptions, 0);
      store.shutdown();
    },
  );
}
