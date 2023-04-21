class Tuple2<T1, T2> {
  final T1 v1;
  final T2 v2;

  Tuple2(this.v1, this.v2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple2 &&
          runtimeType == other.runtimeType &&
          v1 == other.v1 &&
          v2 == other.v2;

  @override
  int get hashCode => v1.hashCode ^ v2.hashCode;

  @override
  String toString() {
    return '($v1, $v2)';
  }
}

class Tuple3<T1, T2, T3> {
  final T1 v1;
  final T2 v2;
  final T3 v3;

  Tuple3(this.v1, this.v2, this.v3);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple3 &&
          runtimeType == other.runtimeType &&
          v1 == other.v1 &&
          v2 == other.v2 &&
          v3 == other.v3;

  @override
  int get hashCode => v1.hashCode ^ v2.hashCode ^ v3.hashCode;

  @override
  String toString() {
    return '($v1, $v2, $v3)';
  }
}

class Tuple4<T1, T2, T3, T4> {
  final T1 v1;
  final T2 v2;
  final T3 v3;
  final T4 v4;

  Tuple4(this.v1, this.v2, this.v3, this.v4);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple4 &&
          runtimeType == other.runtimeType &&
          v1 == other.v1 &&
          v2 == other.v2 &&
          v3 == other.v3 &&
          v4 == other.v4;

  @override
  int get hashCode => v1.hashCode ^ v2.hashCode ^ v3.hashCode ^ v4.hashCode;

  @override
  String toString() {
    return '($v1, $v2, $v3, $v4)';
  }
}
