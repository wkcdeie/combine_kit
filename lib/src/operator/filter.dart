import '../publisher.dart';
import '../subscriber.dart';
import 'map.dart';

extension PublisherFilter<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  CompactMapPublisher<U, Output, Failure> compactMap<U>(
          U? Function(Output) transform) =>
      CompactMapPublisher<U, Output, Failure>(this, transform);

  FilterPublisher<Output, Failure> filter(bool Function(Output) isIncluded) =>
      FilterPublisher<Output, Failure>(this, isIncluded);

  RemoveDuplicatesPublisher<Output, Failure> removeDuplicates(
          [bool Function(Output, Output)? predicate]) =>
      RemoveDuplicatesPublisher<Output, Failure>(
          this, predicate ?? (a, b) => a == b);

  MapPublisher<Output, Output, Failure> replaceNull(Output output) =>
      map((p0) => p0 ?? output);

  ReplaceErrorPublisher<Output, Failure> replaceError(Output output) =>
      ReplaceErrorPublisher<Output, Failure>(this, output);

  ReplaceEmptyPublisher<Output, Failure> replaceEmpty(Output output) =>
      ReplaceEmptyPublisher<Output, Failure>(this, output);
}

class CompactMapPublisher<U, Output, Failure extends Error>
    implements Publisher<U, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final U? Function(Output) transform;
  Subscriber<U, Failure>? _subscriber;

  CompactMapPublisher(this.upstream, this.transform);

  @override
  void subscribe(Subscriber<U, Failure> subscriber) {
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
    final value = transform.call(input);
    if (value != null) {
      _subscriber?.receive(value);
    }
  }
}

class FilterPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final bool Function(Output) isIncluded;
  Subscriber<Output, Failure>? _subscriber;

  FilterPublisher(this.upstream, this.isIncluded);

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
    if (isIncluded.call(input)) {
      _subscriber?.receive(input);
    }
  }
}

class RemoveDuplicatesPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final bool Function(Output, Output) predicate;
  Subscriber<Output, Failure>? _subscriber;
  Output? _currentValue;

  RemoveDuplicatesPublisher(this.upstream, this.predicate);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _currentValue = null;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    if (_currentValue != null && predicate(_currentValue!, input)) {
      return;
    }
    _currentValue = input;
    _subscriber?.receive(input);
  }
}

class ReplaceErrorPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final Output output;
  Subscriber<Output, Failure>? _subscriber;

  ReplaceErrorPublisher(this.upstream, this.output);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    if (failure != null) {
      _subscriber?.receive(output);
    }
    _subscriber?.complete();
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _subscriber?.receive(input);
  }
}

class ReplaceEmptyPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final Output output;
  Subscriber<Output, Failure>? _subscriber;
  bool _hasData = false;

  ReplaceEmptyPublisher(this.upstream, this.output);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    if (failure == null && !_hasData) {
      _subscriber?.receive(output);
    }
    _subscriber?.complete();
    _hasData = false;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _hasData = true;
    _subscriber?.receive(input);
  }
}
