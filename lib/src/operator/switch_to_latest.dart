import '../publisher.dart';
import '../subscriber.dart';
import '../cancellable.dart';
import 'sink.dart';

extension PublisherSwitchToLatest<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  SwitchToLatestPublisher<P, Output, Failure> switchToLatest<P>() =>
      SwitchToLatestPublisher<P, Output, Failure>(this);
}

class SwitchToLatestPublisher<P, Output, Failure extends Error>
    implements Publisher<P, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  Subscriber<P, Failure>? _subscriber;
  Cancellable? _cancellable;

  SwitchToLatestPublisher(this.upstream);

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
    assert(input is Publisher);
    if (input is Publisher) {
      _cancellable?.cancel();
      final publisher = input as Publisher<P, Failure>;
      _cancellable = publisher.sink(
        (value) {
          _subscriber?.receive(value);
        },
        onCompletion: (err) {
          complete(err);
        },
      );
    }
  }
}
