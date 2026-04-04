module Verilang::Syntax

layout LAYOUT
  = [\t-\n \r \ ]* !>> [\t-\n \r \ ]
  ;

keyword Reserved
  = "defmodule"
  | "end"
  | "using"
  | "defspace"
  | "defoperator"
  | "defvar"
  | "defrule"
  | "defexpression"
  | "forall"
  | "exists"
  | "in"
  | "and"
  | "or"
  ;

start syntax Program
  = program: Module module
  ;

syntax Module
  = moduleDecl: "defmodule" Identifier name Declaration+ body "end"
  ;

syntax Declaration
  = importDecl: "using" Identifier name
  | spaceDecl: "defspace" Identifier name SpaceParent parent "end"
  | spaceDeclNoParent: "defspace" Identifier name "end"
  | operatorDeclBlock: "defoperator" Identifier name ":" Type sig AttributeBlock attributeBlock "end"
  | operatorDecl: "defoperator" Identifier name ":" Type sig Attribute+ attributes "end"
  | operatorDeclNoAttrs: "defoperator" Identifier name ":" Type sig "end"
  | varDecl: "defvar" {VarItem ","}+ vars "end"
  | ruleDecl: "defrule" RuleTerm lhs "-\>" RuleTerm rhs "end"
  | expressionDecl: "defexpression" Expr expr Attribute+ attributes "end"
  | expressionDeclNoAttrs: "defexpression" Expr expr "end"
  ;

syntax SpaceParent
  = parent: "\<" Identifier name
  ;

syntax VarItem
  = varItem: Identifier name ":" Identifier typeName
  ;

syntax Type
  = functionType: Identifier from "-\>" Type to
  | namedType: Identifier name
  ;

syntax Expr
  = quantifiedExpr: "(" Quantifier quantifier Identifier var "in" Identifier domain "." Expr body ")"
  | logicExpr: LogicExpr logic
  ;

syntax GroupedLogicExpr
  = groupedLogic: SimpleExpr first GroupedLogicStep+ rest
  ;

syntax Quantifier
  = forallQ: "forall"
  | existsQ: "exists"
  ;

syntax LogicExpr
  = logicChain: SimpleExpr first LogicStep* rest
  ;

syntax LogicStep
  = logicStep: LogicOp op SimpleExpr rhs
  ;

syntax LogicOp
  = andOp: "and"
  | orOp: "or"
  | impliesOp: "=\>"
  | equivOp: "≡"
  | eqOp: "="
  | neqOp: "\<\>"
  | ltOp: "\<"
  | gtOp: "\>"
  | leOp: "\<="
  | geOp: "\>="
  | inOp: "in"
  | namedOp: Identifier op
  ;

syntax BuiltinLogicOp
  = builtinAndOp: "and"
  | builtinOrOp: "or"
  | builtinImpliesOp: "=\>"
  | builtinEquivOp: "≡"
  | builtinEqOp: "="
  | builtinNeqOp: "\<\>"
  | builtinLtOp: "\<"
  | builtinGtOp: "\>"
  | builtinLeOp: "\<="
  | builtinGeOp: "\>="
  | builtinInOp: "in"
  | builtinIsInOp: "isIn"
  ;

syntax GroupedLogicStep
  = groupedLogicStep: BuiltinLogicOp op SimpleExpr rhs
  ;

syntax SimpleExpr
  = applicationExpr: Application app
  | identifierExpr: Identifier name
  | literalExpr: Literal lit
  | groupedExpr: "(" GroupedLogicExpr expr ")"
  ;

syntax Application
  = application: "(" Identifier name SimpleExpr+ params ")"
  ;

syntax RuleTerm
  = ruleApplication: Application app
  | ruleIdentifier: Identifier name
  ;

syntax Attribute
  = plainAttribute: Identifier name
  | valuedAttribute: Identifier name ":" AttributeValue value
  ;

syntax AttributeBlock
  = block: "[" Attribute+ attrs "]"
  ;

syntax AttributeValue
  = idValue: Identifier text
  | intValue: IntLiteral number
  ;

syntax Literal
  = floatLiteral: FloatLiteral floatText
  | intLiteral: IntLiteral intText
  ;

lexical Identifier
  = ([A-Za-z] [A-Za-z0-9\-]* !>> [A-Za-z0-9\-]) \ Reserved
  ;

lexical IntLiteral
  = [0-9]+ !>> [0-9]
  ;

lexical FloatLiteral
  = [0-9]+ "." [0-9]+ !>> [0-9]
  ;
