module Verilang::Checker

extend analysis::typepal::TypePal;

import Verilang::Syntax;
import ParseTree;
import List;

data IdRole
  = spaceId()
  | operatorId()
  | verilangVarId()
  ;

data AType
  = spaceType()
  | primitiveType(str name)
  | operatorType(int arity, list[str] paramTypes)
  | varType(str spaceName)
  ;

str prettyAType(spaceType())                       = "space";
str prettyAType(primitiveType(str n))              = n;
str prettyAType(operatorType(int a, list[str] _))  = "operator/<a>";
str prettyAType(varType(str sn))                   = "var:<sn>";

set[str] primitiveTypes = {"Int", "Bool", "Char", "String", "Float"};

int sigArity((Type) `<Identifier _> -\> <Type to>`) = 1 + sigArity(to);
default int sigArity(Type _) = 0;

list[str] sigParamTypes((Type) `<Identifier from> -\> <Type to>`) = ["<from>"] + sigParamTypes(to);
default list[str] sigParamTypes(Type _) = [];

void collect(current: (Module) `defmodule <Identifier _name> <Declaration* decls> end`, Collector c) {
  c.enterScope(current);
    collect(decls, c);
  c.leaveScope(current);
}

void collect((Declaration) `using <Identifier _>`, Collector c) { }

void collect(current: (Declaration) `defspace <Identifier name> end`, Collector c) {
  c.define("<name>", spaceId(), name, defType(spaceType()));
}

void collect(current: (Declaration) `defspace <Identifier name> <SpaceParent parent> end`, Collector c) {
  c.define("<name>", spaceId(), name, defType(spaceType()));
  collect(parent, c);
}

void collect(current: (SpaceParent) `\< <Identifier name>`, Collector c) {
  c.use(name, {spaceId()});
}

void collect(current: (Declaration) `defoperator <Identifier name> : <Type sig> end`, Collector c) {
  c.define("<name>", operatorId(), name, defType(operatorType(sigArity(sig), sigParamTypes(sig))));
  collect(sig, c);
}

void collect(current: (Declaration) `defoperator <Identifier name> : <Type sig> <Attribute+ _> end`, Collector c) {
  c.define("<name>", operatorId(), name, defType(operatorType(sigArity(sig), sigParamTypes(sig))));
  collect(sig, c);
}

void collect(current: (Declaration) `defoperator <Identifier name> : <Type sig> <AttributeBlock _> end`, Collector c) {
  c.define("<name>", operatorId(), name, defType(operatorType(sigArity(sig), sigParamTypes(sig))));
  collect(sig, c);
}

void collect(current: (Type) `<Identifier from> -\> <Type to>`, Collector c) {
  if ("<from>" in primitiveTypes) {
    c.fact(from, primitiveType("<from>"));
  } else {
    c.use(from, {spaceId()});
  }
  collect(to, c);
}

void collect(current: (Type) `<Identifier name>`, Collector c) {
  if ("<name>" in primitiveTypes) {
    c.fact(current, primitiveType("<name>"));
  } else {
    c.use(name, {spaceId()});
  }
}

void collect(current: (Declaration) `defvar <{VarItem ","}+ vars> end`, Collector c) {
  collect(vars, c);
}

void collect(current: (VarItem) `<Identifier name> : <Identifier typeName>`, Collector c) {
  str typeNameStr = "<typeName>";
  c.define("<name>", verilangVarId(), name, defType(varType(typeNameStr)));
  if (typeNameStr in primitiveTypes) {
    c.fact(typeName, primitiveType(typeNameStr));
  } else {
    c.use(typeName, {spaceId()});
    c.require("type is a known space", current, [typeName], (Solver s) {
      s.requireTrue(spaceType() := s.getType(typeName),
        error(typeName, "undefined type \'<typeNameStr>\'"));
    });
  }
}

void collect(current: (Declaration) `defrule <RuleTerm lhs> -\> <RuleTerm rhs> end`, Collector c) {
  collect(lhs, c);
  collect(rhs, c);
}

void collect(current: (RuleTerm) `<Application app>`, Collector c) {
  collect(app, c);
}

void collect(current: (Declaration) `defexpression <Expr expr> end`, Collector c) {
  collect(expr, c);
}

void collect(current: (Declaration) `defexpression <Expr expr> <Attribute+ _> end`, Collector c) {
  collect(expr, c);
}

void collect(current: (Expr) `(<Quantifier _> <Identifier var> in <Identifier domain> . <Expr body>)`, Collector c) {
  c.enterScope(current);
    c.define("<var>", verilangVarId(), var, defType(varType("<domain>")));
    c.use(domain, {spaceId()});
    collect(body, c);
  c.leaveScope(current);
}

void collect(current: (Expr) `<LogicExpr le>`, Collector c) {
  collect(le, c);
}

void collect(current: (LogicExpr) `<SimpleExpr first> <LogicStep* rest>`, Collector c) {
  collect(first, c);
  collect(rest, c);
}

void collect(current: (LogicStep) `<LogicOp _> <SimpleExpr rhs>`, Collector c) {
  collect(rhs, c);
}

void collect(current: (SimpleExpr) `<Application app>`, Collector c) {
  collect(app, c);
}

void collect(current: (SimpleExpr) `<Identifier name>`, Collector c) {
  c.use(name, {verilangVarId(), operatorId()});
  str nameStr = "<name>";
  c.require("identifier exists", current, [name], (Solver s) {
    AType t = s.getType(name);
    s.requireTrue(varType(_) := t || operatorType(_, _) := t,
      error(current, "undefined identifier \'<nameStr>\'"));
  });
}

void collect(current: (SimpleExpr) `<Literal lit>`, Collector c) {
  collect(lit, c);
}

void collect(current: (SimpleExpr) `(<Expr inner>)`, Collector c) {
  collect(inner, c);
}

void collect(current: (Application) `(<Identifier name> <SimpleExpr+ params>)`, Collector c) {
  c.use(name, {operatorId()});
  collect(params, c);
  int actualArity = size([p | SimpleExpr p <- params]);
  str nameStr = "<name>";
  list[SimpleExpr] paramList = [p | SimpleExpr p <- params];
  list[Tree] idDeps = [id | SimpleExpr p <- params, (SimpleExpr) `<Identifier id>` := p];
  c.require("arity and type check", current, [name] + idDeps, (Solver s) {
    AType t = s.getType(name);
    if (operatorType(int expected, list[str] paramTypes) := t) {
      if (actualArity != expected) {
        s.requireTrue(false,
          error(current, "operator \'<nameStr>\' expects <expected> argument(s) but got <actualArity>"));
      } else {
        int i = 0;
        for (SimpleExpr p <- paramList) {
          if ((SimpleExpr) `<Identifier id>` := p) {
            AType argType = s.getType(id);
            str expectedTypeName = paramTypes[i];
            if (varType(str sn) := argType) {
              s.requireTrue(sn == expectedTypeName,
                error(p, "argument <i+1> of \'<nameStr>\' has type <sn> but expected <expectedTypeName>"));
            }
          }
          i += 1;
        }
      }
    }
  });
}

void collect(current: (Literal) `<IntLiteral _>`, Collector c) {
  c.fact(current, primitiveType("Int"));
}

void collect(current: (Literal) `<FloatLiteral _>`, Collector c) {
  c.fact(current, primitiveType("Float"));
}

void collect(current: (Literal) `<BoolLiteral _>`, Collector c) {
  c.fact(current, primitiveType("Bool"));
}

void collect(current: (Literal) `<CharLiteral _>`, Collector c) {
  c.fact(current, primitiveType("Char"));
}

void collect(current: (Literal) `<StringLiteral _>`, Collector c) {
  c.fact(current, primitiveType("String"));
}

TModel checkProgram(Tree pt) {
  if (pt has top) pt = pt.top;
  Collector c = newCollector("verilang", pt, config=tconfig());
  collect(pt, c);
  return newSolver(pt, c.run()).run();
}
