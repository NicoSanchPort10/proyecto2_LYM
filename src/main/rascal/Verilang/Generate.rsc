module Verilang::Generate

import Verilang::AST;
import Verilang::Load;
import List;
import String;
import IO;

str runProgram(loc src) {
  Program p = loadProgram(src);
  return generateProgram(p);
}

str generateProgram(program(Module m)) = generateModule(m);

str generateModule(moduleDecl(str name, list[Declaration] decls)) {
  list[str] uses = [n | importDecl(n) <- decls];
  str header = "=== Module: <name>";
  if (uses != []) header += " (uses: <intercalate(", ", uses)>)";
  header += " ===\n";
  str body = intercalate("\n", [line | decl <- decls, str line := generateDecl(decl), line != ""]);
  return header + body + "\n";
}

str generateDecl(importDecl(str _)) = "";
str generateDecl(spaceDecl(str name, parent(str p))) = "  Space: <name> (extends <p>)";
str generateDecl(spaceDeclNoParent(str name))        = "  Space: <name>";
str generateDecl(operatorDeclNoAttrs(str name, Type sig)) =
  "  Op: <name> : <generateType(sig)>";
str generateDecl(operatorDecl(str name, Type sig, list[Attribute] attrs)) =
  "  Op: <name> : <generateType(sig)> [<generateAttrs(attrs)>]";
str generateDecl(operatorDeclBlock(str name, Type sig, block(list[Attribute] attrs))) =
  "  Op: <name> : <generateType(sig)> [<generateAttrs(attrs)>]";
str generateDecl(varDecl(list[VarItem] vars)) {
  str result = "  Vars:";
  for (v <- vars) {
    result += "\n    <generateVar(v)>";
  }
  return result;
}
str generateDecl(ruleDecl(RuleTerm l, RuleTerm r)) =
  "  Rule: <generateRuleTerm(l)> -\> <generateRuleTerm(r)>";
str generateDecl(expressionDeclNoAttrs(Expr e)) =
  "  Expr: <generateExpr(e)>";
str generateDecl(expressionDecl(Expr e, list[Attribute] _)) =
  "  Expr: <generateExpr(e)>";
default str generateDecl(Declaration _) = "";

str generateType(namedType(str name)) = name;
str generateType(functionType(str from, Type to)) = "<from> -\> <generateType(to)>";

str generateVar(varItem(str name, str typeName)) = "<name> : <typeName>";

str generateAttrs(list[Attribute] attrs) =
  intercalate(", ", [generateAttr(a) | a <- attrs]);

str generateAttr(plainAttribute(str name)) = name;
str generateAttr(valuedAttribute(str name, idValue(str v))) = "<name>:<v>";
str generateAttr(valuedAttribute(str name, intValue(int v))) = "<name>:<v>";

str generateRuleTerm(ruleApplication(application(str name, list[SimpleExpr] params))) {
  if (params == []) return "(<name>)";
  return "(<name> <intercalate(" ", [generateSimpleExpr(p) | p <- params])>)";
}

str generateExpr(quantifiedExpr(Quantifier q, str var, str domain, Expr body)) =
  "<generateQuant(q)> <var> in <domain> . <generateExpr(body)>";
str generateExpr(logicExpr(LogicExpr le)) = generateLogicExpr(le);

str generateQuant(forallQ()) = "forall";
str generateQuant(existsQ()) = "exists";

str generateLogicExpr(logicChain(SimpleExpr first, list[LogicStep] rest)) {
  str result = generateSimpleExpr(first);
  for (logicStep(LogicOp op, SimpleExpr rhs) <- rest) {
    result += " <generateOp(op)> <generateSimpleExpr(rhs)>";
  }
  return result;
}

str generateSimpleExpr(applicationExpr(application(str name, list[SimpleExpr] params))) {
  if (params == []) return "(<name>)";
  return "(<name> <intercalate(" ", [generateSimpleExpr(p) | p <- params])>)";
}
str generateSimpleExpr(identifierExpr(str name)) = name;
str generateSimpleExpr(literalExpr(intLiteral(int n)))    = "<n>";
str generateSimpleExpr(literalExpr(floatLiteral(real r))) = "<r>";
str generateSimpleExpr(literalExpr(boolLiteral(str b)))   = b;
str generateSimpleExpr(literalExpr(charLiteral(str c)))   = c;
str generateSimpleExpr(literalExpr(stringLiteral(str s))) = s;
str generateSimpleExpr(groupedExpr(Expr e)) = "(<generateExpr(e)>)";
default str generateSimpleExpr(SimpleExpr _) = "?";

str generateOp(andOp())    = "and";
str generateOp(orOp())     = "or";
str generateOp(impliesOp())= "=\>";
str generateOp(equivOp())  = "≡";
str generateOp(eqOp())     = "=";
str generateOp(neqOp())    = "\<\>";
str generateOp(ltOp())     = "\<";
str generateOp(gtOp())     = "\>";
str generateOp(leOp())     = "\<=";
str generateOp(geOp())     = "\>=";
str generateOp(inOp())     = "in";
str generateOp(isInOp())   = "isIn";

int main(list[str] args=[]) {
  loc src = args == [] ? |project://proyecto2/examples/example.vl| : |project://proyecto2/| + args[0];
  println(runProgram(src));
  return 0;
}
