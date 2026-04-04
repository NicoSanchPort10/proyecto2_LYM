module Main

import IO;
import Verilang::AST;
import Verilang::Load;

Program demoProgram() {
    str sample = "defmodule Demo using Base defspace Naturals end end";
    return loadProgram(sample);
}

int main(list[str] _args=[]) {
    println(demoProgram());
    return 0;
}
