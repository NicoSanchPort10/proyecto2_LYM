# Verilang en Rascal

## Estructura

- `src/main/rascal/Verilang/Syntax.rsc`: gramática concreta
- `src/main/rascal/Verilang/Parse.rsc`: parser de `Program`
- `src/main/rascal/Verilang/AST.rsc`: sintaxis abstracta
- `src/main/rascal/Verilang/Load.rsc`: carga a parse tree y a AST
- `src/main/rascal/Verilang/Pretty.rsc`: impresión legible del AST
- `src/main/rascal/Verilang/Run.rsc`: pipeline desde archivo y verificación de round-trip
- `src/main/rascal/Verilang/Highlight.rsc`: generación de HTML con highlighting
- `src/main/rascal/ExampleSet.rsc`: ejemplo principal del AST
- `src/main/rascal/CompileVerilang.rsc`: entrypoint para correr el pipeline
- `src/main/rascal/VerifyVerilang.rsc`: smoke test sobre varios programas
- `src/main/rascal/HighlightVerilang.rsc`: genera un HTML resaltado para un `.veri`

## Qué cubre la implementación

- módulos `defmodule`
- imports `using`
- espacios `defspace`
- operadores `defoperator`
- variables `defvar`
- reglas `defrule`
- expresiones cuantificadas `forall` y `exists`
- operadores lógicos e infijos como `and`, `or`, `in`, `isIn`, `≡`
- atributos sueltos y bloques como `[associative id:0]`

## Compilación

Desde la raíz del proyecto:

```bash
mvn org.rascalmpl:rascal-maven-plugin:0.8.2:compile
```

Ese comando valida que los módulos Rascal compilen.

## Pruebas recomendadas

### 1. Ver el AST del ejemplo principal

```bash
java -cp ~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal.jar:~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal-lsp.jar org.rascalmpl.shell.RascalShell ExampleSet
```

Salida esperada:

- un valor `program(...)`
- dentro del módulo deben aparecer `importDecl`, `spaceDecl`, `operatorDecl`, `varDecl`, `ruleDecl` y `expressionDeclNoAttrs`

### 2. Probar el pipeline desde archivo

```bash
java -cp ~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal.jar:~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal-lsp.jar org.rascalmpl.shell.RascalShell CompileVerilang examples/set.veri
```

Salida esperada:

- `Input: |project://proyecto2/examples/set.veri|`
- `Round-trip: ok`
- el programa Verilang reconstruido en consola

Esto demuestra:

- lectura desde archivo `.veri`
- parseo
- reconstrucción del programa con `unparse`
- reparse y comparación de AST para validar round-trip

### 3. Verificar varios programas válidos

```bash
java -cp ~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal.jar:~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal-lsp.jar org.rascalmpl.shell.RascalShell VerifyVerilang
```

Salida esperada:

- `examples/set.veri: ok`
- `examples/set-normalized.veri: ok`
- `examples/exists.veri: ok`
- `examples/literals.veri: ok`

### 4. Generar una versión HTML con highlighting

```bash
java -cp ~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal.jar:~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal-lsp.jar org.rascalmpl.shell.RascalShell HighlightVerilang examples/set.veri target/verilang-highlight.html
```

Salida esperada:

- `Highlight HTML: |project://proyecto2/target/verilang-highlight.html|`

Luego se puede abrir el archivo:

- `target/verilang-highlight.html`

Ahí se ve el código con palabras reservadas resaltadas en HTML.

## Ejemplos incluidos

- `examples/set.veri`: ejemplo principal
- `examples/set-normalized.veri`: variante con bloque de atributos
- `examples/exists.veri`: cubre `exists`
- `examples/literals.veri`: cubre literales numéricos y operadores relacionales

## Uso desde el REPL

AST legible:

```rascal
import ExampleSet;
demoSet();
```

AST crudo:

```rascal
import ExampleSet;
demoSetAst();
```

Loader directo:

```rascal
import Verilang::Load;
loadProgram("defmodule Demo using Base defspace Naturals end end");
```
