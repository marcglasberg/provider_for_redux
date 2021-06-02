// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dartlang.org/packages/async_redux

/// The app state, which in this case is a counter and a description.
class AppState {
  final int counter;
  final String description;

  AppState({
    required this.counter,
    required this.description,
  });

  AppState copy({int? counter, String? description}) => AppState(
        counter: counter ?? this.counter,
        description: description ?? this.description,
      );

  static AppState initialState() => AppState(counter: 0, description: "");

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          counter == other.counter &&
          description == other.description;

  @override
  int get hashCode => counter.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'AppState{counter: $counter, description: $description}';
  }
}
