module Verilang::Run

import IO;
import List;
import Message;
import ParseTree;
import analysis::typepal::TypePal;
import Verilang::AST;
import Verilang::Checker;
import Verilang::Load;
import Verilang::Parse;
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

bool roundTripOk(list[str] args) {
  Program original = loadInput(args);
  Program reparsed = loadProgram(generatedOutput(args));
  return prettyProgram(original) == prettyProgram(reparsed);
}

str typeCheckReport(loc source) {
  TModel tm = checkProgram(parseProgram(source));
  list[Message] msgs = getMessages(tm);
  if (msgs == []) return "  OK — no errors";
  list[str] lines = [];
  for (Message m <- msgs) {
    str kind = m is error ? "ERROR" : (m is warning ? "WARNING" : "INFO");
    lines = lines + ["  [<kind>] <m.msg> at line <m.at.begin.line>"];
  }
  return intercalate("\n", lines);
}

int runCli(list[str] args) {
  println(pipelineReport(args));
  loc source = inputLoc(args);
  TModel tm = checkProgram(parseProgram(source));
  bool hasTypeErrors = size([m | m <- getMessages(tm), m is error]) > 0;
  return (roundTripOk(args) && !hasTypeErrors) ? 0 : 1;
}

str pipelineReport(list[str] args) {
  loc source = inputLoc(args);
  str generated = generatedOutput(args);
  str roundTrip = roundTripOk(args) ? "ok" : "failed";
  str typeCheck = typeCheckReport(source);
  return "Input: <source>\nRound-trip: <roundTrip>\nType checking:\n<typeCheck>\n\nGenerated Verilang:\n<generated>\n";
}

int main(list[str] args=[]) {
  return runCli(args);
}
