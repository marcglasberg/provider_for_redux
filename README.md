[![pub package](https://img.shields.io/pub/v/provider_for_redux.svg)](https://pub.dartlang.org/packages/provider_for_redux)

# provider_for_redux

With <a href="https://pub.dev/packages/provider">Provider</a> you can inject your state, but it's
your job to figure out how to update that state, structure the solution etc. In other words,
Provider is a great alternative to `InheritedWidget`, and lets you do dependency injection, but you
still need to do your own state management.

What people mean by “Provider as state management” is usually using Provider to do scoped model. But
as a matter of fact, this is not the only possible architecture using Provider. You can use it with
Bloc, Mobx, Redux and other.

This package lets you use it with <a href="https://pub.dev/packages/async_redux">AsyncRedux</a>, the
non-boilerplate version of Redux.

## How to use it

Please, read the async_redux <a href="https://pub.dev/packages/async_redux">documentation</a> first,
if you haven't already.

You should have learned that to use AsyncRedux the traditional way, you provide the Redux store to
your app by wrapping it with a `StoreProvider`, and then using the so called "connector" widgets,
like the `MyHomePageConnector` below:

```
@override
Widget build(BuildContext context) =>
    StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: MyHomePageConnector(),
        ));
```

Now, if you want to use AsyncRedux with `Provider`, simply remove the `StoreProvider` and
use `AsyncReduxProvider` instead. Also, you won't need the connector widgets anymore, since you will
use `Provider` instead.

For example:

```
@override
Widget build(BuildContext context) =>
    AsyncReduxProvider<AppState>.value( // Instead of StoreProvider.
        value: store,
        child: MaterialApp(
          home: MyHomePage(), // Instead of MyHomePageConnector. 
        ));
```

The `AsyncReduxProvider` widget above will expose the store, the state, and the dispatch method to
its descendants:

* The Redux store, of type `Store`. Get it like this: `Provider.of<Store<AppState>>(context)`.

* The store's state, of type `AppState`. Get it like this: `Provider.of<AppState>(context)`.

* The dispatch method, of type `Dispatch`. Get it like this: `Provider.of<Dispatch>(context)`.

This is a complete example:

```
class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  int counter(context) =>
      Provider
          .of<AppState>(context)
          .counter;

  String description(context) =>
      Provider
          .of<AppState>(context)
          .description;

  VoidCallback onIncrement(context) =>
          () => Provider.of<Dispatch>(context, listen: false)(IncrementAndGetDescriptionAction());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Increment Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("You've pushed the button:"),
            Text('${counter(context)}', style: TextStyle(fontSize: 30)),
            Text('${description(context)}', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onIncrement(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
```     

Try running
the <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main.dart">
Provider.of</a> example.

## Consumer

You can use Provider's
<a href="https://pub.dev/documentation/provider/latest/provider/Consumer-class.html">`Consumer`</a>
class to read from the store.
For <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main_consumer.dart">
example</a>:

```
return Consumer<Store<AppState>>(
   builder: (context, store, child) =>
      ...
      Text('${store.state.counter}'),
      ...
      onPressed: () => store.dispatch(IncrementAction()),
),
```

But it's easier if you use `ReduxConsumer`, which already gives you the store, the state, and the
dispatch method:

```
return ReduxConsumer<AppState>(
   builder: (context, store, state, dispatch, child) => ...
```

This is a complete example:

```            
class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReduxConsumer<AppState>(
      builder: (context, store, state, dispatch, child) => Scaffold(
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
        ),
      ),
    );
  }
}
```        

Try running
the <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main_redux_consumer.dart">
ReduxConsumer</a> example.

## Selector

You can use Provider's
<a href="https://pub.dev/documentation/provider/latest/provider/Selector-class.html">`Selector`</a>
class to read from the store, while preventing unnecessary widget rebuilds.
For <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main_selector.dart">
example</a>:

```       
return Selector<Store<AppState>, Tuple2<int, Dispatch>>(

   selector: (context, store) => 
      Tuple2(store.state.counter, store.dispatch),

   builder: (context, model, child) => 
      ...     
      Text('${model.item1}'),
      ...
      onPressed: () => model.item3(IncrementAction()),      
      ),
```

Your `selector` parameter must return a "model"
which you can use to build your widget in the `builder` parameter. In the above example the model is
a `Tuple2` instance, but you can return any immutable object that correctly implements equals and
hashcode. The widget will rebuild whenever the model changes.

But it's easier if you use `ReduxSelector`, which already gives you the store, the state, and the
dispatch method:

```
return ReduxSelector<AppState, Tuple2<int, String>>(
selector: (context, state) => Tuple2(state.counter, store.dispatch),
builder: (ctx, store, state, dispatch, model, child) =>
   ...
   Text('${state.counter}'),
   ...
   onPressed: () => store.dispatch(IncrementAction()
   ),
),
```

Try running
the <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main_redux_selector_with_model.dart">
ReduxSelector with model</a> example.

However, `ReduxSelector` also lets you return a `List` as the model. In case you do that, it will
rebuild the widget whenever any of the items in the list changes:

```
return ReduxSelector<AppState, dynamic>(
selector: (context, state) => [...],
builder: (context, store, state, dispatch, model, child) => ...    
```                                                                                           

**Using `ReduxSelector` with a list is the easiest way of all**, since you just need to list all of
the state parts that should trigger a rebuild.

**Note:** The `builder` gives you both the `state` and the `model`, and you can choose one of them
to build your widget from. While using `state` is probably easier for you, it's also easier to
accidentally use something you forget to add to the `model`, and then wonder why the Widget doesn't
rebuild. So you have two options:

1) Use only the `model` and have the compiler make sure there's no state you're using from outside
   of the model.
2) Use `state` directly, and have yourself the responsibility to make you've listed everything you'
   re using in the model.

This is a complete example:

```            

Widget build(BuildContext context) {       
  return ReduxSelector<AppState, dynamic>(
     
      selector: (context, state) => [
                                    state.counter, 
                                    state.description
                                    ],

      builder: (context, store, state, dispatch, model, child) => 
         Scaffold(
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
```       

Try running
the <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main_redux_selector_with_list.dart">
ReduxSelector with list</a> example.

## Migrating

When you use `AsyncReduxProvider` you will notice that both `Provider` and
AsyncRedux's `StoreConnector`
will work simultaneously. You can mix and match both of them, as desired, or slowly migrate between
them.

***

*Special thanks for <a href="https://github.com/rrousselGit">Remi Rousselet</a>, main author of
Provider, for helping me with ideas and making suggestions.*

*The Flutter packages I've authored:*

* <a href="https://pub.dev/packages/async_redux">async_redux</a>
* <a href="https://pub.dev/packages/fast_immutable_collections">fast_immutable_collections</a>
* <a href="https://pub.dev/packages/provider_for_redux">provider_for_redux</a>
* <a href="https://pub.dev/packages/i18n_extension">i18n_extension</a>
* <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
* <a href="https://pub.dev/packages/network_to_file_image">network_to_file_image</a>
* <a href="https://pub.dev/packages/image_pixels">image_pixels</a>
* <a href="https://pub.dev/packages/matrix4_transform">matrix4_transform</a>
* <a href="https://pub.dev/packages/back_button_interceptor">back_button_interceptor</a>
* <a href="https://pub.dev/packages/indexed_list_view">indexed_list_view</a>
* <a href="https://pub.dev/packages/animated_size_and_fade">animated_size_and_fade</a>
* <a href="https://pub.dev/packages/assorted_layout_widgets">assorted_layout_widgets</a>
* <a href="https://pub.dev/packages/weak_map">weak_map</a>
* <a href="https://pub.dev/packages/themed">themed</a>
* <a href="https://pub.dev/packages/bdd_framework">bdd_framework</a>

*My Medium Articles:*

* <a href="https://medium.com/flutter-community/https-medium-com-marcglasberg-async-redux-33ac5e27d5f6">
  Async Redux: Flutter’s non-boilerplate version of Redux</a> (
  versions: <a href="https://medium.com/flutterando/async-redux-pt-brasil-e783ceb13c43">
  Português</a>)
* <a href="https://medium.com/flutter-community/i18n-extension-flutter-b966f4c65df9">
  i18n_extension</a> (
  versions: <a href="https://medium.com/flutterando/qual-a-forma-f%C3%A1cil-de-traduzir-seu-app-flutter-para-outros-idiomas-ab5178cf0336">
  Português</a>)
* <a href="https://medium.com/flutter-community/flutter-the-advanced-layout-rule-even-beginners-must-know-edc9516d1a2">
  Flutter: The Advanced Layout Rule Even Beginners Must Know</a> (
  versions: <a href="https://habr.com/ru/post/500210/">русский</a>)
* <a href="https://medium.com/flutter-community/the-new-way-to-create-themes-in-your-flutter-app-7fdfc4f3df5f">
  The New Way to create Themes in your Flutter App</a> 

*My article in the official Flutter documentation*:

* <a href="https://flutter.dev/docs/development/ui/layout/constraints">Understanding constraints</a>

---<br>_Marcelo Glasberg:_<br>
_https://github.com/marcglasberg_<br>
_https://twitter.com/glasbergmarcelo_<br>
_https://stackoverflow.com/users/3411681/marcg_<br>
_https://medium.com/@marcglasberg_<br>
