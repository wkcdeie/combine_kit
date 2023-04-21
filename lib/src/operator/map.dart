import '../publisher.dart';
import '../subscriber.dart';
import '../cancellable.dart';
import 'sink.dart';

extension PublisherMap<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  ScanPublisher<T, Output, Failure> scan<T>(
          T initial, T Function(T, Output) nextPartial) =>
      ScanPublisher<T, Output, Failure>(initial, this, nextPartial);

  MapPublisher<T, Output, Failure> map<T>(T Function(Output) transform) =>
      MapPublisher<T, Output, Failure>(this, transform);

  FlatMapPublisher<P, Output, Failure> flatMap<P>(
          Publisher<P, Failure> Function(Output) transform) =>
      FlatMapPublisher<P, Output, Failure>(this, transform);
}

class MapPublisher<T, Output, Failure extends Error>
    implements Publisher<T, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final T Function(Output) transform;
  Subscriber<T, Failure>? _subscriber;

  MapPublisher(this.upstream, this.transform);

  @override
  void subscribe(Subscriber<T, Failure> subscriber) {
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
    _subscriber?.receive(transform.call(input));
  }
}

class FlatMapPublisher<P, Output, Failure extends Error>
    implements Publisher<P, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final Publisher<P, Failure> Function(Output) transform;
  Subscriber<P, Failure>? _subscriber;
  Cancellable? _cancellable;

  FlatMapPublisher(this.upstream, this.transform);

  @override
  void subscribe(Subscriber<P, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _cancellable?.cancel();
    _cancellable = null;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    final publisher = transform.call(input);
    _cancellable = publisher.sink((value) {
      _subscriber?.receive(value);
    });
  }
}

class ScanPublisher<T, Output, Failure extends Error>
    implements Publisher<T, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final T Function(T, Output) nextPartial;
  T _value;
  Subscriber<T, Failure>? _subscriber;

  ScanPublisher(this._value, this.upstream, this.nextPartial);

  @override
  void subscribe(Subscriber<T, Failure> subscriber) {
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
    _value = nextPartial.call(_value, input);
    _subscriber?.receive(_value);
  }
}
