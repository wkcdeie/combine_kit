import '../publisher.dart';
import '../subscriber.dart';

extension PublisherMerge<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  MergePublisher<Output, Failure> merge(Publisher<Output, Failure> other) =>
      MergePublisher<Output, Failure>([this, other]);

  MergePublisher<Output, Failure> merge3(
          Publisher<Output, Failure> v1, Publisher<Output, Failure> v2) =>
      MergePublisher<Output, Failure>([this, v1, v2]);

  MergePublisher<Output, Failure> merge4(Publisher<Output, Failure> v1,
          Publisher<Output, Failure> v2, Publisher<Output, Failure> v3) =>
      MergePublisher<Output, Failure>([this, v1, v2, v3]);

  MergePublisher<Output, Failure> merge5(
          Publisher<Output, Failure> v1,
          Publisher<Output, Failure> v2,
          Publisher<Output, Failure> v3,
          Publisher<Output, Failure> v4) =>
      MergePublisher<Output, Failure>([this, v1, v2, v3, v4]);

  MergePublisher<Output, Failure> merge6(
          Publisher<Output, Failure> v1,
          Publisher<Output, Failure> v2,
          Publisher<Output, Failure> v3,
          Publisher<Output, Failure> v4,
          Publisher<Output, Failure> v5) =>
      MergePublisher<Output, Failure>([this, v1, v2, v3, v4, v5]);

  MergePublisher<Output, Failure> merge7(
          Publisher<Output, Failure> v1,
          Publisher<Output, Failure> v2,
          Publisher<Output, Failure> v3,
          Publisher<Output, Failure> v4,
          Publisher<Output, Failure> v5,
          Publisher<Output, Failure> v6) =>
      MergePublisher<Output, Failure>([this, v1, v2, v3, v4, v5, v6]);

  MergePublisher<Output, Failure> merge8(
          Publisher<Output, Failure> v1,
          Publisher<Output, Failure> v2,
          Publisher<Output, Failure> v3,
          Publisher<Output, Failure> v4,
          Publisher<Output, Failure> v5,
          Publisher<Output, Failure> v6,
          Publisher<Output, Failure> v7) =>
      MergePublisher<Output, Failure>([this, v1, v2, v3, v4, v5, v6, v7]);
}

class MergePublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final List<Publisher<Output, Failure>> publishers;
  Subscriber<Output, Failure>? _subscriber;

  MergePublisher(this.publishers);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    for (var element in publishers) {
      element.subscribe(this);
    }
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    publishers.clear();
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _subscriber?.receive(input);
  }
}
