---
name: resolve-identifier
description: Resolve a scholarly identifier (DOI/PMID/PMCID/ISBN/ISSN/arXiv/ADS/WHO IRIS) to structured CSL JSON metadata.
---

# resolveIdentifier

Resolves a single bibliographic identifier to canonical CSL JSON metadata via the Scholar Sidekick resolver chain (Crossref → PubMed → DataCite → arXiv → ADS → ISBN → WHO IRIS, with deterministic fallback order).

## When to use

- The user provides a single DOI, PMID, PMCID, ISBN, ISSN, arXiv ID, ADS bibcode, or WHO IRIS URL and wants the underlying metadata.
- An agent needs structured fields (author list, title, container, year, identifiers) before formatting or exporting.

## Inputs

- `identifier` (string, required) — DOI like `10.1038/nphys1170`, PMID like `34812345`, ISBN, etc. Detection is automatic.

## Outputs

CSL JSON with at least `title`, `author[]`, `issued`, `container-title`, `DOI`/`PMID`/`PMCID`/`URL` (depending on source). Errors return `{ ok: false, code, error }`.

## Underlying surfaces

- **REST**: `POST /api/format` with `text: "<identifier>"` and `output: "json"` returns the resolved item alongside the formatted string.
- **MCP tool**: `resolveIdentifier` in [`scholar-sidekick-mcp`](https://github.com/mlava/scholar-sidekick-mcp).

## Example

```bash
curl -sS -X POST "https://scholar-sidekick.com/api/format" \
  -H "Content-Type: application/json" \
  -d '{"text":"10.1038/nphys1170","style":"vancouver","output":"text"}'
```

## See also

- `formatCitation` for rendering, `verifyCitation` for fabrication detection.
- [`/llms.txt`](https://scholar-sidekick.com/llms.txt) for the full service description.
