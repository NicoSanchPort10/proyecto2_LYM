module Verilang::Load

import ParseTree;
import Verilang::AST;
import Verilang::Parse;

Tree loadParseTree(str src)
  = parseProgram(src);

Tree loadParseTree(loc src)
  = parseProgram(src);

Program loadProgram(str src)
  = implode(#Program, parseProgram(src));

Program loadProgram(loc src)
  = implode(#Program, parseProgram(src));
