import '../publisher.dart';
import '../subscriber.dart';

abstract class Subject<Output, Failure extends Error>
    extends Publisher<Output, Failure> {
  void send(Output value);

  void complete([Failure? failure]);
}

class AbstractSubject<Output, Failure extends Error>
    extends Subject<Output, Failure> {
  final List<Subscriber<Output, Failure>> _subscribers = [];
  bool _isComplete = false;

  bool get isComplete => _isComplete;

  List<Subscriber<Output, Failure>> get subscribers => _subscribers;

  @override
  void complete([Failure? failure]) {
    if (_isComplete) {
      return;
    }
    _isComplete = true;
    for (var element in _subscribers) {
      element.complete(failure);
    }
    _subscribers.clear();
  }

  @override
  void send(Output value) {
    if (_isComplete) {
      return;
    }
    for (var element in _subscribers) {
      element.receive(value);
    }
  }

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    if (_isComplete) {
      return;
    }
    if (_subscribers.indexWhere((element) => element == subscriber) == -1) {
      _subscribers.add(subscriber);
    }
  }
}
