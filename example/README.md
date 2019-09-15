# Examples

All examples below show a counter, a text description, and a button.
When the button is tapped, the counter will increment synchronously,
while an async process downloads some text description that relates
to the counter number.  

1. <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main.dart">main</a>

    This example shows how to use `Provider.of` to access the Redux store.    

2. <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main_consumer.dart">main_consumer</a>
   
   This example shows how to use `Consumer` to access the Redux store.  

3. <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main_redux_consumer.dart">main_redux_consumer</a>
   
    This example shows how to use `ReduxConsumer` to access the Redux store.

4. <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main_selector.dart">main_selector</a>

    This example shows how to use `Selector` to access the Redux store.    

5. <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main_redux_selector_with_model.dart">main_redux_selector_with_model</a>

   This example shows how to use `ReduxSelector` to access the Redux store,
   and how the selector may return a model class (in this case a `Tuple2`)
   to control when the widget rebuilds.
 
6. <a href="https://github.com/marcglasberg/provider_for_redux/blob/master/example/lib/main_redux_selector_with_list.dart">main_redux_selector_with_list</a>
    
    This example shows how to use `ReduxSelector` to access the Redux store,
    and how the selector may return a list to control when the widget rebuilds.        

**Note:** All the above examples use `Provider` instead of the original Redux `StoreConnector`,
so you can also compare them with the corresponding AsyncRedux's original 
<a href="https://github.com/marcglasberg/async_redux/blob/master/example/lib/main_increment_async.dart">example with StoreConnector</a>.
