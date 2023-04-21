import '../publisher.dart';
import '../subscriber.dart';

extension PublisherReduce<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  ReducePublisher<T, Output, Failure> reduce<T>(
          T initial, T Function(T, Output) nextPartial) =>
      ReducePublisher<T, Output, Failure>(initial, this, nextPartial);

  IgnoreOutputPublisher<Output, Failure> ignoreOutput() =>
      IgnoreOutputPublisher<Output, Failure>(this);

  CollectPublisher<Output, Failure> collect([int? count]) =>
      CollectPublisher<Output, Failure>(this, count);
}

class ReducePublisher<T, Output, Failure extends Error>
    implements Publisher<T, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final T Function(T, Output) nextPartial;
  final T initial;
  final List<Output> _values = [];
  Subscriber<T, Failure>? _subscriber;

  ReducePublisher(this.initial, this.upstream, this.nextPartial);

  @override
  void subscribe(Subscriber<T, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    T _value = initial;
    for (var element in _values) {
      _value = nextPartial.call(_value, element);
    }
    _subscriber?.receive(_value);
    _subscriber?.complete(failure);
    _values.clear();
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _values.add(input);
  }
}

class IgnoreOutputPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  Subscriber<Output, Failure>? _subscriber;

  IgnoreOutputPublisher(this.upstream);

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
  void receive(Output input) {}
}

class CollectPublisher<Output, Failure extends Error>
    implements Publisher<List<Output>, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final List<Output> _values = [];
  final int? count;
  Subscriber<List<Output>, Failure>? _subscriber;

  CollectPublisher(this.upstream, this.count);

  @override
  void subscribe(Subscriber<List<Output>, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    if (failure == null && _values.isNotEmpty) {
      _subscriber?.receive(_values);
    }
    _subscriber?.complete(failure);
    _values.clear();
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _values.add(input);
    if (count != null && count! <= _values.length) {
      final sublist = _values.sublist(0, count);
      _subscriber?.receive(sublist);
      _values.removeRange(0, count!);
    }
  }
}
