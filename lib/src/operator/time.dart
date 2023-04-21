import 'dart:async';

import '../publisher.dart';
import '../subscriber.dart';

extension PublisherDebounce<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  DebouncePublisher<Output, Failure> debounce(Duration dueTime) =>
      DebouncePublisher<Output, Failure>(this, dueTime);

  DelayPublisher<Output, Failure> delay(Duration interval) =>
      DelayPublisher<Output, Failure>(this, interval);

  ThrottlePublisher<Output, Failure> throttle(Duration interval, bool latest) =>
      ThrottlePublisher<Output, Failure>(this, interval, latest);

  TimeoutPublisher<Output, Failure> timeout(Duration interval,
          {Failure Function()? customError}) =>
      TimeoutPublisher<Output, Failure>(this, interval, customError);
}

class DebouncePublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final Duration dueTime;
  Subscriber<Output, Failure>? _subscriber;
  Timer? _timer;
  Output? _value;

  DebouncePublisher(this.upstream, this.dueTime);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    _stopTimer();
    _subscriber?.complete(failure);
    _value = null;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _value = input;
    _startTimer();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(dueTime, (timer) {
      if (_value != null) {
        _subscriber?.receive(_value!);
      }
      _stopTimer();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

class DelayPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final Duration interval;
  Subscriber<Output, Failure>? _subscriber;

  DelayPublisher(this.upstream, this.interval);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    Future.delayed(interval, () {
      _subscriber?.receive(input);
    });
  }
}

class ThrottlePublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final Duration interval;
  final bool latest;
  Subscriber<Output, Failure>? _subscriber;
  Timer? _timer;
  Output? _value;

  ThrottlePublisher(this.upstream, this.interval, this.latest);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
    _startTimer();
  }

  @override
  void complete([Failure? failure]) {
    _stopTimer();
    if (failure == null && _value != null) {
      _subscriber?.receive(_value!);
    }
    _subscriber?.complete(failure);
    _value = null;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    if (_value == null || latest) {
      _value = input;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(interval, (timer) {
      if (_value != null) {
        _subscriber?.receive(_value!);
        _value = null;
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

class TimeoutPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final Duration interval;
  final Failure Function()? customError;
  Subscriber<Output, Failure>? _subscriber;
  Timer? _timer;

  TimeoutPublisher(this.upstream, this.interval, this.customError);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
    _timer = Timer(interval, () {
      complete(customError?.call());
    });
  }

  @override
  void complete([Failure? failure]) {
    _timer?.cancel();
    _subscriber?.complete(failure);
    _timer = null;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _subscriber?.receive(input);
  }
}
