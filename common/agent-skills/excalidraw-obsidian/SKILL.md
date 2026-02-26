---
name: excalidraw-obsidian
description: Create or update Excalidraw diagrams in the Obsidian vault as .md files compatible with the obsidian-excalidraw-plugin.
argument-hint: [description of what to draw]
---

# Excalidraw Obsidian Diagrams

Create or update Excalidraw drawings in the Obsidian vault at `~/notes/obsedian/Excalidraw/`.

## File Format

Files use the `.md` extension (NOT `.excalidraw` or `.excalidraw.md`) and follow this structure:

```
---

excalidraw-plugin: parsed
tags: [excalidraw]

---
==Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document.==


# Excalidraw Data

## Text Elements
<text content> ^<element-id>

## Drawing
` ` `json
{
  "type": "excalidraw",
  "version": 2,
  "source": "https://excalidraw.com",
  "elements": [...],
  "appState": {
    "viewBackgroundColor": "#ffffff",
    "gridSize": null
  },
  "files": {}
}
` ` `
%%
```

## Key Rules

1. **File extension**: Always `.md`, never `.excalidraw` or `.excalidraw.md`
2. **Text Elements section**: List every text element's content followed by `^<id>` — one blank line between each
3. **Drawing section**: Wrapped in `%%` at the end (the `%%` before `## Drawing` and after the closing triple backticks)
4. **JSON format**: Use raw `json` code fence, NOT `compressed-json`. The plugin will compress it on load.
5. **Frontmatter**: Must include `excalidraw-plugin: parsed` and `tags: [excalidraw]`

## Updating Existing Files

The plugin compresses JSON into `compressed-json` format on save. You CANNOT surgically edit compressed content. To update an existing file:

1. Reconstruct the full elements array from context or by re-reading the `.excalidraw` source if available
2. Rewrite the entire `## Drawing` section with raw `json`
3. Update the `## Text Elements` section to include any new text elements
4. The plugin will re-compress on next load

## Element Format Reference

Use the Excalidraw MCP `read_me` tool to get the full element format reference including color palettes, element types, and examples. Call it once per session before creating diagrams.

## Workflow

1. Call the Excalidraw MCP `read_me` tool (once per session) to get element format reference
2. Optionally use `create_view` to preview the diagram inline first
3. Write the `.md` file to the Excalidraw folder
4. If updating, rewrite the full file since compressed JSON can't be edited in place

## Arguments

$ARGUMENTS — Description of what to draw or which file to update
