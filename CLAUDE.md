# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

A Rascal implementation of **Verilang**, a toy language for defining algebraic/logical structures (modules, spaces, operators, variables, rules, and expressions). The project covers the full language-processing pipeline: concrete syntax → parse tree → AST → pretty-print → round-trip verification → HTML highlighting → TypePal type checking → VSCode language server.

## Build

```bash
mvn org.rascalmpl:rascal-maven-plugin:0.8.2:compile
```

Compiled `.tpl` files land in `target/classes/rascal/`. The `errorsAsWarnings` flag in `pom.xml` means Maven will succeed even if Rascal reports type errors — check output carefully.

## Running the pipelines

All commands below require Rascal + rascal-lsp JARs on the classpath. Replace the path prefix with the actual VSCode extension version installed locally.

```bash
JAR="~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal.jar:~/.vscode/extensions/usethesource.rascalmpl-0.13.3/assets/jars/rascal-lsp.jar"
java -cp $JAR org.rascalmpl.shell.RascalShell <Module> [args]
```

| Task | Module | Args |
|------|--------|------|
| Parse + round-trip a `.veri` file | `CompileVerilang` | `examples/set.veri` |
| Smoke-test all example files | `VerifyVerilang` | _(none)_ |
| Generate HTML highlight | `HighlightVerilang` | `examples/set.veri target/out.html` |
| Print demo AST | `ExampleSet` | _(none)_ |

## Architecture

The pipeline flows through these layers, each in `src/main/rascal/Verilang/`:

| File | Role |
|------|------|
| `Syntax.rsc` | Concrete grammar (`start syntax Program`, lexicals, layout) |
| `Parse.rsc` | Wraps Rascal's `parser(#start[Program])` |
| `AST.rsc` | Abstract data types mirroring the grammar |
| `Load.rsc` | `loadParseTree` / `loadProgram` using `implode` to convert parse tree → AST |
| `Pretty.rsc` | Human-readable string rendering of AST nodes (used for round-trip comparison) |
| `Run.rsc` | Round-trip check: parse → `unparse` → reparse → compare `prettyProgram` output |
| `Highlight.rsc` | Recursive parse-tree walk that wraps tokens in `<span>` tags |
| `Generate.rsc` | Alternative back-end: renders AST to a structured summary string (not Verilang surface syntax) |
| `Checker.rsc` | TypePal type checker — collects scopes/definitions/uses for spaces, operators, vars |
| `Plugin.rsc` | VSCode language server registration (call `main()` in the Rascal Terminal to activate `.vl` support) |

Top-level entry-point modules in `src/main/rascal/`:

- `CompileVerilang.rsc` — CLI for the round-trip pipeline
- `VerifyVerilang.rsc` — batch smoke test
- `HighlightVerilang.rsc` — HTML generation
- `ExampleSet.rsc` / `ExampleSetNormalized.rsc` — hardcoded AST demos
- `Main.rsc` — minimal inline demo

## Key design details

**Round-trip validation** (`Run.rsc`): correctness is verified by comparing `prettyProgram(original)` with `prettyProgram(reparse(unparse(parseTree)))`. This means `Pretty.rsc` is the canonical equality surface — changes to it affect what "round-trip ok" means.

**Two separate back-ends**: `Pretty.rsc` reconstructs Verilang surface syntax for round-trip checks; `Generate.rsc` produces a structured summary (with `=== Module: ... ===` headers). They serve different purposes and should not be conflated.

**TypePal checker** (`Checker.rsc`): uses pattern-matching on concrete syntax trees (not the AST). It defines three `IdRole`s (`spaceId`, `operatorId`, `verilangVarId`) and three `AType`s. Quantified expressions introduce a local scope for the bound variable. `Plugin.rsc` wires the checker into the language server via `verilangAnalyzer`.

**File extensions**: examples use `.veri`; the language server registers the `.vl` extension via `Plugin.rsc`.

**Project-relative `loc` URIs**: source paths are encoded as `|project://proyecto2/...|`. The project name must match `META-INF/RASCAL.MF`.

## REPL quick-start

```rascal
import Verilang::Load;
loadProgram("defmodule Demo using Base defspace Naturals end end");
```
