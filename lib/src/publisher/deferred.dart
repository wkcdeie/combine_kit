import '../subscriber.dart';
import '../publisher.dart';

class Deferred<Output, Failure extends Error>
    extends Publisher<Output, Failure> {
  final Publisher<Output, Failure> Function() createPublisher;

  Deferred(this.createPublisher);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    final publisher = createPublisher.call();
    publisher.subscribe(subscriber);
  }
}
