// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * Dart grammar definition.
 */
class DartGrammar extends CompositeParser {

  void initialize() {
    def('start', ref('compilationUnit').end());
    whitespaces();
    keywords();
    grammar();
  }

  /** Defines the whitespace and comments. */
  void whitespaces() {
    def('whitespace', whitespace()
      .or(ref('singe line comment'))
      .or(ref('multi line comment')));
    def('singe line comment', string('//')
      .seq(Token.newlineParser().neg().star()));
    def('multi line comment', string('/*')
      .seq(string('*/').neg().star())
      .seq(string('*/')));
  }

  /** Define keywords. */
  Parser tok(String value) {
    return string(value).token().trim(ref('whitespace'));
  }

  /** Keyword definitions. */
  void keywords() {
    def('ABSTRACT', tok('abstract'));
    def('ASSERT', tok('assert'));
    def('BREAK', tok('break'));
    def('CASE', tok('case'));
    def('CATCH', tok('catch'));
    def('CLASS', tok('class'));
    def('CONST', tok('const'));
    def('CONTINUE', tok('continue'));
    def('DEFAULT', tok('default'));
    def('DO', tok('do'));
    def('ELSE', tok('else'));
    def('EXTENDS', tok('extends'));
    def('FACTORY', tok('factory'));
    def('FALSE', tok('false'));
    def('FINAL', tok('final'));
    def('FINALLY', tok('finally'));
    def('FOR', tok('for'));
    def('GET', tok('get'));
    def('IF', tok('if'));
    def('IMPLEMENTS', tok('implements'));
    def('IMPORT', tok('import'));
    def('IN', tok('in'));
    def('INTERFACE', tok('interface'));
    def('IS', tok('is'));
    def('LIBRARY', tok('library'));
    def('NATIVE', tok('native'));
    def('NEGATE', tok('negate'));
    def('NEW', tok('new'));
    def('NULL', tok('null'));
    def('OPERATOR', tok('operator'));
    def('RETURN', tok('return'));
    def('SET', tok('set'));
    def('SOURCE', tok('source'));
    def('STATIC', tok('static'));
    def('SUPER', tok('super'));
    def('SWITCH', tok('switch'));
    def('THIS', tok('this'));
    def('THROW', tok('throw'));
    def('TRUE', tok('true'));
    def('TRY', tok('try'));
    def('TYPEDEF', tok('typedef'));
    def('VAR', tok('var'));
    def('VOID', tok('void'));
    def('WHILE', tok('while'));
  }

  /** Rest */
  void grammar() {
    def('compilationUnit', ref('HASHBANG').optional()
      .seq(ref('directive').star())
      .seq(ref('topLevelDefinition').star()));
    def('directive', tok('#')
      .seq(ref('identifier'))
      .seq(ref('arguments'))
      .seq(tok(';')));
    def('topLevelDefinition', ref('classDefinition')
      .or(ref('interfaceDefinition'))
      .or(ref('functionTypeAlias'))
      .or(ref('functionDeclaration')
        .seq(ref('functionBodyOrNative')))
      .or(ref('returnType').optional()
        .seq(ref('getOrSet'))
        .seq(ref('identifier'))
        .seq(ref('formalParameterList'))
        .seq(ref('functionBodyOrNative')))
      .or(ref('FINAL')
        .seq(ref('type').optional())
        .seq(ref('staticFinalDeclarationList'))
        .seq(tok(';')))
      .or(ref('constInitializedVariableDeclaration')
        .seq(tok(';'))));

    def('classDefinition', ref('CLASS')
      .seq(ref('identifier'))
      .seq(ref('typeParameters').optional())
      .seq(ref('superclass').optional())
      .seq(ref('interfaces').optional())
      .seq(tok('{'))
      .seq(ref('classMemberDefinition').star())
      .seq(tok('}')));
    def('typeParameter', ref('identifier')
      .seq(ref('EXTENDS').seq(ref('type')).optional()));
    def('typeParameters', tok('<')
      .seq(ref('typeParameter').separatedBy(tok(',')))
      .seq(tok('>')));
    def('superclass', ref('EXTENDS').seq(ref('type')));
    def('interfaces', ref('IMPLEMENTS').seq(ref('typeList')));
    def('superinterfaces', ref('EXTENDS').seq(ref('typeList')));

    def('classMemberDefinition', ref('declaration').seq(tok(';'))
      .or(ref('constructorDeclaration').seq(tok(';')))
      .or(ref('methodDeclaration').seq(ref('functionBodyOrNative')))
      .or(ref('CONST').seq(ref('factoryConstructorDeclaration')).seq(ref('functionNative'))));
    def('functionBodyOrNative', ref('NATIVE').seq(ref('functionBody'))
      .or(ref('functionNative'))
      .or(ref('functionBody')));
    def('functionNative', ref('NATIVE')
      .seq(ref('STRING').optional())
      .seq(tok(';')));

    /*
// ref('A') method, operator, or constructor (which all should be followed by
// a block of code).
def('methodDeclaration', factoryConstructorDeclaration
   .or(ref('STATIC') functionDeclaration
   .or(specialSignatureDefinition
   .or(functionDeclaration initializers.optional()
   .or(namedConstructorDeclaration initializers.optional()
    ;

// An abstract method/operator, a field, or const constructor (which
// all should be followed by a semicolon).
def('declaration', constantConstructorDeclaration (redirection.or(initializers).optional()
   .or(functionDeclaration redirection
   .or(namedConstructorDeclaration redirection
   .or(ref('ABSTRACT') specialSignatureDefinition
   .or(ref('ABSTRACT') functionDeclaration
   .or(ref('STATIC') ref('FINAL') type.optional() staticFinalDeclarationList
   .or(ref('STATIC').optional() constInitializedVariableDeclaration
    ;

def('initializers', ':' superCallOrFieldInitializer (',' superCallOrFieldInitializer).star()
    ;

def('redirection', ':' ref('THIS') ('.' identifier).optional() arguments
    ;

fieldInitializer
@init { bool old = this._setParseFunctionExpressions(false); }
    : (ref('THIS') '.').optional() identifier '=' conditionalExpression
    ;
finally { this._setParseFunctionExpressions(old); }

def('superCallOrFieldInitializer', ref('SUPER') arguments
   .or(ref('SUPER') '.' identifier arguments
   .or(fieldInitializer
    ;

def('staticFinalDeclarationList', staticFinalDeclaration (',' staticFinalDeclaration).star()
    ;

def('staticFinalDeclaration', identifier '=' constantExpression
    ;

def('interfaceDefinition', ref('INTERFACE') identifier typeParameters.optional() superinterfaces.optional()
      factorySpecification.optional() '{' (interfaceMemberDefinition).star() '}'
    ;

def('factorySpecification', ref('FACTORY') type
   ;

def('functionTypeAlias', ref('TYPEDEF') functionPrefix typeParameters.optional() formalParameterList ';'
    ;

def('interfaceMemberDefinition', ref('STATIC') ref('FINAL') type.optional() initializedIdentifierList ';'
   .or(functionDeclaration ';'
   .or(constantConstructorDeclaration ';'
   .or(namedConstructorDeclaration ';'
   .or(specialSignatureDefinition ';'
   .or(variableDeclaration ';'
    ;

def('factoryConstructorDeclaration', ref('FACTORY') qualified typeParameters.optional() ('.' identifier).optional() formalParameterList
    ;

def('namedConstructorDeclaration', identifier '.' identifier formalParameterList
    ;

def('constructorDeclaration', identifier formalParameterList (redirection.or(initializers).optional()
   .or(namedConstructorDeclaration (redirection.or(initializers).optional()
    ;

def('constantConstructorDeclaration', ref('CONST') qualified formalParameterList
    ;

def('specialSignatureDefinition', ref('STATIC').optional() returnType.optional() getOrSet identifier formalParameterList
   .or(returnType.optional() ref('OPERATOR') userDefinableOperator formalParameterList
    ;

def('getOrSet', ref('GET')
   .or(ref('SET')
    ;

def('userDefinableOperator', multiplicativeOperator
   .or(additiveOperator
   .or(shiftOperator
   .or(relationalOperator
   .or(bitwiseOperator
   .or('=='  // Disallow negative and === equality checks.
   .or('~'   // Disallow ! operator.
   .or(ref('NEGATE')
   .or('[' ']' { '[]' == $text }.optional()
   .or('[' ']' '=' { '[]=' == $text }.optional()
    ;

def('prefixOperator', additiveOperator
   .or(negateOperator
    ;

def('postfixOperator', incrementOperator
    ;

def('negateOperator', '!'
   .or('~'
    ;

def('multiplicativeOperator', '.star()'
   .or('/'
   .or('%'
   .or('~/'
    ;

def('assignmentOperator', '='
   .or('.star()='
   .or('/='
   .or('~/='
   .or('%='
   .or('.plus()='
   .or('-='
   .or('<<='
   .or('>' '>' '>' '=' { '>>>=' == $text }.optional()
   .or('>' '>' '=' { '>>=' == $text }.optional()
   .or('&='
   .or('^='
   .or('|='
    ;

def('additiveOperator', '.plus()'
   .or('-'
    ;

def('incrementOperator', '.plus().plus()'
   .or('--'
    ;

def('shiftOperator', '<<'
   .or('>' '>' '>' { '>>>' == $text }.optional()
   .or('>' '>' { '>>' == $text }.optional()
    ;

def('relationalOperator', '>' '=' { '>=' == $text }.optional()
   .or('>'
   .or('<='
   .or('<'
    ;

def('equalityOperator', '=='
   .or('!='
   .or('==='
   .or('!=='
    ;

def('bitwiseOperator', '&'
   .or('^'
   .or('|'
    ;

def('formalParameterList', '(' namedFormalParameters.optional() ')'
   .or('(' normalFormalParameter normalFormalParameterTail.optional() ')'
    ;

def('normalFormalParameterTail', ',' namedFormalParameters
   .or(',' normalFormalParameter normalFormalParameterTail.optional()
    ;

def('normalFormalParameter', functionDeclaration
   .or(fieldFormalParameter
   .or(simpleFormalParameter
    ;

def('simpleFormalParameter', declaredIdentifier
   .or(identifier
    ;

def('fieldFormalParameter', finalVarOrType.optional() ref('THIS') '.' identifier
   ;

def('namedFormalParameters', '[' defaultFormalParameter (',' defaultFormalParameter).star() ']'
    ;

def('defaultFormalParameter', normalFormalParameter ('=' constantExpression).optional()
    ;

def('returnType', ref('VOID')
   .or(type
    ;

def('finalVarOrType', ref('FINAL') type.optional()
   .or(ref('VAR')
   .or(type
    ;

// We have to introduce a separate rule for 'declared' identifiers to
// allow ref('ANTLR') to decide if the first identifier we encounter after
// final is a type or an identifier. Before this change, we used the
// production 'finalVarOrType identifier' in numerous places.
def('declaredIdentifier', ref('FINAL') type.optional() identifier
   .or(ref('VAR') identifier
   .or(type identifier
    ;

def('identifier', IDENTIFIER_NO_DOLLAR
   .or(ref('IDENTIFIER')
   .or(ref('ABSTRACT')
   .or(ref('ASSERT')
   .or(ref('CLASS')
   .or(ref('EXTENDS')
   .or(ref('FACTORY')
   .or(ref('GET')
   .or(ref('IMPLEMENTS')
   .or(ref('IMPORT')
   .or(ref('INTERFACE')
   .or(ref('IS')
   .or(ref('LIBRARY')
   .or(ref('NATIVE')
   .or(ref('NEGATE')
   .or(ref('OPERATOR')
   .or(ref('SET')
   .or(ref('SOURCE')
   .or(ref('STATIC')
   .or(ref('TYPEDEF')
    ;

def('qualified', identifier ('.' identifier).optional()
    ;

def('type', qualified typeArguments.optional()
    ;

def('typeArguments', '<' typeList '>'
    ;

def('typeList', type (',' type).star()
    ; */

    def('block', tok('{')
      .seq(ref('statements'))
      .seq(tok('}')));
    def('statements', ref('statement').star());
    def('statement', ref('label').star()
      .seq(ref('nonLabelledStatement')));
    def(ref('block')
      .or(ref('initializedVariableDeclaration')
        .seq(tok(';')))
      .or(ref('iterationStatement'))
      .or(ref('selectionStatement'))
      .or(ref('tryStatement'))
      .or(ref('BREAK')
        .seq(ref('identifier').optional())
        .seq(tok(';')))
      .or(ref('CONTINUE')
        .seq(ref('identifier').optional())
        .seq(tok(';')))
      .or(ref('RETURN')
        .seq(ref('identifier').optional())
        .seq(tok(';')))
      .or(ref('THROW')
        .seq(ref('identifier').optional())
        .seq(tok(';')))
      .or(ref('expression').optional()
        .seq(tok(';')))
      .or(ref('ASSERT')
        .seq(tok('('))
        .seq(ref('conditionalExpression'))
        .seq(tok(')'))
        .seq(tok(';')))
      .or(ref('functionDeclaration')
        .seq('functionBody')));
    def('label', ref('identifier').seq(tok(':')));

    // iteration statements
    def('iterationStatement', ref('iterationStatementWhile')
      .or(ref('iterationStatementDo'))
      .or(ref('iterationStatementFor')));
    def('iterationStatementWhile', ref('WHILE')
      .seq(tok('('))
      .seq(ref('expression'))
      .seq(tok(')'))
      .seq(ref('statement')));
    def('iterationStatementDo', ref('DO')
      .seq(ref('statement'))
      .seq(ref('WHILE'))
      .seq(tok('('))
      .seq(ref('expression'))
      .seq(tok(')'))
      .seq(tok(';')));
    def('iterationStatementFor', ref('FOR')
      .seq(tok('('))
      .seq(ref('forLoopParts')
        .or(ref('forLoopIn')))
      .seq(tok(')'))
      .seq(ref('statement'))));
    def('forLoopParts', ref('forInitializerStatement')
      .seq(ref('expression').optional())
      .seq(tok(';'))
      .seq(ref('expressionList').optional()));
    def('forLoopIn', ref('declaredIdentifier')
        .seq(ref('IN'))
        .seq(ref('expression'))
      .or(ref('identifier')
        .seq(ref('IN'))
        .seq(ref('expression'))));
    def('forInitializerStatement', ref('initializedVariableDeclaration').seq(tok(';'))
      .or(ref('expression').optional().seq(tok(';'))));

   /*

def('selectionStatement', ref('IF') '(' expression ')' statement ((ref('ELSE'))=> ref('ELSE') statement).optional()
   .or(ref('SWITCH') '(' expression ')' '{' switchCase.star() defaultCase.optional() '}'
    ;

def('switchCase', label.optional() (ref('CASE') expression ':').plus() statements
    ;

def('defaultCase', label.optional() (ref('CASE') expression ':').star() ref('DEFAULT') ':' statements
    ;

def('tryStatement', ref('TRY') block (catchPart.plus() finallyPart.optional().or(finallyPart)
    ;

def('catchPart', ref('CATCH') '(' declaredIdentifier (',' declaredIdentifier).optional() ')' block
    ;

def('finallyPart', ref('FINALLY') block
    ;

def('variableDeclaration', declaredIdentifier (',' identifier).star()
    ;

def('initializedVariableDeclaration', declaredIdentifier ('=' expression).optional() (',' initializedIdentifier).star()
    ;

def('initializedIdentifierList', initializedIdentifier (',' initializedIdentifier).star()
    ;

def('initializedIdentifier', identifier ('=' expression).optional()
    ;

def('constInitializedVariableDeclaration', declaredIdentifier ('=' constantExpression).optional()
      (',' constInitializedIdentifier).star()
    ;

def('constInitializedIdentifier', identifier ('=' constantExpression).optional()
    ;

// The constant expression production is used to mark certain expressions
// as only being allowed to hold a compile-time constant. The grammar cannot
// express these restrictions (yet), so this will have to be enforced by a
// separate analysis phase.
def('constantExpression', expression
    ;

def('expression', assignableExpression assignmentOperator expression
   .or(conditionalExpression
    ;

def('expressionList', expression (',' expression).star()
    ;

arguments
@init { bool old = this._setParseFunctionExpressions(true); }
    : '(' argumentList.optional() ')'
    ;
finally { this._setParseFunctionExpressions(old); }

def('argumentList', namedArgument (',' namedArgument).star()
   .or(expressionList (',' namedArgument).star()
    ;

def('namedArgument', label expression
    ;

def('assignableExpression', primary (arguments.star() assignableSelector).plus()
   .or(ref('SUPER') assignableSelector
   .or(identifier
    ;

def('conditionalExpression', logicalOrExpression ('.optional()' expression ':' expression).optional()
    ;

def('logicalOrExpression', logicalAndExpression ('||' logicalAndExpression).star()
    ;

def('logicalAndExpression', bitwiseOrExpression ('&&' bitwiseOrExpression).star()
    ;

def('bitwiseOrExpression', bitwiseXorExpression ('|' bitwiseXorExpression).star()
   .or(ref('SUPER') ('|' bitwiseXorExpression).plus()
    ;

def('bitwiseXorExpression', bitwiseAndExpression ('^' bitwiseAndExpression).star()
   .or(ref('SUPER') ('^' bitwiseAndExpression).plus()
    ;

def('bitwiseAndExpression', equalityExpression ('&' equalityExpression).star()
   .or(ref('SUPER') ('&' equalityExpression).plus()
    ;

def('equalityExpression', relationalExpression (equalityOperator relationalExpression).optional()
   .or(ref('SUPER') equalityOperator relationalExpression
    ;

def('relationalExpression', shiftExpression (isOperator type.or(relationalOperator shiftExpression).optional()
   .or(ref('SUPER') relationalOperator shiftExpression
    ;

def('isOperator', ref('IS') '!'.optional()
    ;

def('shiftExpression', additiveExpression (shiftOperator additiveExpression).star()
   .or(ref('SUPER') (shiftOperator additiveExpression).plus()
    ;

def('additiveExpression', multiplicativeExpression (additiveOperator multiplicativeExpression).star()
   .or(ref('SUPER') (additiveOperator multiplicativeExpression).plus()
    ;

def('multiplicativeExpression', unaryExpression (multiplicativeOperator unaryExpression).star()
   .or(ref('SUPER') (multiplicativeOperator unaryExpression).plus()
    ;

def('unaryExpression', postfixExpression
   .or(prefixOperator unaryExpression
   .or(negateOperator ref('SUPER')
   .or('-' ref('SUPER')  // Invokes the ref('NEGATE') operator.
   .or(incrementOperator assignableExpression
    ;

def('postfixExpression', assignableExpression postfixOperator
   .or(primary selector.star()
    ;

def('selector', assignableSelector
   .or(arguments
    ;

assignableSelector
@init { bool old = this._setParseFunctionExpressions(true); }
    : '[' expression ']'
   .or('.' identifier
    ;
finally { this._setParseFunctionExpressions(old); }

def('primary', {!_parseFunctionExpressions}.optional()=> primaryNoFE
   .or(primaryFE
    ;

def('primaryFE', functionExpression
   .or(primaryNoFE
    ;

def('primaryNoFE', ref('THIS')
   .or(ref('SUPER') assignableSelector
   .or(literal
   .or(identifier
   .or(ref('CONST').optional() typeArguments.optional() compoundLiteral
   .or((ref('NEW').or(ref('CONST')) type ('.' identifier).optional() arguments
   .or(expressionInParentheses
    ;

expressionInParentheses
@init { bool old = this._setParseFunctionExpressions(true); }
    :'(' expression ')'
    ;
finally { this._setParseFunctionExpressions(old); }

def('literal', ref('NULL')
   .or(ref('TRUE')
   .or(ref('FALSE')
   .or(HEX_NUMBER
   .or(ref('NUMBER')
   .or(ref('STRING')
    ;

compoundLiteral
@init { bool old = this._setParseFunctionExpressions(true); }
    : listLiteral
   .or(mapLiteral
    ;
finally { this._setParseFunctionExpressions(old); }

// The list literal syntax doesn't allow elided elements, unlike
// in ECMAScript. We do allow a trailing comma.
def('listLiteral', '[' (expressionList ','.optional() ) .optional() ']'
    ;

def('mapLiteral', '{' (mapLiteralEntry (',' mapLiteralEntry).star() ','.optional()).optional() '}'
    ;

def('mapLiteralEntry', ref('STRING') ':' expression
    ;

def('functionExpression', (returnType.optional() identifier).optional() formalParameterList functionExpressionBody
    ;

def('functionDeclaration', returnType.optional() identifier formalParameterList
    ;

def('functionPrefix', returnType.optional() identifier
    ;

def('functionBody', '=>' expression ';'
   .or(block
    ;

def('functionExpressionBody', '=>' expression
   .or(block
    ;

// -----------------------------------------------------------------
// Library files.
// -----------------------------------------------------------------
def('libraryUnit', libraryDefinition ref('EOF')
    ;

def('libraryDefinition', ref('LIBRARY') '{' libraryBody '}'
    ;

def('libraryBody', libraryImport.optional() librarySource.optional()
    ;

def('libraryImport', ref('IMPORT') '=' '[' importReferences.optional() ']'
    ;

def('importReferences', importReference (',' importReference).star() ','.optional()
    ;

def('importReference', (ref('IDENTIFIER') ':').optional() ref('STRING')
    ;

def('librarySource', ref('SOURCE') '=' '[' sourceUrls.optional() ']'
    ;

def('sourceUrls', ref('STRING') (',' ref('STRING')).star() ','.optional()
    ;


// -----------------------------------------------------------------
// Lexical tokens.
// -----------------------------------------------------------------
def('IDENTIFIER_NO_DOLLAR', IDENTIFIER_START_NO_DOLLAR IDENTIFIER_PART_NO_DOLLAR.star()
    ;

def('ref('IDENTIFIER')', IDENTIFIER_START IDENTIFIER_PART.star()
    ;

def('HEX_NUMBER', '0x' HEX_DIGIT.plus()
   .or('0X' HEX_DIGIT.plus()
    ;

def('ref('NUMBER')', ref('DIGIT').plus() NUMBER_OPT_FRACTIONAL_PART ref('EXPONENT').optional() NUMBER_OPT_ILLEGAL_END
   .or('.' ref('DIGIT').plus() ref('EXPONENT').optional() NUMBER_OPT_ILLEGAL_END
    ;

fragment NUMBER_OPT_FRACTIONAL_PART
    : ('.' ref('DIGIT'))=> ('.' ref('DIGIT').plus())
   .or(// Empty fractional part.
    ;

fragment NUMBER_OPT_ILLEGAL_END
    : (IDENTIFIER_START)=> { this._error("numbers cannot contain identifiers"); }
   .or(// Empty illegal end (good!).
    ;

fragment HEX_DIGIT
    : 'a'..'f'
   .or('ref('A')'..'ref('F')'
   .or(ref('DIGIT')
    ;

fragment IDENTIFIER_START
    : IDENTIFIER_START_NO_DOLLAR
   .or('\$'
    ;

fragment IDENTIFIER_START_NO_DOLLAR
    : ref('LETTER')
   .or('_'
    ;

fragment IDENTIFIER_PART_NO_DOLLAR
    : IDENTIFIER_START_NO_DOLLAR
   .or(ref('DIGIT')
    ;

fragment IDENTIFIER_PART
    : IDENTIFIER_START
   .or(ref('DIGIT')
    ;

// Bug 5408613: Should be Unicode characters.
fragment ref('LETTER')
    : 'a'..'z'
   .or('ref('A')'..'ref('Z')'
    ;

fragment ref('DIGIT')
    : '0'..'9'
    ;

fragment ref('EXPONENT')
    : ('e'.or('ref('E')') ('.plus()'.or('-').optional() ref('DIGIT').plus()
    ;

def('ref('STRING')', '@'.optional() MULTI_LINE_STRING
   .or(SINGLE_LINE_STRING
    ;

fragment MULTI_LINE_STRING
options { greedy=false; }
    : '"""' ..star() '"""'
   .or('\'\'\'' ..star() '\'\'\''
    ;

fragment SINGLE_LINE_STRING
    : '"' STRING_CONTENT_DQ.star() '"'
   .or('\'' STRING_CONTENT_SQ.star() '\''
   .or('@' '\'' (~( '\''.or(ref('NEWLINE') )).star() '\''
   .or('@' '"' (~( '"'.or(ref('NEWLINE') )).star() '"'
    ;

fragment STRING_CONTENT_DQ
    : ~( '\\'.or('"'.or(ref('NEWLINE') )
   .or('\\' ~( ref('NEWLINE') )
    ;

fragment STRING_CONTENT_SQ
    : ~( '\\'.or('\''.or(ref('NEWLINE') )
   .or('\\' ~( ref('NEWLINE') )
    ;

fragment ref('NEWLINE')
    : '\n'
   .or('\r'
    ;

def('BAD_STRING', UNTERMINATED_STRING ref('NEWLINE') { this._error("unterminated string"); }
    ;

fragment UNTERMINATED_STRING
    : '@'.optional() '\'' (~( '\''.or(ref('NEWLINE') )).star()
   .or('@'.optional() '"' (~( '"'.or(ref('NEWLINE') )).star()
    ;

def('ref('HASHBANG')', '#!' ~(ref('NEWLINE')).star() (ref('NEWLINE')).optional()
    ;

 */
  }

}

