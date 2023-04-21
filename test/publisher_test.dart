import 'package:flutter_test/flutter_test.dart';
import 'package:combine_kit/combine_kit.dart';

void main() {
  test('Future', () {
    final task =
        Future.delayed(const Duration(seconds: 2), () => 123).publisher;
    var done = expectAsync0(() {});
    task.sink((value) {
      expect(value, 123);
    }, onCompletion: (reason) {
      expect(reason, isNull);
      done();
    });
  });

  test('Just', () {
    final just = Just(124);
    just.sink((value) {
      expect(value, 124);
    }, onCompletion: (reason) {
      expect(reason, isNull);
    });
  });

  test('Empty', () {
    final empty = Empty();
    empty.sink((value) {
    }, onCompletion: (reason) {
      expect(reason, isNull);
    });
  });

  test('Record', () {
    final record = Record<int, Never>.record((r) {
      r.receive(1);
      r.receive(2);
      r.receive(3);
      r.complete();
    });
    record.sink((value) {
      expect(value, inClosedOpenRange(0, 4));
    }, onCompletion: (reason) {
      expect(reason, isNull);
    });
  });

  test('Sequence', () {
    final sequence = [0, 1, 3].publisher;
    sequence.sink((value) {
      expect(value, inClosedOpenRange(0, 4));
    }, onCompletion: (reason) {
      expect(reason, isNull);
    });
  });
}
