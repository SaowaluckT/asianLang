import 'dart:async';

typedef DebouncedFunction<T> = void Function(T value);

class Debouncer<T> {
  final Duration duration;
  Timer? _timer;

  Debouncer(this.duration);

  void call(DebouncedFunction<T> func, T value) {
    _timer?.cancel();
    _timer = Timer(duration, () => func(value));
  }
}
