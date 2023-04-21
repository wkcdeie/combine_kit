import 'subscriber.dart';

abstract class Publisher<Output, Failure extends Error> {
  void subscribe(Subscriber<Output, Failure> subscriber);
}
