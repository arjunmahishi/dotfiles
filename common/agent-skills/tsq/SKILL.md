---
name: tsq
description: Use tsq to extract structured code information with tree-sitter queries, symbols, outlines, and references across languages.
---

## Purpose
Use this skill when you need structured, language-aware insight into code: declarations, references, outlines, and precise AST pattern matches. tsq is best for targeted extraction and analysis that would be noisy with text search.

## When to use what

- `tsq query`: Use for custom AST patterns and precise structural matching. Best when you need specific constructs or relationships in the syntax tree.
- `tsq symbols`: Use to catalog declarations (functions, types, methods, variables) across files for indexing or summaries.
- `tsq outline`: Use to get a high-level file structure (package/module, imports, top-level symbols) when you need quick orientation.
- `tsq refs`: Use to find usages of a symbol across a codebase.
- `tsq example-queries`: Use only to discover query syntax and patterns. It is a reference, not a required step.

## Core concepts

- Tree-sitter queries use capture names (e.g., `@name`) to extract data. Queries without captures return matches with no usable payload.
- Use `--file` for a single file, `--path` to scan a directory.
- Prefer `symbols` or `outline` when you do not need a custom query.

## Recommended workflow

1. Start with `outline` for a quick map of a file.
2. Use `symbols` to gather relevant declarations.
3. Use `refs` to trace usage.
4. Use `query` for precise AST patterns or advanced filtering.

## Minimal cross-language examples

These patterns are representative; adjust node types and names for the target language grammar.

```scm
; Function declarations (capture the whole node)
(function_declaration) @fn

; Function names only
(function_declaration name: (identifier) @name)

; Method calls (object.method())
(call_expression
  function: (selector_expression
    operand: (_) @receiver
    field: (field_identifier) @method))

; Type definitions (struct/class-like)
(type_declaration
  (type_spec
    name: (type_identifier) @name
    type: (_) @type_def))

; Imports (module paths)
(import_spec path: (interpreted_string_literal) @path)
```

# JSON output schemas

Tip: pipe `tsq ...` output into `jq` to extract exactly what you need, e.g.
`tsq symbols --path . --compact | jq '.[].symbols[] | select(.kind=="function") | .name'`

## `tsq query` -> `[]QueryMatch`

```json
[
  {
    "file": "path/to/file.go",
    "pattern": 0,
    "captures": [
      {
        "name": "name",
        "node_type": "identifier",
        "text": "Foo",
        "range": {
          "start": { "line": 12, "column": 6 },
          "end": { "line": 12, "column": 9 }
        }
      }
    ]
  }
]
```

## `tsq symbols` -> `[]SymbolsResult`

```json
[
  {
    "file": "path/to/file.go",
    "symbols": [
      {
        "name": "Foo",
        "kind": "function|type|method|var|const|interface|struct|field",
        "visibility": "public|private",
        "file": "path/to/file.go",
        "range": {
          "start": { "line": 12, "column": 1 },
          "end": { "line": 20, "column": 2 }
        },
        "signature": "func Foo(...) ...",
        "source": "func Foo() { ... }",
        "receiver": "MyType",
        "doc": "Doc comment text"
      }
    ]
  }
]
```

## `tsq outline` -> `FileOutline`

```json
{
  "file": "path/to/file.go",
  "package": "main",
  "imports": [{ "path": "fmt", "alias": "f" }],
  "symbols": [
    {
      "name": "Foo",
      "kind": "function|method|struct|interface|type|const|var",
      "visibility": "public|private",
      "file": "path/to/file.go",
      "range": {
        "start": { "line": 12, "column": 1 },
        "end": { "line": 20, "column": 2 }
      },
      "source": "func Foo() { ... }",
      "receiver": "MyType"
    }
  ]
}
```

## `tsq refs` -> `RefsResult`

```json
{
  "symbol": "Foo",
  "references": [
    {
      "symbol": "Foo",
      "kind": "call|type_ref|field_access|identifier|reference",
      "file": "path/to/file.go",
      "position": { "line": 42, "column": 7 },
      "context": "Foo()"
    }
  ]
}
```

## Errors (stderr)

```json
{ "error": "message" }
```
