import '../publisher.dart';
import '../subscriber.dart';
import '../tuple.dart';
import '../cancellable.dart';
import 'sink.dart';
import 'map.dart';

extension PublisherZip<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  ZipPublisher<E, Output, Failure> zip<E>(Publisher<E, Failure> other) =>
      ZipPublisher<E, Output, Failure>(this, other);

  MapPublisher<T, Tuple2<Output, E>, Failure> zipWith<T, E>(
          Publisher<E, Failure> other, T Function(Output, E) transform) =>
      zip<E>(other).map((e) => transform.call(e.v1, e.v2));

  ZipPublisher3<E, Q, Output, Failure> zip3<E, Q>(
          Publisher<E, Failure> v1, Publisher<Q, Failure> v2) =>
      ZipPublisher3<E, Q, Output, Failure>(this, v1, v2);

  MapPublisher<T, Tuple3<Output, E, Q>, Failure> zip3With<T, E, Q>(
          Publisher<E, Failure> v1,
          Publisher<Q, Failure> v2,
          T Function(Output, E, Q) transform) =>
      zip3<E, Q>(v1, v2).map((e) => transform.call(e.v1, e.v2, e.v3));

  ZipPublisher4<E, Q, R, Output, Failure> zip4<E, Q, R>(
          Publisher<E, Failure> v1,
          Publisher<Q, Failure> v2,
          Publisher<R, Failure> v3) =>
      ZipPublisher4<E, Q, R, Output, Failure>(this, v1, v2, v3);

  MapPublisher<T, Tuple4<Output, E, Q, R>, Failure> zip4With<T, E, Q, R>(
          Publisher<E, Failure> v1,
          Publisher<Q, Failure> v2,
          Publisher<R, Failure> v3,
          T Function(Output, E, Q, R) transform) =>
      zip4<E, Q, R>(v1, v2, v3)
          .map((e) => transform.call(e.v1, e.v2, e.v3, e.v4));
}

class ZipPublisher<E, Output, Failure extends Error>
    implements
        Publisher<Tuple2<Output, E>, Failure>,
        Subscriber<Output, Failure> {
  final Publisher<Output, Failure> a;
  final Publisher<E, Failure> b;
  Subscriber<Tuple2<Output, E>, Failure>? _subscriber;
  Output? _aLatest;
  E? _bLatest;
  Cancellable? _bCancellable;

  ZipPublisher(this.a, this.b);

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
      _aLatest = null;
      _bLatest = null;
    }
  }
}

class ZipPublisher3<E, Q, Output, Failure extends Error>
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

  ZipPublisher3(this.a, this.b, this.c);

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
      _aLatest = null;
      _bLatest = null;
      _cLatest = null;
    }
  }
}

class ZipPublisher4<E, Q, R, Output, Failure extends Error>
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

  ZipPublisher4(this.a, this.b, this.c, this.d);

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
      _aLatest = null;
      _bLatest = null;
      _cLatest = null;
      _dLatest = null;
    }
  }
}
