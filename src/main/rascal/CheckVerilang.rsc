module CheckVerilang

import IO;
import Message;
import ParseTree;
import analysis::typepal::TypePal;

import Verilang::Syntax;
import Verilang::Parse;
import Verilang::Checker;


int checkFile(loc src) {
  println("=== Checking: <src.path> ===");
  try {
    start[Program] pt = parseProgram(src);
    TModel tm = checkProgram(pt);
    list[Message] msgs = getMessages(tm);
    if (msgs == []) {
      println("  OK — no errors");
    } else {
      for (Message m <- msgs) {
        str kind = m is error ? "ERROR" : (m is warning ? "WARNING" : "INFO");
        println("  [<kind>] <m.msg> at line <m.at.begin.line>");
      }
    }
    return size([m | m <- msgs, m is error]);
  } catch value e: {
    println("  PARSE/RUNTIME ERROR: <e>");
    return 1;
  }
}

int main(list[str] _args=[]) {
  loc base = |project://proyecto2/examples/|;

  list[tuple[str file, int expectedErrors]] cases = [
    <"test-ok.vl",    0>,
    <"test-arity.vl", 2>,
    <"test-bad-space.vl", 1>,
    <"test-literals.vl", 0>
  ];

  int passed = 0;
  int failed = 0;

  for (<f, expected> <- cases) {
    int actual = checkFile(base + f);
    if (actual == expected) {
      println("  PASS (expected <expected> error(s), got <actual>)\n");
      passed += 1;
    } else {
      println("  FAIL (expected <expected> error(s), got <actual>)\n");
      failed += 1;
    }
  }

  println("Results: <passed> passed, <failed> failed");
  return failed == 0 ? 0 : 1;
}
