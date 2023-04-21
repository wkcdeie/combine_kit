import '../publisher.dart';
import '../subscriber.dart';
import '../cancellable.dart';

typedef ReceiveCallback<T> = void Function(T value);
typedef CompletionCallback<Failure> = void Function(Failure? error);

extension PublisherSink<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  Cancellable sink(ReceiveCallback<Output> onReceive,
      {CompletionCallback<Failure>? onCompletion}) {
    final subscriber =
        SinkSubscriber<Output, Failure>(onReceive, onCompletion: onCompletion);
    subscribe(subscriber);
    return subscriber;
  }
}

class SinkSubscriber<Input, Failure extends Error>
    extends Subscriber<Input, Failure> implements Cancellable {
  final ReceiveCallback<Input> onReceive;
  final CompletionCallback<Failure>? onCompletion;
  bool _isCancel = false;

  bool get isCancel => _isCancel;

  SinkSubscriber(this.onReceive, {this.onCompletion});

  @override
  void complete([Failure? failure]) {
    if (_isCancel) {
      return;
    }
    onCompletion?.call(failure);
  }

  @override
  void receive(Input input) {
    if (_isCancel) {
      return;
    }
    onReceive.call(input);
  }

  @override
  void cancel() {
    _isCancel = true;
  }
}
