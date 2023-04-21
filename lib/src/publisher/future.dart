import '../publisher.dart';
import '../subscriber.dart';

class AsyncTask<Output, Failure extends Error>
    extends Publisher<Output, Failure> {
  Subscriber<Output, Failure>? _subscriber;

  AsyncTask(Future<Output> future) {
    future.then((value) {
      _subscriber?.receive(value);
      _subscriber?.complete();
    }).catchError((err) {
      _subscriber?.complete(err);
    });
  }

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
  }
}

extension FuturePublisher<T> on Future<T> {
  AsyncTask<T, Error> get publisher => AsyncTask<T, Error>(this);
}
