import '../publisher.dart';
import '../subscriber.dart';
import '../tuple.dart';
import '../cancellable.dart';
import 'sink.dart';
import 'map.dart';

extension PublisherCombineLatest<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  CombineLatestPublisher<E, Output, Failure> combineLatest<E>(
          Publisher<E, Failure> other) =>
      CombineLatestPublisher<E, Output, Failure>(this, other);

  MapPublisher<T, Tuple2<Output, E>, Failure> combineLatestWith<T, E>(
          Publisher<E, Failure> other, T Function(Output, E) transform) =>
      combineLatest<E>(other).map((e) => transform.call(e.v1, e.v2));

  CombineLatestPublisher3<E, Q, Output, Failure> combineLatest2<E, Q>(
          Publisher<E, Failure> v1, Publisher<Q, Failure> v2) =>
      CombineLatestPublisher3<E, Q, Output, Failure>(this, v1, v2);

  MapPublisher<T, Tuple3<Output, E, Q>, Failure> combineLatest2With<T, E, Q>(
          Publisher<E, Failure> v1,
          Publisher<Q, Failure> v2,
          T Function(Output, E, Q) transform) =>
      combineLatest2<E, Q>(v1, v2).map((e) => transform.call(e.v1, e.v2, e.v3));

  CombineLatestPublisher4<E, Q, R, Output, Failure> combineLatest3<E, Q, R>(
          Publisher<E, Failure> v1,
          Publisher<Q, Failure> v2,
          Publisher<R, Failure> v3) =>
      CombineLatestPublisher4<E, Q, R, Output, Failure>(this, v1, v2, v3);

  MapPublisher<T, Tuple4<Output, E, Q, R>, Failure>
      combineLatest3With<T, E, Q, R>(
              Publisher<E, Failure> v1,
              Publisher<Q, Failure> v2,
              Publisher<R, Failure> v3,
              T Function(Output, E, Q, R) transform) =>
          combineLatest3<E, Q, R>(v1, v2, v3)
              .map((e) => transform.call(e.v1, e.v2, e.v3, e.v4));
}

class CombineLatestPublisher<E, Output, Failure extends Error>
    implements
        Publisher<Tuple2<Output, E>, Failure>,
        Subscriber<Output, Failure> {
  final Publisher<Output, Failure> a;
  final Publisher<E, Failure> b;
  Subscriber<Tuple2<Output, E>, Failure>? _subscriber;
  Output? _aLatest;
  E? _bLatest;
  Cancellable? _bCancellable;

  CombineLatestPublisher(this.a, this.b);

  @override
  void subscribe(Subscriber<Tuple2<Output, E>, Failure> subscriber) {
    _subscriber = subscriber;
    a.subscribe(this);
    _bCancellable = b.sink((value) {
      _bLatest = value;
      _send();
    }, onCompletion: (failure) {
      complete(failure);
    });
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _bCancellable?.cancel();
    _bCancellable = null;
    _aLatest = null;
    _bLatest = null;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _aLatest = input;
    _send();
  }

  void _send() {
    if (_aLatest != null && _bLatest != null) {
      _subscriber?.receive(Tuple2<Output, E>(_aLatest!, _bLatest!));
    }
  }
}

class CombineLatestPublisher3<E, Q, Output, Failure extends Error>
    implements
        Publisher<Tuple3<Output, E, Q>, Failure>,
        Subscriber<Output, Failure> {
  final Publisher<Output, Failure> a;
  final Publisher<E, Failure> b;
  final Publisher<Q, Failure> c;
  Subscriber<Tuple3<Output, E, Q>, Failure>? _subscriber;
  Output? _aLatest;
  E? _bLatest;
  Q? _cLatest;
  Cancellable? _bCancellable;
  Cancellable? _cCancellable;

  CombineLatestPublisher3(this.a, this.b, this.c);

  @override
  void subscribe(Subscriber<Tuple3<Output, E, Q>, Failure> subscriber) {
    _subscriber = subscriber;
    a.subscribe(this);
    _bCancellable = b.sink((value) {
      _bLatest = value;
      _send();
    }, onCompletion: (failure) {
      complete(failure);
    });
    _cCancellable = c.sink((value) {
      _cLatest = value;
      _send();
    }, onCompletion: (failure) {
      complete(failure);
    });
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _bCancellable?.cancel();
    _bCancellable = null;
    _cCancellable?.cancel();
    _cCancellable = null;
    _aLatest = null;
    _bLatest = null;
    _cLatest = null;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _aLatest = input;
    _send();
  }

  void _send() {
    if (_aLatest != null && _bLatest != null && _cLatest != null) {
      _subscriber
          ?.receive(Tuple3<Output, E, Q>(_aLatest!, _bLatest!, _cLatest!));
    }
  }
}

class CombineLatestPublisher4<E, Q, R, Output, Failure extends Error>
    implements
        Publisher<Tuple4<Output, E, Q, R>, Failure>,
        Subscriber<Output, Failure> {
  final Publisher<Output, Failure> a;
  final Publisher<E, Failure> b;
  final Publisher<Q, Failure> c;
  final Publisher<R, Failure> d;
  Subscriber<Tuple4<Output, E, Q, R>, Failure>? _subscriber;
  Output? _aLatest;
  E? _bLatest;
  Q? _cLatest;
  R? _dLatest;
  Cancellable? _bCancellable;
  Cancellable? _cCancellable;
  Cancellable? _dCancellable;

  CombineLatestPublisher4(this.a, this.b, this.c, this.d);

  @override
  void subscribe(Subscriber<Tuple4<Output, E, Q, R>, Failure> subscriber) {
    _subscriber = subscriber;
    a.subscribe(this);
    _bCancellable = b.sink((value) {
      _bLatest = value;
      _send();
    }, onCompletion: (failure) {
      complete(failure);
    });
    _cCancellable = c.sink((value) {
      _cLatest = value;
      _send();
    }, onCompletion: (failure) {
      complete(failure);
    });
    _dCancellable = d.sink((value) {
      _dLatest = value;
      _send();
    }, onCompletion: (failure) {
      complete(failure);
    });
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _bCancellable?.cancel();
    _bCancellable = null;
    _cCancellable?.cancel();
    _cCancellable = null;
    _dCancellable?.cancel();
    _dCancellable = null;
    _aLatest = null;
    _bLatest = null;
    _cLatest = null;
    _dLatest = null;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _aLatest = input;
    _send();
  }

  void _send() {
    if (_aLatest != null &&
        _bLatest != null &&
        _cLatest != null &&
        _dLatest != null) {
      _subscriber?.receive(
          Tuple4<Output, E, Q, R>(_aLatest!, _bLatest!, _cLatest!, _dLatest!));
    }
  }
}
