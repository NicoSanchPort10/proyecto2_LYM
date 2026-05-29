module Verilang::RunnerJson

import IO;
import ParseTree;
import Message;
import List;
import String;

import Verilang::Parse;
import Verilang::AST;
import Verilang::Checker;
import Verilang::Generate;

import analysis::typepal::TypePal;

str escapeJson(str s) {
    s = replaceAll(s, "\\", "\\\\");
    s = replaceAll(s, "\"", "\\\"");
    s = replaceAll(s, "\n", "\\n");
    s = replaceAll(s, "\r", "\\r");
    s = replaceAll(s, "\t", "\\t");
    return s;
}

str msgToStr(Message m) {
    switch (m) {
        case error(str msg, loc l): return "Error en <l.file> línea <l.begin.line>: <msg>";
        case warning(str msg, loc l): return "Warning en <l.file> línea <l.begin.line>: <msg>";
        default: return "<m>";
    }
}

str buildResumen(program(moduleDecl(str _, list[Declaration] decls))) {
    int nSpaces = 0;
    int nOps = 0;
    int nVars = 0;
    for (Declaration d <- decls) {
        switch (d) {
            case spaceDecl(_, _): nSpaces += 1;
            case spaceDeclNoParent(_): nSpaces += 1;
            case operatorDecl(_, _, _): nOps += 1;
            case operatorDeclBlock(_, _, _): nOps += 1;
            case operatorDeclNoAttrs(_, _): nOps += 1;
            case varDecl(_): nVars += 1;
        }
    }
    return "spaces: <nSpaces>, operators: <nOps>, vars: <nVars>";
}

int main(list[str] args = []) {
    loc src = (args == [])
        ? |project://proyecto2_LYM/examples/test-ok.vl|
        : |file:///|[path = args[0]];

    start[Program] cst;
    try {
        cst = parseProgram(src);
    } catch ParseError(loc l): {
        str errMsg = escapeJson("Parse error at <l>");
        println("{\"success\":false,\"parseOk\":false,\"typeCheckOk\":false,\"semanticOk\":false,\"error\":\"<errMsg>\",\"module\":\"\",\"typeErrors\":[],\"output\":[],\"resumen\":\"\",\"codigoFormateado\":\"\"}");
        return 1;
    } catch value e: {
        str errMsg = escapeJson("<e>");
        println("{\"success\":false,\"parseOk\":false,\"typeCheckOk\":false,\"semanticOk\":false,\"error\":\"<errMsg>\",\"module\":\"\",\"typeErrors\":[],\"output\":[],\"resumen\":\"\",\"codigoFormateado\":\"\"}");
        return 1;
    }

    Program ast = implode(#Program, cst.top);
    TModel tm = checkProgram(cst.top);
    list[Message] msgs = getMessages(tm);

    str modName = "";
    if (program(moduleDecl(str n, _)) := ast) modName = n;

    list[str] typeErrors = [msgToStr(m) | m <- msgs, error(_, _) := m];
    bool typeCheckOk = isEmpty(typeErrors);

    str resumen = buildResumen(ast);
    str formatted = generateProgram(ast);

    str errorsJson = "[" + intercalate(",", ["\"<escapeJson(e)>\"" | str e <- typeErrors]) + "]";

    println("{\"success\":<typeCheckOk>,\"parseOk\":true,\"typeCheckOk\":<typeCheckOk>,\"semanticOk\":true,\"module\":\"<escapeJson(modName)>\",\"typeErrors\":<errorsJson>,\"output\":[],\"resumen\":\"<escapeJson(resumen)>\",\"codigoFormateado\":\"<escapeJson(formatted)>\"}");

    return 0;
}
