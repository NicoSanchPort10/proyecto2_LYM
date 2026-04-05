module HighlightVerilang

import IO;
import Verilang::Highlight;

loc defaultInput()
  = |project://proyecto2/examples/set.veri|;

loc defaultOutput()
  = |project://proyecto2/target/verilang-highlight.html|;

loc inputLoc(list[str] args) {
  if (args == []) {
    return defaultInput();
  }

  return |project://proyecto2/| + args[0];
}

loc outputLoc(list[str] args) {
  switch (args) {
    case []:
      return defaultOutput();
    case [_]:
      return defaultOutput();
  }

  return |project://proyecto2/| + args[1];
}

int runCli(list[str] args) {
  loc source = inputLoc(args);
  loc target = outputLoc(args);
  writeHighlightedHTML(source, target);
  println("Highlight HTML: <target>");
  return 0;
}

int main(list[str] args=[]) {
  return runCli(args);
}
