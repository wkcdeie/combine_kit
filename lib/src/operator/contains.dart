import '../publisher.dart';
import '../subscriber.dart';

extension PublisherContains<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  AllSatisfyPublisher<Output, Failure> allSatisfy(
          bool Function(Output) predicate) =>
      AllSatisfyPublisher<Output, Failure>(this, predicate);

  ContainsPublisher<Output, Failure> contains(Output output) =>
      containsWhere((p0) => p0 == output);

  ContainsPublisher<Output, Failure> containsWhere(
          bool Function(Output) predicate) =>
      ContainsPublisher<Output, Failure>(this, predicate);
}

class AllSatisfyPublisher<Output, Failure extends Error>
    implements Publisher<bool, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final bool Function(Output) predicate;
  Subscriber<bool, Failure>? _subscriber;

  AllSatisfyPublisher(this.upstream, this.predicate);

  @override
  void subscribe(Subscriber<bool, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    if (failure == null) {
      _subscriber?.receive(true);
    }
    _sendCompletion(failure);
  }

  @override
  void receive(Output input) {
    if (!predicate.call(input)) {
      _subscriber?.receive(false);
      _sendCompletion();
    }
  }

  void _sendCompletion([Failure? failure]) {
    _subscriber?.complete(failure);
    _subscriber = null;
  }
}

class ContainsPublisher<Output, Failure extends Error>
    implements Publisher<bool, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final bool Function(Output) predicate;
  Subscriber<bool, Failure>? _subscriber;
  bool? _result;

  ContainsPublisher(this.upstream, this.predicate);

  @override
  void subscribe(Subscriber<bool, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    if (failure == null) {
      _subscriber?.receive(_result ?? false);
    }
    _subscriber?.complete(failure);
    _result = false;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    if (_result == null || !_result!) {
      _result = predicate.call(input);
    }
  }
}
