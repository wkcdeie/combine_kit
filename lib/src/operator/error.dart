import '../publisher.dart';
import '../subscriber.dart';
import '../cancellable.dart';
import 'sink.dart';

extension PublisherError<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  WithCatchPublisher<Output, Failure> withCatch(
          Publisher<Output, Failure> Function(Failure) handler) =>
      WithCatchPublisher<Output, Failure>(this, handler);

  MapErrorPublisher<E, Output, Failure> mapError<E extends Failure>(
          E Function(Failure) transform) =>
      MapErrorPublisher<E, Output, Failure>(this, transform);
}

class WithCatchPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final Publisher<Output, Failure> Function(Failure) handler;
  Subscriber<Output, Failure>? _subscriber;
  Cancellable? _cancellable;

  WithCatchPublisher(this.upstream, this.handler);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    if (failure != null) {
      final publisher = handler.call(failure);
      _cancellable = publisher.sink(
        (value) {
          _subscriber?.receive(value);
        },
        onCompletion: (err) {
          _onCompletion(err);
        },
      );
    } else {
      _onCompletion(failure);
    }
  }

  @override
  void receive(Output input) {
    _subscriber?.receive(input);
  }

  void _onCompletion([Failure? failure]) {
    _subscriber?.complete(failure);
    _cancellable?.cancel();
    _cancellable = null;
    _subscriber = null;
  }
}

class MapErrorPublisher<E extends Failure, Output, Failure extends Error>
    implements Publisher<Output, E>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final E Function(Failure) transform;
  Subscriber<Output, E>? _subscriber;

  MapErrorPublisher(this.upstream, this.transform);

  @override
  void subscribe(Subscriber<Output, E> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    if (failure != null) {
      _subscriber?.complete(transform.call(failure));
    } else {
      _subscriber?.complete();
    }
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _subscriber?.receive(input);
  }
}
