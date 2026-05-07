module Verilang::Checker

extend analysis::typepal::TypePal;

import Verilang::Syntax;
import ParseTree;

// --- Roles para cada tipo de declaracion ---
data IdRole
  = spaceId()
  | operatorId()
  | verilangVarId()
  ;

// --- Tipos abstractos ---
data AType
  = spaceType()
  | primitiveType(str name)
  | operatorType()
  | varType()
  ;

str prettyAType(spaceType())        = "space";
str prettyAType(primitiveType(str n)) = n;
str prettyAType(operatorType())     = "operator";
str prettyAType(varType())          = "variable";

set[str] primitiveTypes = {"Int", "Bool", "Char", "String", "Float"};

// --- Collect: Modulo (scope global de declaraciones) ---
void collect(current: (Module) `defmodule <Identifier _name> <Declaration* decls> end`, Collector c) {
  c.enterScope(current);
    collect(decls, c);
  c.leaveScope(current);
}

// --- Collect: Espacios ---
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

// --- Collect: Operadores ---
void collect(current: (Declaration) `defoperator <Identifier name> : <Type sig> end`, Collector c) {
  c.define("<name>", operatorId(), name, defType(operatorType()));
  collect(sig, c);
}

void collect(current: (Declaration) `defoperator <Identifier name> : <Type sig> <Attribute+ _> end`, Collector c) {
  c.define("<name>", operatorId(), name, defType(operatorType()));
  collect(sig, c);
}

void collect(current: (Declaration) `defoperator <Identifier name> : <Type sig> <AttributeBlock _> end`, Collector c) {
  c.define("<name>", operatorId(), name, defType(operatorType()));
  collect(sig, c);
}

// --- Collect: Tipos en signaturas ---
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

// --- Collect: Variables ---
void collect(current: (Declaration) `defvar <{VarItem ","}+ vars> end`, Collector c) {
  collect(vars, c);
}

void collect(current: (VarItem) `<Identifier name> : <Identifier typeName>`, Collector c) {
  c.define("<name>", verilangVarId(), name, defType(varType()));
  if ("<typeName>" in primitiveTypes) {
    c.fact(typeName, primitiveType("<typeName>"));
  } else {
    c.use(typeName, {spaceId()});
  }
}

// --- Collect: Expresion cuantificada (introduce variable local) ---
void collect(current: (Expr) `(<Quantifier _> <Identifier var> in <Identifier _> . <Expr body>)`, Collector c) {
  c.enterScope(current);
    c.define("<var>", verilangVarId(), var, defType(varType()));
    collect(body, c);
  c.leaveScope(current);
}

// --- Collect: Aplicaciones (verificar que el operador existe) ---
void collect(current: (Application) `(<Identifier name> <SimpleExpr+ params>)`, Collector c) {
  c.use(name, {operatorId()});
  collect(params, c);
}

// --- Collect: Identificadores sueltos en expresiones ---
void collect(current: (SimpleExpr) `<Identifier name>`, Collector c) {
  c.use(name, {verilangVarId(), operatorId()});
}

// --- TModel desde parse tree ---
TModel checkProgram(Tree pt) {
  if (pt has top) pt = pt.top;
  Collector c = newCollector("verilang", pt, config=tconfig());
  collect(pt, c);
  return newSolver(pt, c.run()).run();
}

