import '../publisher.dart';
import '../subscriber.dart';
import '../cancellable.dart';

extension PublisherConnect<Output, Failure extends Never>
    on Publisher<Output, Failure> {
  MakeConnectable<Output, Failure> makeConnectable() =>
      MakeConnectable<Output, Failure>(this);
}

abstract class ConnectablePublisher<Output, Failure extends Error>
    extends Publisher<Output, Failure> {
  Cancellable connect();
}

extension AutoConnectablePublisher<Output, Failure extends Error>
    on ConnectablePublisher<Output, Failure> {
  AutoConnectPublisher<Output, Failure> autoConnect() =>
      AutoConnectPublisher<Output, Failure>(this);
}

class MakeConnectable<Output, Failure extends Error>
    implements
        ConnectablePublisher<Output, Failure>,
        Subscriber<Output, Failure>,
        Cancellable {
  final Publisher<Output, Failure> upstream;
  Subscriber<Output, Failure>? _subscriber;

  MakeConnectable(this.upstream);

  @override
  Cancellable connect() {
    upstream.subscribe(this);
    return this;
  }

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _subscriber?.receive(input);
  }

  @override
  void cancel() {
    _subscriber = null;
  }
}

class AutoConnectPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final ConnectablePublisher<Output, Failure> upstream;
  Subscriber<Output, Failure>? _subscriber;
  Cancellable? _cancellable;

  AutoConnectPublisher(this.upstream);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    _cancellable = upstream.connect();
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
    _subscriber?.receive(input);
  }
}
