import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';
import '../utils/types.dart';

extension WhereParserExtension<T> on Parser<T> {
  /// Returns a parser that evaluates the [predicate] with the successful
  /// parse result. If the predicate returns `true` the parser proceeds with
  /// the parse result, otherwise a parse failure is created using the
  /// optionally specified [failureMessage] and [failurePosition] callbacks.
  ///
  /// The function [failureMessage] receives the parse result and is expected
  /// to return an error string of the failed predicate. If no function is
  /// specified a default error message is created.
  ///
  /// Similarly, the [failurePosition] receives the parse result and is
  /// expected to return the position of the error of the failed predicate. If
  /// no function is specified the parser fails at the beginning of the
  /// delegate.
  ///
  /// The following example parses two digits, but only succeeds if the two
  /// numbers match:
  ///
  ///     final inner = digit() & digit();
  ///     final parser = inner.where(
  ///         (value) => value[0] == value[1],
  ///         failureMessage: (value) => 'digits do not match');
  ///     parser.parse('11');   // ==> Success: ['1', '1']
  ///     parser.parse('12');   // ==> Failure: digits do not match
  ///
  Parser<T> where(Predicate<T> predicate,
          {Callback<T, String>? failureMessage,
          Callback<T, int>? failurePosition}) =>
      WhereParser<T>(this, predicate, failureMessage, failurePosition);
}

class WhereParser<T> extends DelegateParser<T, T> {
  final Predicate<T> predicate;
  final Callback<T, String>? failureMessage;
  final Callback<T, int>? failurePosition;

  WhereParser(Parser<T> parser, this.predicate, this.failureMessage,
      this.failurePosition)
      : super(parser);

  @override
  Result<T> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      final value = result.value;
      if (!predicate(value)) {
        return context.failure(
            failureMessage?.call(value) ?? 'unexpected "$value"',
            failurePosition?.call(value));
      }
    }
    return result;
  }

  @override
  Parser<T> copy() =>
      WhereParser<T>(delegate, predicate, failureMessage, failurePosition);

  @override
  bool hasEqualProperties(WhereParser<T> other) =>
      super.hasEqualProperties(other) &&
      predicate == other.predicate &&
      failureMessage == other.failureMessage &&
      failurePosition == other.failurePosition;
}
