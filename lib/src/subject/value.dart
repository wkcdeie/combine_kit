import 'subject.dart';
import '../subscriber.dart';

class CurrentValueSubject<Output, Failure extends Error>
    extends AbstractSubject<Output, Failure> {
  Output _value;

  Output get value => _value;

  CurrentValueSubject(this._value);

  @override
  void send(Output value) {
    if (isComplete) {
      return;
    }
    if (_value != value) {
      _value = value;
      super.send(value);
    }
  }

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    if (isComplete) {
      return;
    }
    if (subscribers.indexWhere((element) => element == subscriber) == -1) {
      subscribers.add(subscriber);
      subscriber.receive(_value);
    }
  }
}
