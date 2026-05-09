# Verilang en Rascal

Implementación completa del lenguaje Verilang en Rascal: gramática, AST, round-trip, highlighting, type checker con TypePal e integración con el language server de VSCode.

## Estructura

```
src/main/rascal/
  Verilang/
    Syntax.rsc       — gramática concreta
    Parse.rsc        — parser de Program
    AST.rsc          — sintaxis abstracta
    Load.rsc         — carga parse tree y AST
    Pretty.rsc       — impresión legible del AST
    Generate.rsc     — genera representación estructurada desde el AST
    Run.rsc          — pipeline desde archivo y verificación de round-trip
    Highlight.rsc    — generación de HTML con highlighting
    Checker.rsc      — type checker completo con TypePal
    Plugin.rsc       — language server para VSCode (soporte .vl)
  CheckVerilang.rsc  — runner de tests del type checker
  CompileVerilang.rsc— entrypoint del pipeline round-trip
  VerifyVerilang.rsc — smoke test sobre varios programas
  ExampleSet.rsc     — ejemplo principal del AST
  HighlightVerilang.rsc — genera HTML resaltado para un .veri
```

## Qué cubre la implementación

**Construcciones del lenguaje:**
- módulos `defmodule`
- imports `using`
- espacios `defspace` con herencia opcional (`< ParentSpace`)
- operadores `defoperator` con signatura de tipo (e.g. `Nat -> Nat -> Nat`)
- variables `defvar` con anotación de tipo
- reglas `defrule`
- expresiones cuantificadas `forall` y `exists` con dominio
- operadores lógicos e infijos: `and`, `or`, `=>`, `≡`, `=`, `<>`, `<`, `>`, `<=`, `>=`, `in`, `isIn`
- literales: enteros, flotantes, booleanos, caracteres y strings
- atributos sueltos y en bloque `[associative id:0]`

**Sistema de tipos (TypePal):**
- Registro de espacios, operadores y variables con sus roles e tipos
- Anotación de tipo para los 5 tipos de literales (`Int`, `Float`, `Bool`, `Char`, `String`)
- Verificación de que los tipos usados en `defvar` corresponden a espacios declarados
- Verificación de que el dominio en expresiones cuantificadas (`in <Space>`) existe
- Verificación de aridad: cada aplicación `(op arg1 arg2)` debe usar exactamente los argumentos que la signatura del operador requiere
- Integración con el language server: errores de tipo aparecen subrayados en VSCode

## Compilación

Desde la raíz del proyecto:

```bash
mvn org.rascalmpl:rascal-maven-plugin:0.8.2:compile
```

Verificar que el output termine con `BUILD SUCCESS` y que no aparezcan líneas `[ERROR]` antes del resultado.

## Variables de entorno para los comandos

Definir una vez antes de correr cualquier comando:

```bash
JAR="/Users/<usuario>/.vscode/extensions/usethesource.rascalmpl-0.13.5/assets/jars/rascal.jar:/Users/<usuario>/.vscode/extensions/usethesource.rascalmpl-0.13.5/assets/jars/rascal-lsp.jar"
TYPEPAL="/Users/<usuario>/.m2/repository/org/rascalmpl/typepal/0.7.6/typepal-0.7.6.jar"
CLASSES="/ruta/al/proyecto/target/classes"
```

> Reemplazar `/Users/<usuario>` y `/ruta/al/proyecto` con los valores reales de la máquina.

## Pruebas

### 1. Type checker — verificación de tipos

Corre el checker sobre 4 programas de prueba y valida el número de errores esperado:

```bash
java -cp "$CLASSES:$TYPEPAL:$JAR" org.rascalmpl.shell.RascalShell CheckVerilang
```

Salida esperada:

```
=== Checking: .../examples/test-ok.vl ===
  OK — no errors
  PASS (expected 0 error(s), got 0)

=== Checking: .../examples/test-arity.vl ===
  [ERROR] operator 'succ' expects 1 argument(s) but got 2 at line 10
  [ERROR] operator 'plus' expects 2 argument(s) but got 1 at line 11
  PASS (expected 2 error(s), got 2)

=== Checking: .../examples/test-bad-space.vl ===
  [ERROR] Undefined space `Nonexistent` at line 2
  PASS (expected 1 error(s), got 1)

=== Checking: .../examples/test-literals.vl ===
  OK — no errors
  PASS (expected 0 error(s), got 0)

Results: 4 passed, 0 failed
```

### 2. Pipeline round-trip desde archivo

```bash
java -cp "$CLASSES:$TYPEPAL:$JAR" org.rascalmpl.shell.RascalShell CompileVerilang examples/set.veri
```

Salida esperada:

```
Input: |project://proyecto2/examples/set.veri|
Round-trip: ok

Generated Verilang:
...
```

### 3. Smoke test sobre varios programas

```bash
java -cp "$CLASSES:$TYPEPAL:$JAR" org.rascalmpl.shell.RascalShell VerifyVerilang
```

Salida esperada:

```
examples/set.veri: ok
examples/set-normalized.veri: ok
examples/exists.veri: ok
examples/literals.veri: ok
```

### 4. Generar HTML con highlighting

```bash
java -cp "$CLASSES:$TYPEPAL:$JAR" org.rascalmpl.shell.RascalShell HighlightVerilang examples/set.veri target/verilang-highlight.html
```

Salida esperada: `Highlight HTML: |project://proyecto2/target/verilang-highlight.html|`

Luego abrir `target/verilang-highlight.html` en el navegador para ver el código resaltado.

### 5. Language server en VSCode

Para activar el soporte `.vl` en el editor (errores de tipo subrayados, go-to-definition):

1. Compilar el proyecto con Maven.
2. Abrir el terminal de Rascal en VSCode: `Ctrl+Shift+P` → **Create Rascal Terminal**.
3. En el terminal de Rascal ejecutar:

```rascal
import Verilang::Plugin;
main();
```

4. Abrir cualquier archivo `.vl` de la carpeta `examples/`. Los errores de tipo aparecen subrayados en rojo.

Para verificar el checker directamente desde el terminal de Rascal:

```rascal
import Verilang::Parse;
import Verilang::Checker;
import analysis::typepal::TypePal;

getMessages(checkProgram(parseProgram(|project://proyecto2/examples/test-arity.vl|)));
```

## Ejemplos incluidos

| Archivo | Descripción |
|---------|-------------|
| `examples/set.veri` | Ejemplo principal con espacios, operadores, variables y reglas |
| `examples/set-normalized.veri` | Variante con bloque de atributos `[...]` |
| `examples/exists.veri` | Cubre expresiones `exists` |
| `examples/literals.veri` | Cubre literales numéricos y operadores relacionales |
| `examples/test-ok.vl` | Programa bien tipado — espera 0 errores del checker |
| `examples/test-arity.vl` | Violaciones de aridad — espera 2 errores |
| `examples/test-bad-space.vl` | Referencia a espacio inexistente — espera 1 error |
| `examples/test-literals.vl` | Todos los tipos de literales — espera 0 errores |
