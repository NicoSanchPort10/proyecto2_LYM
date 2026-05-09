module Verilang::Plugin

import util::LanguageServer;
import util::Reflective;
import ParseTree;
import Message;

import Verilang::Syntax;
import Verilang::Checker;

// Parser: crea el parser una sola vez (patron del ejemplo pico)
private Tree (str, loc) verilangParser()
  = parser(#start[Program], allowAmbiguity=false);

Summary verilangAnalyzer(loc l, start[Program] input) {
  TModel tm = checkProgram(input);
  rel[loc, Message] msgs = {<m.at, m> | m <- getMessages(tm), !(m is info)};
  rel[loc, loc]    defs  = getUseDef(tm);
  return summary(l, messages=msgs, definitions=defs);
}

// Servicios registrados (llamado por el language server)
set[LanguageService] verilangServices() = {
  parsing(verilangParser(), usesSpecialCaseHighlighting=false),
  analysis(verilangAnalyzer, providesImplementations=false)
};

// Correr en el Rascal Terminal de VSCode para activar soporte .vl
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
