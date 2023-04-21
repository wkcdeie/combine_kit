# combine_kit

[![Pub](https://img.shields.io/pub/v/combine_kit.svg)](https://pub.dartlang.org/packages/combine_kit)

Customize handling of asynchronous events by combining event-processing operators.

- The `Publisher` protocol declares a type that can deliver a sequence of values over time. Publishers have operators to act on the values received from upstream publishers and republish them.
- At the end of a chain of publishers, a `Subscriber` acts on elements as it receives them. Publishers only emit values when explicitly requested to do so by subscribers. This puts your subscriber code in control of how fast it receives events from the publishers it’s connected to.

## Publisher

- Just
- Empty
- Fail
- Deferred
- AsyncTask
- Record
- Sequence

## Subject

- PassthroughSubject
- CurrentValueSubject

## Operator

- combineLatest(combineLatest2,combineLatest3)
- combineLatestWith(combineLatest2With, combineLatest3With)
- makeConnectable
- allSatisfy
- contains/containsWhere
- debug
- withCatch
- mapError
- compactMap
- filter
- removeDuplicates
- replaceNull
- replaceError
- replaceEmpty
- scan
- map
- flatMap
- max
- min
- count
- merge(merge2,merge3... merge8)
- reduce
- ignoreOutput
- collect
- retry
- first
- last
- dropFirst
- dropWhile
- dropUntilOutput
- prefixWhile
- prefixUntilOutput
- output
- prepend
- append
- switchToLatest
- debounce
- delay
- throttle
- timeout
- zip(zip3,zip4)
- zipWith(zip3With, zip4With)

## Usage

```dart
final subject = PassthroughSubject<int, Never>();
final cancellable = subject.sink((value) {
    print("sink:${value}");
});
// cancellable.cancel();
subject.send(1);
subject.send(2);
subject.complete();
// or
// subject.complete(MyError());
```

## References

- [Apple Combine](https://developer.apple.com/documentation/combine)
