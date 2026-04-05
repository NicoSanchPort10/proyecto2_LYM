module Verilang::Run

import IO;
import ParseTree;
import Verilang::AST;
import Verilang::Load;
import Verilang::Pretty;

loc defaultInput()
  = |project://proyecto2/examples/set.veri|;

loc inputLoc(list[str] args) {
  if (args == []) {
    return defaultInput();
  }

  return |project://proyecto2/| + args[0];
}

Program loadInput(list[str] args)
  = loadProgram(inputLoc(args));

str generatedOutput(list[str] args)
  = unparse(loadParseTree(inputLoc(args)));

int runCli(list[str] args) {
  println(pipelineReport(args));

  if (roundTripOk(args)) {
    return 0;
  }

  return 1;
}

bool roundTripOk(list[str] args) {
  Program original = loadInput(args);
  Program reparsed = loadProgram(generatedOutput(args));
  return prettyProgram(original) == prettyProgram(reparsed);
}

str pipelineReport(list[str] args) {
  loc source = inputLoc(args);
  str generated = generatedOutput(args);
  str roundTrip = roundTripOk(args) ? "ok" : "failed";

  return "Input: <source>\nRound-trip: <roundTrip>\n\nGenerated Verilang:\n<generated>\n";
}

int main(list[str] args=[]) {
  return runCli(args);
}
