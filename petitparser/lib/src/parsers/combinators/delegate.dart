library petitparser.parsers.combinators.delegate;

import '../../core/contexts/context.dart';
import '../../core/contexts/result.dart';
import '../../core/parser.dart';

/// A parser that delegates to another one. Normally users do not need to
/// directly use a delegate parser.
class DelegateParser<T> extends Parser<T> {
  Parser delegate;

  DelegateParser(this.delegate)
      : assert(delegate != null, 'delegate must not be null');

  @override
  Result<T> parseOn(Context context) => delegate.parseOn(context);

  @override
  List<Parser> get children => [delegate];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (delegate == source) {
      delegate = target;
    }
  }

  @override
  DelegateParser<T> copy() => DelegateParser<T>(delegate);
}