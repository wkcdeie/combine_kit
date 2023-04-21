import '../subject/value.dart';
import '../publisher/sequence.dart';
import '../tuple.dart';

extension StringPublisher on String {
  CurrentValueSubject<String, Never> get publisher =>
      CurrentValueSubject<String, Never>(this);
}

extension IntPublisher on int {
  CurrentValueSubject<int, Never> get publisher =>
      CurrentValueSubject<int, Never>(this);
}

extension DoublePublisher on double {
  CurrentValueSubject<double, Never> get publisher =>
      CurrentValueSubject<double, Never>(this);
}

extension BoolPublisher on bool {
  CurrentValueSubject<bool, Never> get publisher =>
      CurrentValueSubject<bool, Never>(this);
}

extension DateTimePublisher on DateTime {
  CurrentValueSubject<DateTime, Never> get publisher =>
      CurrentValueSubject<DateTime, Never>(this);
}

extension DurationPublisher on Duration {
  CurrentValueSubject<Duration, Never> get publisher =>
      CurrentValueSubject<Duration, Never>(this);
}

extension BigIntPublisher on BigInt {
  CurrentValueSubject<BigInt, Never> get publisher =>
      CurrentValueSubject<BigInt, Never>(this);
}

extension EnumPublisher on Enum {
  CurrentValueSubject<Enum, Never> get publisher =>
      CurrentValueSubject<Enum, Never>(this);
}

extension IterablePublisher<T> on Iterable<T> {
  Sequence<T, Never> get publisher => Sequence<T, Never>(this);
}

extension DictionaryPublisher<K, V> on Map<K, V> {
  Sequence<Tuple2<K, V>, Never> get publisher => Sequence<Tuple2<K, V>, Never>(
      entries.map((e) => Tuple2<K, V>(e.key, e.value)));
}
