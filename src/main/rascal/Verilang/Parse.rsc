module Verilang::Parse

import ParseTree;
import Verilang::Syntax;

Tree parseProgram(str src) = parse(#start[Program], src);
Tree parseProgram(loc src) = parse(#start[Program], src);
