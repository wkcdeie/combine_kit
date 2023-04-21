import 'package:flutter/widgets.dart';
import '../publisher.dart';
import '../cancellable.dart';
import '../operator/sink.dart';

typedef ObserverWidgetBuilder<T> = Widget Function(
    BuildContext context, T value);

class ObserverBuilder<T> extends StatefulWidget {
  final Publisher<T, Error> publisher;
  final ObserverWidgetBuilder<T> builder;
  final Widget? placeholder;

  const ObserverBuilder(
      {Key? key,
      required this.publisher,
      required this.builder,
      this.placeholder})
      : super(key: key);

  @override
  State<ObserverBuilder<T>> createState() => _ObserverBuilderState<T>();
}

class _ObserverBuilderState<T> extends State<ObserverBuilder<T>> {
  late Cancellable _cancellable;
  T? _value;

  @override
  void initState() {
    super.initState();
    _cancellable = widget.publisher.sink((value) {
      setState(() {
        _value = value;
      });
    });
  }

  @override
  void dispose() {
    _cancellable.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ObserverBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.publisher, oldWidget.publisher)) {
      _cancellable.cancel();
      _cancellable = widget.publisher.sink((value) {
        setState(() {
          _value = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_value == null) {
      return widget.placeholder ?? const SizedBox.shrink();
    }
    return widget.builder.call(context, _value!);
  }
}
