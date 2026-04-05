module ExampleSetNormalized

import IO;
import Verilang::AST;
import Verilang::Load;

Program demoSet() {
    loc example = |project://proyecto2/examples/set-normalized.veri|;
    return loadProgram(example);
}

int main(list[str] _args=[]) {
    println(demoSet());
    return 0;
}
