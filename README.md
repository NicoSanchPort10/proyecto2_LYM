

## Estructura

- `src/main/rascal/Verilang/Syntax.rsc`: gramática concreta
- `src/main/rascal/Verilang/Parse.rsc`: función de parseo
- `src/main/rascal/Verilang/Load.rsc`: punto de entrada para cargar programas
- `examples/set-normalized.veri`: ejemplo completo que parsea con la gramática actual
- `examples/set.veri`: versión cercana al ejemplo original, todavía ambigua

## Qué funciona

La implementación actual ya hace dos cosas:

- parsea programas Verilang a `Tree` con `loadParseTree(...)`
- convierte ese parse tree a AST con `loadProgram(...)`

La gramática actual cubre:

- módulos `defmodule`
- imports `using`
- espacios `defspace`
- operadores `defoperator`
- variables `defvar`
- reglas `defrule`
- expresiones cuantificadas `forall` y `exists`
- operadores lógicos e infijos como `and`, `or`, `in`, `isIn`, `≡`
- bloques de atributos como `[associative id:0]`

## Cómo probarlo

### Opción 1: desde la terminal con el runtime de Rascal

Desde la raíz del proyecto:

```bash
java -cp ~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal.jar:~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal-lsp.jar org.rascalmpl.shell.RascalShell ExampleSetNormalized
```

Si todo está bien, el comando imprime el AST de `examples/set-normalized.veri`.

### Opción 2: desde el REPL de Rascal

En la terminal Rascal de VS Code:

```rascal
import ExampleSetNormalized;
demoSet();
```

Eso devuelve un string limpio con la sintaxis abstracta, sin `src=` ni `comments=()`.

Si quieres el AST crudo:

```rascal
import ExampleSetNormalized;
demoSetAst();
```

También puedes probar el loader directamente:

```rascal
import Verilang::Load;
loadProgram("defmodule Demo using Base defspace Naturals end end");
```

Si quieres ver el parse tree concreto en vez del AST:

```rascal
import Verilang::Load;
loadParseTree("defmodule Demo using Base defspace Naturals end end");
```

## Ejemplo recomendado para evaluar

Usa este archivo:

- `examples/set-normalized.veri`

