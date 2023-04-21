import '../publisher.dart';
import '../subscriber.dart';

class Fail<Output, Failure extends Error> extends Publisher<Output, Failure> {
  final Failure error;

  Fail(this.error);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    subscriber.complete(error);
  }
}
