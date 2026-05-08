# Handoff — Proyecto 3

## Estado actual

**Parte A (Type System & Checker) — COMPLETADA Y VERIFICADA.**
Compilada, ejecutada y todos los tests pasan (4/4).

Parte B (Generation + Integration) — pendiente.

## Archivos modificados (respecto al último commit)

| Archivo | Qué cambió |
|---------|-----------|
| `src/main/rascal/Verilang/Checker.rsc` | Reescritura completa — ver abajo |
| `src/main/rascal/Verilang/Plugin.rsc` | Actualizado por commit anterior (cambio de firma del parser) |
| `src/main/rascal/CheckVerilang.rsc` | Nuevo — runner de tests del checker (CLI) |
| `CLAUDE.md` | Creado en sesión anterior |
| `examples/test-arity.vl` | Nuevo — 2 errores de aridad confirmados |
| `examples/test-bad-space.vl` | Nuevo — 1 error de scope confirmado |
| `examples/test-ok.vl` | Nuevo — 0 errores confirmado |
| `examples/test-literals.vl` | Nuevo — 0 errores confirmado |

## Qué hace el Checker.rsc

- `operatorType(int arity)` — lleva aridad del operador (cantidad de parámetros)
- `sigArity(Type)` — cuenta flechas en la signatura concreta para computar aridad
- Collectors para: `Module`, `spaceDecl`/`spaceDeclNoParent`, `SpaceParent`, `operatorDecl`/`operatorDeclNoAttrs`/`operatorDeclBlock`, `Type` (function+named), `varDecl`, `VarItem`, `ruleDecl`, `RuleTerm`, `expressionDecl`/`expressionDeclNoAttrs`, `quantifiedExpr`, `logicExpr`, `LogicExpr`, `LogicStep`, `SimpleExpr` (4 variantes), `Application`, `Literal` (5 variantes con `c.fact`)
- Fix: `quantifiedExpr` hace `c.use(domain, {spaceId()})` — verifica que el dominio existe como espacio
- Regla de aridad (Task 6): `c.require(...)` en `Application` que usa `s.requireTrue(actualArity == expected, error(...))`

## Resultados de tests verificados

```
test-ok.vl       → 0 errores   ✓ PASS
test-arity.vl    → 2 errores   ✓ PASS  (succ/2 y plus/1)
test-bad-space.vl→ 1 error     ✓ PASS  (Undefined space Nonexistent)
test-literals.vl → 0 errores   ✓ PASS
```

Round-trip tests (VerifyVerilang) siguen pasando: set.veri, set-normalized.veri, exists.veri, literals.veri → ok.

## Comando para verificar

```bash
JAR="/Users/nicosanchport/.vscode/extensions/usethesource.rascalmpl-0.13.5/assets/jars/rascal.jar:/Users/nicosanchport/.vscode/extensions/usethesource.rascalmpl-0.13.5/assets/jars/rascal-lsp.jar"
TYPEPAL="/Users/nicosanchport/.m2/repository/org/rascalmpl/typepal/0.7.6/typepal-0.7.6.jar"
CLASSES="/Users/nicosanchport/Documents/RascalProjects/proyecto2/target/classes"
java -cp "$CLASSES:$TYPEPAL:$JAR" org.rascalmpl.shell.RascalShell CheckVerilang
```

## Pendientes (Parte B)

1. **Generate.rsc**: agregar tipo de cada variable en el output de consola (requiere integrar info del TModel)
2. **Run.rsc**: llamar `checkProgram()` e imprimir los mensajes de tipo junto al output de round-trip
3. **Documentación**: explicar arquitectura del checker

## Tasks A verificadas

- [x] Task 4 — `c.fact` para literales (Int, Float, Bool, Char, String)
- [x] Task 5 — `quantifiedExpr` introduce scope local + verifica dominio con `c.use(domain, {spaceId()})`
- [x] Task 6 — Regla de aridad en `Application` con `c.require + s.requireTrue`
- [x] Collectors completos para toda la gramática
- [x] Compilación sin errores de tipo Rascal
- [x] 4/4 tests de checker pasan
- [x] Round-trip tests no regresaron
