import '../publisher.dart';
import '../subscriber.dart';

extension PublisherComparison<Output extends Comparable, Failure extends Error>
    on Publisher<Output, Failure> {
  ComparisonPublisher<Output, Failure> max() =>
      ComparisonPublisher<Output, Failure>(this, (a, b) => a.compareTo(b));

  ComparisonPublisher<Output, Failure> min() =>
      ComparisonPublisher<Output, Failure>(this, (a, b) => b.compareTo(a));

  CountPublisher<Output, Failure> count() =>
      CountPublisher<Output, Failure>(this);
}

class ComparisonPublisher<Output extends Comparable, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final int Function(Output, Output) areInIncreasingOrder;
  final List<Output> _values = [];
  Subscriber<Output, Failure>? _subscriber;

  ComparisonPublisher(this.upstream, this.areInIncreasingOrder);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    _values.sort(areInIncreasingOrder);
    _subscriber?.receive(_values.last);
    _subscriber?.complete(failure);
    _values.clear();
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _values.add(input);
  }
}

class CountPublisher<Output, Failure extends Error>
    implements Publisher<int, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  int _sum = 0;
  Subscriber<int, Failure>? _subscriber;

  CountPublisher(this.upstream);

  @override
  void subscribe(Subscriber<int, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.receive(_sum);
    _subscriber?.complete(failure);
    _sum = 0;
    _subscriber = null;
  }

  @override
  void receive(Output input) {
    _sum++;
  }
}
