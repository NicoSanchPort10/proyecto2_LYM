module Verilang::Parse

import ParseTree;
import Verilang::Syntax;

start[Program] parseProgram(str src) = parse(#start[Program], src);
start[Program] parseProgram(loc src) = parse(#start[Program], src);
