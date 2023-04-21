import 'dart:core';

import '../publisher.dart';
import '../subscriber.dart';

class Just<Output> extends Publisher<Output, Never> {
  final Output _output;

  Just(this._output);

  @override
  void subscribe(Subscriber<Output, Never> subscriber) {
    subscriber.receive(_output);
    subscriber.complete();
  }
}
