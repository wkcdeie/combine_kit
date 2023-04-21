import '../publisher.dart';
import '../subscriber.dart';

class Empty<Output, Failure extends Error> extends Publisher<Output, Failure> {
  final bool completeImmediately;

  Empty([this.completeImmediately = true]);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    if (completeImmediately) {
      subscriber.complete();
    }
  }
}
