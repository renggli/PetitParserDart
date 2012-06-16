// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * Dart grammar definition.
 */
class DartGrammar extends CompositeParser {

  void initialize() {
    def('start', ref('unit').end());

    variables();
    functions();
    parameters();
    classes();
  }

  /** Returns a dart token. */
  Parser tok(String value) {
    return string(value).token().trim(ref('trimmer'));
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

}

