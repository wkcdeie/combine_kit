import '../publisher.dart';
import '../subscriber.dart';

class Recording<Input, Failure> {
  final List<Input> _output;
  Failure? _failure;

  List<Input> get output => _output;

  Failure? get failure => _failure;

  Recording({List<Input>? output, Failure? failure})
      : _output = output ?? List<Input>.empty(growable: true),
        _failure = failure;

  void receive(Input input) {
    output.add(input);
  }

  void complete([Failure? failure]) {
    _failure = failure;
  }
}

class Record<Output, Failure extends Error> extends Publisher<Output, Failure> {
  final Recording<Output, Failure> recording;

  Record(this.recording);

  factory Record.from(List<Output> output, Failure? failure) =>
      Record<Output, Failure>(Recording<Output, Failure>(output: output, failure: failure));

  factory Record.record(void Function(Recording<Output, Failure>) fn) {
    final recording = Recording<Output, Failure>();
    fn.call(recording);
    return Record<Output, Failure>(recording);
  }

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    for (var element in recording.output) {
      subscriber.receive(element);
    }
    subscriber.complete(recording.failure);
  }
}
