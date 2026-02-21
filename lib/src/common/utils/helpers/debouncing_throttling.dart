import 'dart:async';

class Debouncing {
  Debouncing({required this.duration});

  final Duration duration;
  Timer? _timer;

  void call(void Function() function) {
    if (_timer?.isActive ?? false) dispose();

    _timer = Timer(duration, function);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

class Throttling {
  Throttling({required this.duration});

  final Duration duration;
  Timer? _timer;

  void call(void Function() function) {
    _timer ??= Timer(duration, () {
      dispose();

      function();
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
