---
name: format-citation
description: Format one or more scholarly identifiers as citations in a chosen style (Vancouver, AMA, APA, IEEE, CSE, or any CSL style ID).
---

# formatCitation

Takes a free-text block of identifiers (one per line, mixed types OK) and returns formatted citations in the requested style. Five builtins ship as plain-text formatters; any other style routes through citeproc-js with a CSL stylesheet.

## When to use

- The user pastes a list of DOIs/PMIDs/ISBNs and wants Vancouver/APA/IEEE/etc. references.
- An agent needs to render a bibliography for a draft manuscript.

## Inputs

- `text` (string, required) — One identifier per line, or free text containing identifiers.
- `style` (string, optional) — Builtin: `vancouver` (default), `ama`, `apa`, `ieee`, `cse`. Or any CSL style ID (e.g. `nature`, `lancet`, `chicago-author-date`).
- `locale` (string, optional) — CSL locale, e.g. `en-US`, `en-GB`.
- `output` (string, optional) — `"text"` (default) or `"html"`.
- `footnotes` (boolean, optional) — Render HTML output as footnotes.

## Outputs

`{ ok: true, items: [{ ok, formatted, _source }, ...] }`. Mixed success — per-item ok flag lets the agent surface partial failures.

## Underlying surfaces

- **REST**: `POST /api/format` (or `/api/format/stream` for NDJSON streaming).
- **MCP tool**: `formatCitation`.

## Example

```bash
curl -sS -X POST "https://scholar-sidekick.com/api/format" \
  -H "Content-Type: application/json" \
  -d '{"text":"10.1038/nphys1170\n34812345","style":"apa","output":"text"}'
```

## See also

- `exportCitation` for file-format bibliographies (RIS, BibTeX, etc.).
- [`/docs.md`](https://scholar-sidekick.com/docs.md) for full API reference.
