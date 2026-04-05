module Verilang::AST

data Program
  = program(Module root)
  ;

data Module
  = moduleDecl(str modName, list[Declaration] declarations)
  ;

data Declaration
  = importDecl(str importedName)
  | spaceDecl(str spaceName, SpaceParent parentSpec)
  | spaceDeclNoParent(str spaceName)
  | operatorDeclBlock(str operatorName, Type signature, AttributeBlock attributeBlock)
  | operatorDecl(str operatorName, Type signature, list[Attribute] attributes)
  | operatorDeclNoAttrs(str operatorName, Type signature)
  | varDecl(list[VarItem] variables)
  | ruleDecl(RuleTerm left, RuleTerm right)
  | expressionDecl(Expr expressionBody, list[Attribute] attributes)
  | expressionDeclNoAttrs(Expr expressionBody)
  ;

data SpaceParent
  = parent(str parentName)
  ;

data VarItem
  = varItem(str varName, str typeName)
  ;

data Type
  = functionType(str fromType, Type toType)
  | namedType(str typeName)
  ;

data Expr
  = quantifiedExpr(Quantifier quantifier, str variable, str domain, Expr body)
  | logicExpr(LogicExpr logic)
  ;

data Quantifier
  = forallQ()
  | existsQ()
  ;

data LogicExpr
  = logicChain(SimpleExpr first, list[LogicStep] rest)
  ;

data LogicStep
  = logicStep(LogicOp op, SimpleExpr rhs)
  ;

data LogicOp
  = andOp()
  | orOp()
  | impliesOp()
  | equivOp()
  | eqOp()
  | neqOp()
  | ltOp()
  | gtOp()
  | leOp()
  | geOp()
  | inOp()
  | isInOp()
  ;

data SimpleExpr
  = applicationExpr(Application application)
  | identifierExpr(str name)
  | literalExpr(Literal literal)
  | groupedExpr(Expr inner)
  ;

data Application
  = application(str name, list[SimpleExpr] params)
  ;

data RuleTerm
  = ruleApplication(Application application)
  ;

data Attribute
  = plainAttribute(str name)
  | valuedAttribute(str name, AttributeValue attrValue)
  ;

data AttributeBlock
  = block(list[Attribute] attributes)
  ;

data AttributeValue
  = idValue(str text)
  | intValue(int number)
  ;

data Literal
  = floatLiteral(real floatNumber)
  | intLiteral(int intNumber)
  ;
