module ExampleSet

import IO;
import Verilang::AST;
import Verilang::Load;
import Verilang::Pretty;

Program demoSetAst() {
    loc example = |project://proyecto2/examples/set.veri|;
    return loadProgram(example);
}

str demoSet() = prettyProgram(demoSetAst());

int main(list[str] _args=[]) {
    println(demoSet());
    return 0;
}
