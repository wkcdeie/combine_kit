import '../publisher.dart';
import '../subscriber.dart';
import '../publisher/deferred.dart';

extension DeferredRetry<Output, Failure extends Error>
    on Deferred<Output, Failure> {
  RetryPublisher<Output, Failure> retry(int retries) =>
      RetryPublisher<Output, Failure>(this, retries);
}

class RetryPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Deferred<Output, Failure> upstream;
  final int? retries;
  Subscriber<Output, Failure>? _subscriber;
  int _step = 1;

  RetryPublisher(this.upstream, this.retries);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    if (failure != null) {
      if (retries == null) {
        _onRetry();
      } else if (_step <= retries!) {
        _onRetry();
      } else {
        _subscriber?.complete(failure);
        _step = 1;
        _subscriber = null;
      }
    } else {
      _subscriber?.complete();
      _step = 1;
      _subscriber = null;
    }
  }

  @override
  void receive(Output input) {
    _subscriber?.receive(input);
  }

  void _onRetry() {
    upstream.subscribe(this);
    _step++;
  }
}
