module VerifyVerilang

import IO;
import Verilang::Run;

list[list[str]] sampleInputs()
  = [
      [],
      ["examples/set-normalized.veri"],
      ["examples/exists.veri"],
      ["examples/literals.veri"]
    ];

str label(list[str] args) {
  if (args == []) {
    return "examples/set.veri";
  }

  return args[0];
}

str status(bool ok) {
  if (ok) {
    return "ok";
  }

  return "failed";
}

int main(list[str] _args=[]) {
  bool allOk = true;

  for (args <- sampleInputs()) {
    bool ok = roundTripOk(args);
    println("<label(args)>: <status(ok)>");
    allOk = allOk && ok;
  }

  if (allOk) {
    return 0;
  }

  return 1;
}
