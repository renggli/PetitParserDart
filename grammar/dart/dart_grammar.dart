// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * Dart grammar definition.
 */
class DartGrammar extends CompositeParser {

  void initialize() {
    def('start', ref('unit').end());
    
    whitespaces();
    variables();
    functions();
    parameters();
    classes();
    operators();
    getters();
    setters();
    constructors();
  }

  /** Returns a dart token. */
  Parser tok(String value) {
    return string(value).token().trim(ref('whitespace'));
  }
  
  void whitespaces() {
    def('newline', Token.newlineParser());
    def('whitespace', whitespace()
      .or(string('/*')
        .seq(string('*/').neg().star())
        .seq(string('*/')))
      .or(string('//')
        .seq(ref('newline').neg().star())));
  }

  /** Variables: http://www.dartlang.org/docs/spec/latest/dart-language-specification.html#h.55kzc4r0q21p */
  void variables() {
    def('variableDeclaration', ref('declaredIdentifier')
      .seq(tok(",").seq(ref('identifier')).star()));
    def('initializedVariableDeclaration', ref('declaredIdentifier')
      .seq(tok("=").seq(ref('expression')).optional())
      .seq(tok(",").seq(ref('initializedIdentifier')).star()));
    def('initializedIdentifierList', ref('itializedIdentifier')
      .seq(tok(",").seq(ref('initializedIdentifier')).star()));
    def('initializedIdentifier', ref('identifier')
      .seq(tok("=").seq(ref('expression')).optional()));
    def('declaredIdentifier', ref('finalConstVarOrType')
      .seq(ref('identifier')));
    def('finalConstVarOrType', tok("final").seq(ref('type').optional())
      .or(tok("const").seq(ref('type').optional()))
      .or(tok("var"))
      .or(ref('type')));
  }

  /** Functions: http://www.dartlang.org/docs/spec/latest/dart-language-specification.html#h.kt174mfrzv4a */
  void functions() {
    def('functionSignature', ref('returnType').optional()
      .seq(ref('identifier'))
      .seq(ref('formalParameterList')));
    def('returnType', tok("void")
      .or(ref('type')));
    def('functionBody', tok("=>")
      .seq(ref('expression'))
      .seq(tok(";"))
      .or(ref('block')));
    def('block', tok("{")
      .seq(ref('statements'))
      .seq(tok("}")));
  }

  /** Parameters: http://www.dartlang.org/docs/spec/latest/dart-language-specification.html#h.1ng1g7im8ubk */
  void parameters() {
    def('formalParameterList',
      tok("(")
        .seq(tok(")"))
      .or(tok("(")
        .seq(ref('normalFormalParameters').separatedBy(tok(",")))
        .seq(tok(")")))
      .or(tok("(")
        .seq(ref('namedFormalParameters'))
        .seq(tok(")"))));
    def('normalFormalParameters', ref('normalFormalParameter').separatedBy(tok(",")));
    def('namedFormalParameters', tok("[")
      .seq(ref('defaultFormalParameter').separatedBy(tok(","))));
    def('normalFormalParameter', ref('functionSignature')
      .or(ref('fieldFormalParameter'))
      .or(ref('simpleFormalParameter')));
    def('simpleFormalParameter', ref('declaredIdentifier')
      .or(ref('identifier')));
    def('fieldFormalParameter', ref('finalConstVarOrType').optional()
      .seq(tok("this"))
      .seq(tok("."))
      .seq(ref('identifier')));
    def('defaultFormalParameter', ref('normalFormalParameter')
      .seq(tok("=").seq(ref('expression')).optional()));
  }

  /** Classes: http://www.dartlang.org/docs/spec/latest/dart-language-specification.html#h.ed5f44k6gfp */
  void classes() {
    def('classDefinition', tok("abstract").optional()
      .seq(tok("class"))
      .seq(ref('identifier'))
      .seq(ref('typeParameters').optional())
      .seq(ref('superclass').optional())
      .seq(ref('interfaces').optional())
      .seq(tok("{"))
      .seq(ref('classMemberDefinition').star())
      .seq(tok("}")));
    def('classMemberDefinition', ref('declaration').seq(tok(";"))
      .or(ref('methodSignature').seq(ref('functionBody'))));
    def('methodSignature', ref('factoryConstructorSignature')
      .or(tok("static").optional().seq(ref('functionSignature')))
      .or(ref('getterSignature'))
      .or(ref('setterSignature'))
      .or(ref('operatorSignature'))
      .or(ref('constructorSignature').seq(ref('initializers').optional())));
    def('declaration',
      ref('constantConstructorSignature')
        .seq(ref('redirection').or(ref('initializers')).optional())
      .or(ref('constructorSignature')
        .seq(ref('redirection').or(ref('initializers')).optional()))
      .or(tok("abstract")
        .seq(ref('getterSignature')))
      .or(tok("abstract")
        .seq(ref('setterSignature')))
      .or(tok("abstract")
        .seq(ref('operatorSignature')))
      .or(tok("abstract")
        .seq(ref('functionSignature')))
      .or(tok("static")
        .seq(tok("final").or(tok("const")))
        .seq(ref('type').optional())
        .seq(ref('staticFinalDeclarationList')))
      .or(tok("const")
        .seq(ref('type').optional())
        .seq(ref('staticFinalDeclarationList')))
      .or(tok("final")
        .seq(ref('type').optional())
        .seq(ref('initializedIdentifierList')))
      .or(tok("static").optional()
        .seq(tok("var").or(ref('type')))
        .seq(ref('initializedIdentifierList'))));
    def('staticFinalDeclarationList', ref('staticFinalDeclaration').separatedBy(tok(",")));
    def('staticFinalDeclaration', ref('identifier').seq(tok("=")).seq(ref('expression')));
  }
  
  /** Operators: http://www.dartlang.org/docs/spec/latest/dart-language-specification.html#h.8z01vn73qf90 */
  void operators() {
    def('operatorSignature', ref('returnType').optional()
      .seq(tok("operator"))
      .seq(ref('operator'))
      .seq(ref('formalParameterList')));
    def('operator', ref('unaryOperator')
      .or(ref('binaryOperator'))
      .or(tok("[")
        .seq(tok("]"))
        .seq(tok("=")))
      .or(tok("[")
        .seq(tok("]")))
      .or(tok("negate"))
      .or(tok("equals")));
    def('unaryOperator', ref('negateOperator'));
    def('binaryOperator', ref('multiplicativeOperator')
      .or(ref('multiplicativeOperator'))
      .or(ref('additiveOperator'))
      .or(ref('shiftOperator'))
      .or(ref('relationalOperator'))
      .or(ref('equalityOperator'))
      .or(ref('bitwiseOperator')));
    def('prefixOperator', tok("-")
      .or(ref('negateOperator')));
    def('negateOperator', tok("!")
      .or(tok("~")));
  }
  
  /** Getters: http://www.dartlang.org/docs/spec/latest/dart-language-specification.html#h.semn73yhmkb5 */
  void getters() {
    def('getterSignature', tok("static").optional()
      .seq(ref('returnType').optional())
      .seq(tok("get"))
      .seq(ref('identifier'))
      .seq(ref('formalParameterList')));
  }
  
  /** Setters: http://www.dartlang.org/docs/spec/latest/dart-language-specification.html#h.xn3nrcf01kbi */
  void setters() {
    def('setterSignature', tok("static").optional()
        .seq(ref('returnType').optional())
        .seq(tok("set"))
        .seq(ref('identifier'))
        .seq(ref('formalParameterList')));
  }
  
  /** Constructors: */
  void constructors() {
    constructorSignature:
      identifier formalParameterList
    | namedConstructorSignature
    ;
 namedConstructorSignature:
      identifier '.' identifier formalParameterList
    ;
  redirection:
    ':' this ('.' identifier)? arguments
   ;
  initializers:
    ':' superCallOrFieldInitializer (',' superCallOrFieldInitializer)*
  ;
superCallOrFieldInitializer:
    super arguments
  | super '.' identifier arguments
  | fieldInitializer
  ;
fieldInitializer:
      (this '.')? identifier '=' conditionalExpression
  ;
  factoryConstructorSignature:
    factory qualified  ('.' identifier)? formalParameterList
  ;
  constantConstructorSignature:
    const qualified formalParameterList
  ;
  }
  
  /** Superclasses: */
  void superclasses() {
    superclass:
      extends type
    ;
  interfaces:
    implements typeList
  ;
  }
  
  /** : */
  void interfaces() {
    interfaceDefinition:
      interface identifier typeParameters? superinterfaces?
      factorySpecification? '{' (interfaceMemberDefinition)* '}'
    ;
 interfaceMemberDefinition:
      static final type? initializedIdentifierList ';'
    | functionSignature ';'
    | constantConstructorSignature ';'
    | namedConstructorSignature ';'
    | getterSignature ';'
     | setterSignature ';'
    | operatorSignature ';'
    | variableDeclaration ';'
     ;
  }

}

