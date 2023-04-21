import '../publisher.dart';
import '../subscriber.dart';
import '../cancellable.dart';
import 'sink.dart';

extension PublisherSequence<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  FirstSequencePublisher<Output, Failure> first(
          [bool Function(Output)? predicate]) =>
      FirstSequencePublisher<Output, Failure>(this, predicate);

  LastSequencePublisher<Output, Failure> last(
          [bool Function(Output)? predicate]) =>
      LastSequencePublisher<Output, Failure>(this, predicate);

  DropFirstPublisher<Output, Failure> dropFirst([int count = 1]) =>
      DropFirstPublisher<Output, Failure>(this, count);

  DropWhilePublisher<Output, Failure> dropWhile(
          bool Function(Output) predicate) =>
      DropWhilePublisher<Output, Failure>(this, predicate);

  DropUntilOutputPublisher<Output, Failure> dropUntilOutput(
          Publisher<dynamic, Failure> form) =>
      DropUntilOutputPublisher<Output, Failure>(this, form);

  PrefixWhilePublisher<Output, Failure> prefixWhile(
          bool Function(Output) predicate) =>
      PrefixWhilePublisher<Output, Failure>(this, predicate);

  PrefixUntilOutputPublisher<Output, Failure> prefixUntilOutput(
          Publisher<dynamic, Failure> form) =>
      PrefixUntilOutputPublisher<Output, Failure>(this, form);

  OutputPublisher<Output, Failure> output({int? start, required int end}) =>
      OutputPublisher<Output, Failure>(this, start ?? 0, end);

  ConcatenatePublisher<Output, Failure> prepend(
          Publisher<Output, Failure> publisher) =>
      ConcatenatePublisher<Output, Failure>(publisher, this);

  ConcatenatePublisher<Output, Failure> append(
          Publisher<Output, Failure> publisher) =>
      ConcatenatePublisher<Output, Failure>(this, publisher);
}

class FirstSequencePublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final bool Function(Output)? predicate;
  Subscriber<Output, Failure>? _subscriber;

  FirstSequencePublisher(this.upstream, this.predicate);

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
    if (predicate != null) {
      if (predicate!.call(input)) {
        _subscriber?.receive(input);
        complete();
      }
    } else {
      _subscriber?.receive(input);
      complete();
    }
  }
}

class LastSequencePublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final bool Function(Output)? predicate;
  Subscriber<Output, Failure>? _subscriber;
  Output? _value;

  LastSequencePublisher(this.upstream, this.predicate);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    if (failure == null && _value != null) {
      _subscriber?.receive(_value!);
    }
    _subscriber?.complete(failure);
    _value = null;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    if (predicate != null) {
      if (predicate!.call(input)) {
        _value = input;
      }
    } else {
      _value = input;
    }
  }
}

class DropFirstPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final int count;
  int _step = 1;
  Subscriber<Output, Failure>? _subscriber;

  DropFirstPublisher(this.upstream, this.count);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _step = 1;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    if (_step <= count) {
      _step++;
    } else {
      _subscriber?.receive(input);
    }
  }
}

class DropWhilePublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final bool Function(Output) predicate;
  Subscriber<Output, Failure>? _subscriber;
  bool _isDrop = false;

  DropWhilePublisher(this.upstream, this.predicate);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _isDrop = false;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    if (!predicate.call(input)) {
      _isDrop = true;
    }
    if (_isDrop) {
      _subscriber?.receive(input);
    }
  }
}

class PrefixWhilePublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final bool Function(Output) predicate;
  Subscriber<Output, Failure>? _subscriber;

  PrefixWhilePublisher(this.upstream, this.predicate);

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
    if (!predicate.call(input)) {
      complete();
    } else {
      _subscriber?.receive(input);
    }
  }
}

class DropUntilOutputPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final Publisher<dynamic, Failure> from;
  Subscriber<Output, Failure>? _subscriber;
  Cancellable? _cancellable;
  bool _isSend = false;

  DropUntilOutputPublisher(this.upstream, this.from);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
    _cancellable = from.sink((value) {
      _isSend = true;
    });
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _isSend = false;
    _subscriber = null;
    _cancellable?.cancel();
    _cancellable = null;
  }

  @override
  void receive(Output input) {
    if (_isSend) {
      _subscriber?.receive(input);
    }
  }
}

class PrefixUntilOutputPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final Publisher<dynamic, Failure> from;
  Subscriber<Output, Failure>? _subscriber;
  Cancellable? _cancellable;
  bool _isSend = false;

  PrefixUntilOutputPublisher(this.upstream, this.from);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
    _cancellable = from.sink((value) {
      _isSend = true;
    });
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _isSend = false;
    _subscriber = null;
    _cancellable?.cancel();
    _cancellable = null;
  }

  @override
  void receive(Output input) {
    if (_isSend) {
      complete();
    } else {
      _subscriber?.receive(input);
    }
  }
}

class OutputPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final int start;
  final int end;
  int _index = 0;
  Subscriber<Output, Failure>? _subscriber;

  OutputPublisher(this.upstream, this.start, this.end);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _index = 0;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    if (_index >= start && _index < end) {
      _subscriber?.receive(input);
      _index++;
    } else {
      complete();
    }
  }
}

class ConcatenatePublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> prefix;
  final Publisher<Output, Failure> suffix;
  Subscriber<Output, Failure>? _subscriber;
  bool _fromPrefix = true;

  ConcatenatePublisher(this.prefix, this.suffix);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    prefix.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    if (_fromPrefix) {
      _fromPrefix = false;
      suffix.subscribe(this);
    } else {
      _subscriber?.complete(failure);
      _subscriber = null;
    }
  }

  @override
  void receive(Output input) {
    _subscriber?.receive(input);
  }
}
