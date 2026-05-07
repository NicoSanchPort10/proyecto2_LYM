module Verilang::Plugin

import util::LanguageServer;
import util::Reflective;
import ParseTree;
import Message;

import Verilang::Syntax;
import Verilang::Parse;
import Verilang::Checker;

// Parser service: wraps our parseProgram
Tree verilangParser(str input, loc origin)
  = parse(#start[Program], input, origin);

// Analysis service: runs TypePal type checker and produces a Summary
Summary verilangAnalyzer(loc l, Tree input) {
  TModel tm = checkProgram(input);
  rel[loc, Message] msgs = {<m.at, m> | m <- getMessages(tm), !(m is info)};
  rel[loc, loc]    defs  = getUseDef(tm);
  return summary(l, messages=msgs, definitions=defs);
}

// The set of IDE services for Verilang (called by the registered language server)
set[LanguageService] verilangServices() = {
  parsing(verilangParser),
  analysis(verilangAnalyzer, providesImplementations=false)
};

// Call this in the VSCode Rascal REPL to activate .vl support in the editor
void main() {
  registerLanguage(
    language(
      pathConfig(),
      "Verilang",
      {"vl"},
      "Verilang::Plugin",
      "verilangServices"
    )
  );
}
