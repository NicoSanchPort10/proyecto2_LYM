module Verilang::Pretty

import String;
import Verilang::AST;

str prettyProgram(Program p) {
  switch (p) {
    case program(moduleDecl(modName, declarations)):
      return "program(\n  moduleDecl(\"<modName>\", [\n<prettyDeclarationsIndented(declarations)>\n  ])\n)";
  }

  return "invalid Program";
}

str prettyDeclaration(Declaration decl) {
  switch (decl) {
    case importDecl(importedName):
      return "importDecl(\"<importedName>\")";
    case spaceDecl(spaceName, parent(parentName)):
      return "spaceDecl(\"<spaceName>\", parent(\"<parentName>\"))";
    case spaceDeclNoParent(spaceName):
      return "spaceDeclNoParent(\"<spaceName>\")";
    case operatorDeclBlock(operatorName, signature, block):
      return "operatorDeclBlock(\"<operatorName>\", <prettyType(signature)>, <prettyAttributeBlock(block)>)";
    case operatorDecl(operatorName, signature, attributes):
      return "operatorDecl(\"<operatorName>\", <prettyType(signature)>, [<prettyAttributes(attributes)>])";
    case operatorDeclNoAttrs(operatorName, signature):
      return "operatorDeclNoAttrs(\"<operatorName>\", <prettyType(signature)>)";
    case varDecl(variables):
      return "varDecl([<prettyVarItems(variables)>])";
    case ruleDecl(left, right):
      return "ruleDecl(<prettyRuleTerm(left)>, <prettyRuleTerm(right)>)";
    case expressionDecl(expressionBody, attributes):
      return "expressionDecl(<prettyExpr(expressionBody)>, [<prettyAttributes(attributes)>])";
    case expressionDeclNoAttrs(expressionBody):
      return "expressionDeclNoAttrs(<prettyExpr(expressionBody)>)";
  }

  return "invalid Declaration";
}

str prettyVarItem(VarItem item) {
  switch (item) {
    case varItem(varName, typeName):
      return "varItem(\"<varName>\", \"<typeName>\")";
  }

  return "invalid VarItem";
}

str prettyType(Type t) {
  switch (t) {
    case functionType(fromType, toType):
      return "functionType(\"<fromType>\", <prettyType(toType)>)";
    case namedType(typeName):
      return "namedType(\"<typeName>\")";
  }

  return "invalid Type";
}

str prettyExpr(Expr e) {
  switch (e) {
    case quantifiedExpr(quantifier, variable, domain, body):
      return "quantifiedExpr(<prettyQuantifier(quantifier)>, \"<variable>\", \"<domain>\", <prettyExpr(body)>)";
    case logicExpr(logic):
      return "logicExpr(<prettyLogicExpr(logic)>)";
  }

  return "invalid Expr";
}

str prettyQuantifier(Quantifier q) {
  switch (q) {
    case forallQ():
      return "forallQ()";
    case existsQ():
      return "existsQ()";
  }

  return "invalid Quantifier";
}

str prettyLogicExpr(LogicExpr expr) {
  switch (expr) {
    case logicChain(first, rest):
      return "logicChain(<prettySimpleExpr(first)>, [<prettyLogicSteps(rest)>])";
  }

  return "invalid LogicExpr";
}

str prettyLogicStep(LogicStep step) {
  switch (step) {
    case logicStep(op, rhs):
      return "logicStep(<prettyLogicOp(op)>, <prettySimpleExpr(rhs)>)";
  }

  return "invalid LogicStep";
}

str prettyLogicOp(LogicOp op) {
  switch (op) {
    case andOp():
      return "andOp()";
    case orOp():
      return "orOp()";
    case impliesOp():
      return "impliesOp()";
    case equivOp():
      return "equivOp()";
    case eqOp():
      return "eqOp()";
    case neqOp():
      return "neqOp()";
    case ltOp():
      return "ltOp()";
    case gtOp():
      return "gtOp()";
    case leOp():
      return "leOp()";
    case geOp():
      return "geOp()";
    case inOp():
      return "inOp()";
    case isInOp():
      return "isInOp()";
  }

  return "invalid LogicOp";
}

str prettySimpleExpr(SimpleExpr expr) {
  switch (expr) {
    case applicationExpr(application):
      return "applicationExpr(<prettyApplication(application)>)";
    case identifierExpr(name):
      return "identifierExpr(\"<name>\")";
    case literalExpr(literal):
      return "literalExpr(<prettyLiteral(literal)>)";
    case groupedExpr(inner):
      return "groupedExpr(<prettyExpr(inner)>)";
  }

  return "invalid SimpleExpr";
}

str prettyApplication(Application app) {
  switch (app) {
    case application(name, params):
      return "application(\"<name>\", [<prettySimpleExprs(params)>])";
  }

  return "invalid Application";
}

str prettyRuleTerm(RuleTerm term) {
  switch (term) {
    case ruleApplication(application):
      return "ruleApplication(<prettyApplication(application)>)";
  }

  return "invalid RuleTerm";
}

str prettyAttribute(Attribute attr) {
  switch (attr) {
    case plainAttribute(name):
      return "plainAttribute(\"<name>\")";
    case valuedAttribute(name, attrValue):
      return "valuedAttribute(\"<name>\", <prettyAttributeValue(attrValue)>)";
  }

  return "invalid Attribute";
}

str prettyAttributeBlock(AttributeBlock b) {
  switch (b) {
    case block(attributes):
      return "block([<prettyAttributes(attributes)>])";
  }

  return "invalid AttributeBlock";
}

str prettyAttributeValue(AttributeValue v) {
  switch (v) {
    case idValue(text):
      return "idValue(\"<text>\")";
    case intValue(number):
      return "intValue(<number>)";
  }

  return "invalid AttributeValue";
}

str prettyLiteral(Literal lit) {
  switch (lit) {
    case floatLiteral(floatNumber):
      return "floatLiteral(<floatNumber>)";
    case intLiteral(intNumber):
      return "intLiteral(<intNumber>)";
  }

  return "invalid Literal";
}

str prettyDeclarations(list[Declaration] declarations)
  = joinComma([prettyDeclaration(decl) | decl <- declarations]);

str prettyAttributes(list[Attribute] attributes)
  = joinComma([prettyAttribute(attr) | attr <- attributes]);

str prettyVarItems(list[VarItem] variables)
  = joinComma([prettyVarItem(item) | item <- variables]);

str prettyLogicSteps(list[LogicStep] steps)
  = joinComma([prettyLogicStep(step) | step <- steps]);

str prettySimpleExprs(list[SimpleExpr] expressions)
  = joinComma([prettySimpleExpr(expr) | expr <- expressions]);

str joinComma(list[str] parts) {
  str result = "";
  bool first = true;

  for (part <- parts) {
    if (!first) {
      result += ", ";
    }

    result += part;
    first = false;
  }

  return result;
}

str prettyDeclarationsIndented(list[Declaration] declarations)
  = joinWith(",\n", [indentBlock(prettyDeclaration(decl), 2) | decl <- declarations]);

str indentBlock(str text, int level)
  = "<indent(level)><replaceAll(text, "\n", "\n<indent(level)>")>";

str joinWith(str separator, list[str] parts) {
  str result = "";
  bool first = true;

  for (part <- parts) {
    if (!first) {
      result += separator;
    }

    result += part;
    first = false;
  }

  return result;
}

str indent(int level) {
  if (level == 0) {
    return "";
  }

  return "  " + indent(level - 1);
}
