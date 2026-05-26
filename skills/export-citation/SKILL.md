---
name: export-citation
description: Export resolved citations to a reference-manager file format (RIS, BibTeX, CSL JSON, EndNote XML, RefWorks, NBIB, Zotero RDF, CSV, or plain text).
---

# exportCitation

Resolves identifiers and serialises the resulting items to a bibliography file. Targets reference managers (Zotero, Mendeley, EndNote, RefWorks) and LaTeX workflows (BibTeX/Overleaf).

## When to use

- The user wants to import citations into Zotero, Mendeley, EndNote, or a LaTeX project.
- An agent needs a `.ris`, `.bib`, or `.json` artifact to attach to a draft.

## Inputs

- `text` (string) OR `items` (CSL-JSON[]) — Input identifiers or pre-resolved items.
- `format` (string, required) — `ris`, `bibtex`, `csl-json`, `endnote-xml`, `refworks`, `nbib`, `rdf`, `csv`, or `txt`.
- `style` (string, optional) — Only used when `format=txt` (selects the formatter style).

## Outputs

Plain-text body in the requested format with appropriate `Content-Type` and `Content-Disposition: attachment; filename=...` headers.

## Underlying surfaces

- **REST**: `POST /api/export`.
- **MCP tool**: `exportCitation`.

## Example

```bash
curl -sS -X POST "https://scholar-sidekick.com/api/export" \
  -H "Content-Type: application/json" \
  -d '{"text":"10.1038/nphys1170\n9780306406157","format":"ris"}' \
  -o citations.ris
```

## See also

- `formatCitation` for inline-rendered references.
- [`/docs.md#post-apiexport`](https://scholar-sidekick.com/docs.md) for full format reference.
