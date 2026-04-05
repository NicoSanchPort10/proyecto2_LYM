module Main

import IO;
import Verilang::AST;
import Verilang::Load;
import Verilang::Pretty;

Program demoProgramAst() {
    str sample = "defmodule Demo using Base defspace Naturals end end";
    return loadProgram(sample);
}

str demoProgram() = prettyProgram(demoProgramAst());

int main(list[str] _args=[]) {
    println(demoProgram());
    return 0;
}
