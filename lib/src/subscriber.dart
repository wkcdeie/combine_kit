abstract class Subscriber<Input, Failure extends Error> {
  void receive(Input input);

  void complete([Failure? failure]);
}
