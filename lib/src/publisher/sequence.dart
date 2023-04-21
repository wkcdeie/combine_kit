import '../publisher.dart';
import '../subscriber.dart';

class Sequence<Output, Failure extends Error>
    extends Publisher<Output, Failure> {
  final Iterable<Output> sequence;

  Sequence(this.sequence);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    for (var element in sequence) {
      subscriber.receive(element);
    }
    subscriber.complete();
  }
}
