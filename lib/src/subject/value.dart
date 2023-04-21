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
    _value = value;
    super.send(value);
  }

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    final isSend = !isComplete && subscribers.isEmpty;
    super.subscribe(subscriber);
    if (isSend) {
      super.send(value);
    }
  }
}
