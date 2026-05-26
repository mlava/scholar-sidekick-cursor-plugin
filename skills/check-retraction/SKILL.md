---
name: check-retraction
description: Check whether a scholarly work has been retracted, corrected, or had an expression of concern raised (via Crossref + Retraction Watch).
---

# checkRetraction

Looks up the live retraction status of an identifier against Crossref's update relationships and the Retraction Watch database. The route resolves any supported identifier to a DOI first, then checks it. Returns retraction / correction / expression-of-concern flags plus the notice records.

## When to use

- A user asks "is this paper still valid?" or "has this been retracted?"
- An agent is about to cite a paper in a clinical, legal, or academic context where retraction-awareness matters.
- A reviewer wants to flag retracted references in a manuscript.

## Inputs

- `id` (string, required) — one identifier per call: DOI, PMID, PMCID, arXiv ID, or ADS bibcode. Pass it verbatim (`PMID:` and similar prefixes are tolerated). Books/ISBNs have no DOI, so they return a "no DOI" result.

## Outputs

```json
{
  "ok": true,
  "doi": "10.1016/s0140-6736(97)11096-0",
  "resolvedFrom": { "type": "pmid", "value": "9500320" },
  "result": {
    "isRetracted": true,
    "hasCorrections": false,
    "hasConcern": false,
    "notices": [
      {
        "type": "retraction",
        "label": "Retraction",
        "doi": "...",
        "date": "1998-03-06",
        "source": "crossref"
      }
    ],
    "title": "..."
  }
}
```

- `resolvedFrom` is present only when the input was not already a DOI.
- When no DOI can be found, `result` is `null` and `reason` is one of `no_doi` / `timeout` / `upstream`.

## Underlying surfaces

- **REST**: `POST /api/retraction-check` with `{ "id": "…" }`.
- **Web UI**: [`/tools/retraction-checker`](https://scholar-sidekick.com/tools/retraction-checker).
- **MCP tool**: `checkRetraction`.

## Example

```bash
curl -sS -X POST "https://scholar-sidekick.com/api/retraction-check" \
  -H "Content-Type: application/json" \
  -d '{"id":"10.1016/s0140-6736(97)11096-0"}'
```

## See also

- `verifyCitation` for fabrication detection (different concern — fake vs. retracted).
- `checkOpenAccess` for legal-copy lookup.
