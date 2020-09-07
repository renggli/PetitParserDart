import '../../core/parser.dart';
import '../combinator/delegate.dart';
import 'unbounded.dart';

/// An abstract parser that repeatedly parses between 'min' and 'max' instances
/// of its delegate.
abstract class RepeatingParser<T> extends DelegateParser<List<T>> {
  final int min;
  final int max;

  RepeatingParser(Parser parser, this.min, this.max) : super(parser) {
    if (min < 0) {
      throw ArgumentError(
          'Minimum repetitions must be positive, but got $min.');
    }
    if (max != unbounded && max < min) {
      throw ArgumentError(
          'Maximum repetitions must be larger than $min, but got $max.');
    }
  }

  @override
  String toString() =>
      '${super.toString()}[$min..${max == unbounded ? '*' : max}]';

  @override
  bool hasEqualProperties(RepeatingParser<T> other) =>
      super.hasEqualProperties(other) && min == other.min && max == other.max;
}
