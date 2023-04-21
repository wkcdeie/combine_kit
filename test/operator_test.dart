import 'package:flutter_test/flutter_test.dart';
import 'package:combine_kit/combine_kit.dart';

class MyError extends Error {}

void main() {
  test('map', () {
    final p = PassthroughSubject<int, Error>();
    final m = p.map<String>((p0) => "M:$p0");
    m.sink((value) {
      expect(value, startsWith('M'));
    });
    p.send(1);
    p.send(2);
    p.complete();
  });

  test('flatMap', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.flatMap<double>((p0) => Just<double>(p0 * 0.1));
    m.sink((value) {
      expect(value, 0.1);
    });
    p.send(1);
  });

  test('compactMap', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.compactMap((p0) => p0 % 2 == 0 ? null : "M:$p0");
    m.sink((value) {
      expect(value, startsWith('M'));
    });
    p.send(1);
    p.send(34);
    p.send(4);
    p.send(7);
  });

  test('scan', () {
    final p = PassthroughSubject<int, Never>();
    final s = p.scan("::", (p0, p1) => "$p0$p1");
    s.sink((value) {
      expect(value, startsWith('::'));
    });
    p.send(2);
    p.send(7);
  });

  test('reduce', () {
    final p = PassthroughSubject<int, Never>();
    final s = p.reduce<int>(0, (p0, p1) => (p0 + p1).toInt());
    s.sink((value) {
      expect(value, 9);
    });
    p.send(2);
    p.send(7);
    p.complete();
  });

  test('collect', () {
    final p = PassthroughSubject<int, Never>();
    final s = p.collect(2);
    s.sink((value) {
      expect(value, isList);
    });
    p.send(2);
    p.send(7);
    p.send(11);
    // p.complete();
  });

  test('removeDuplicates', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.removeDuplicates();
    m.sink((value) {
      expect(value, inClosedOpenRange(1, 8));
    });
    p.send(1);
    p.send(4);
    p.send(4);
    p.send(7);
    p.send(3);
    p.send(1);
  });

  test('replaceNull', () {
    final p = PassthroughSubject<int?, Never>();
    final m = p.replaceNull(0);
    m.sink((value) {
      expect(value, 0);
    });
    p.send(null);
  });

  test('replaceError', () {
    final p = PassthroughSubject<int?, Error>();
    final m = p.replaceError(0);
    m.sink((value) {
      expect(value, 0);
    });
    p.complete(MyError());
  });

  test('max-min', () {
    final p = PassthroughSubject<int, Never>();
    p.max().sink((value) {
      expect(value, 7);
    });
    p.min().sink((value) {
      expect(value, 1);
    });
    p.send(1);
    p.send(4);
    p.send(7);
    p.send(3);
    p.complete();
  });

  test('count', () {
    final p = ['1', '2', '3', '4'].publisher.count();
    p.sink((value) {
      expect(value, 4);
    });
  });

  test('catch', () {
    final p = PassthroughSubject<String, Error>();
    final m =
        p.withCatch((p0) => CurrentValueSubject<String, Error>("Default"));
    m.sink((value) {
      expect(value, 'Default');
    });
    p.complete(MyError());
  });

  test('Map-Error', () {
    final p = PassthroughSubject<String, Error>();
    final m = p.mapError((p0) => MyError());
    m.sink((value) {
      expect(value, '1');
    }, onCompletion: (err) {
      expect(err, isInstanceOf<MyError>());
    });
    p.send("1");
    p.complete(ArgumentError());
  });

  test('retry', () {
    int c = 0;
    Future<int> _request() async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (c == 1) {
        throw StateError('c=$c');
      }
      c++;
      return c;
    }

    final task = Deferred(() => _request().publisher);
    final m = task.retry(3);
    var done = expectAsync0(() {});
    m.sink((value) {
      expect(value, 1);
    }, onCompletion: (err) {
      expect(err, isNull);
      done();
    });
  });

  test('combineLatest', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.combineLatest<int>(Just(3));
    m.sink((value) {
      expect(value.v1, 1);
      expect(value.v2, 3);
    });
    p.send(1);
    p.complete();
  });

  test('merge', () {
    final p = PassthroughSubject<int, Error>();
    final p2 = PassthroughSubject<int, Error>();
    final m = p.merge(p2);
    m.sink((value) {
      expect(value, inClosedOpenRange(0, 3));
    });
    p.send(1);
    p2.send(2);
  });

  test('zip', () {
    final p = PassthroughSubject<String, Never>();
    final p2 = PassthroughSubject<int, Never>();
    final m = p.zipWith(p2, (p0, p1) => "$p0.$p1");
    m.sink((value) {
      expect(value, '1.2');
    });
    p.send('1');
    p2.send(2);
  });

  test('connect', () {
    final p = PassthroughSubject<String, Never>();
    final m = p.makeConnectable().autoConnect();
    m.sink((value) {
      expect(value, '1');
    });
    p.send('1');
  });

  test('first-sequence', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.first();
    m.sink((value) {
      expect(value, 1);
    }, onCompletion: (err) {
      expect(err, isNull);
    });
    p.send(1);
    p.send(3);
  });

  test('dropWhile', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.dropWhile((p0) => p0 < 2);
    m.sink((value) {
      expect(value, 3);
    });
    p.send(1);
    p.send(0);
    p.send(3);
  });

  test('output', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.output(end: 1);
    m.sink((value) {
      expect(value, 1);
    });
    p.send(1);
    p.send(0);
    p.send(3);
    p.send(4);
  });

  test('prepend', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.prepend([11].publisher);
    List<int> values = [];
    m.sink((value) {
      values.add(value);
    }, onCompletion: (_) {
      expect(values, [11, 3]);
    });
    p.send(3);
    p.complete();
  });

  test('append', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.append([35].publisher);
    List<int> values = [];
    m.sink((value) {
      values.add(value);
    }, onCompletion: (_) {
      expect(values, [0, 35]);
    });
    p.send(0);
    p.complete();
  });

  test('allSatisfy', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.allSatisfy((p0) => p0 > 1);
    m.sink((value) {
      expect(value, true);
    });
    p.send(2);
    p.send(3);
    p.complete();
  });

  test('contains', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.contains(3);
    m.sink((value) {
      expect(value, true);
    });
    p.send(2);
    p.send(3);
    p.complete();
  });

  test('debounce', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.debounce(const Duration(seconds: 3));
    var done = expectAsync0(() {});
    m.sink((value) {
      expect(value, 30);
    }, onCompletion: (_) {
      done();
    });
    p.send(2);
    p.send(21);
    p.send(23);
    p.send(24);
    Future.delayed(const Duration(seconds: 1), () {
      p.send(3);
      p.send(30);
    });
    Future.delayed(const Duration(seconds: 5), () {
      p.send(44);
      p.complete();
    });
  });

  test('delay', () {
    final p = PassthroughSubject<int, Never>();
    final m = p.delay(const Duration(seconds: 3));
    var done = expectAsync0(() {});
    m.sink((value) {
      expect(value, 2);
    }, onCompletion: (_) {
      done();
    });
    p.send(2);
    Future.delayed(const Duration(seconds: 5), () {
      p.complete();
    });
  });

  test('throttle', () {
    final p = PassthroughSubject<int, Error>();
    final m = p.throttle(const Duration(seconds: 1), true);
    var done = expectAsync0(() {});
    m.sink((value) {
      expect(value == 5 || value == 4 || value == 11, true);
    }, onCompletion: (err) {
      done();
    });
    p.send(1);
    p.send(2);
    Future.delayed(const Duration(seconds: 1), () {
      p.send(3);
      p.send(4);
    });
    p.send(5);
    Future.delayed(const Duration(seconds: 5), () {
      p.send(10);
      p.send(11);
      p.complete();
    });
  });

  test('timeout', () {
    final p = PassthroughSubject<int, Error>();
    final m = p
        .timeout(const Duration(seconds: 3) /*, customError: () => MyError()*/);
    var done = expectAsync0(() {});
    m.sink((value) {
      expect(value, 2);
    }, onCompletion: (err) {
      done();
    });
    p.send(2);
  });

  test('switchToLatest', () {
    final p = PassthroughSubject<int, Error>();
    final m = p
        .map((p0) => Deferred(() => Future.delayed(Duration(seconds: p0), () {
              return "t:$p0";
            }).publisher))
        .switchToLatest<String>();
    var done = expectAsync0(() {});
    m.sink((value) {
      expect(value, 't:4');
    }, onCompletion: (err) {
      expect(err, null);
    });
    for (var i = 0; i < 5; i++) {
      p.send(i);
    }
    Future.delayed(const Duration(seconds: 5), () {
      p.complete();
      done();
    });
  });
}
