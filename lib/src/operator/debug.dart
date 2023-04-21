import 'dart:developer' as dev;

import '../publisher.dart';
import '../subscriber.dart';

extension PublisherDebug<Output, Failure extends Error>
    on Publisher<Output, Failure> {
  DebugPublisher<Output, Failure> debug([String name = ""]) =>
      DebugPublisher<Output, Failure>(this, name);
}

class DebugPublisher<Output, Failure extends Error>
    implements Publisher<Output, Failure>, Subscriber<Output, Failure> {
  final Publisher<Output, Failure> upstream;
  final String name;
  Subscriber<Output, Failure>? _subscriber;

  DebugPublisher(this.upstream, this.name);

  @override
  void subscribe(Subscriber<Output, Failure> subscriber) {
    _subscriber = subscriber;
    upstream.subscribe(this);
    dev.log('subscribe: (${upstream.runtimeType})', name: name);
  }

  @override
  void complete([Failure? failure]) {
    _subscriber?.complete(failure);
    _subscriber = null;
    dev.log('receive ${failure ?? 'finished'}', name: name);
  }

  @override
  void receive(Output input) {
    _subscriber?.receive(input);
    dev.log('receive value: ($input)', name: name);
  }
}
