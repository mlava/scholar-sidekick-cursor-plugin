---
name: check-open-access
description: Check whether a scholarly work is openly accessible and return the best legal free URL, license, and version (via Unpaywall).
---

# checkOpenAccess

Resolves an identifier to a DOI, then looks up its open-access status via Unpaywall. Returns the best legal full-text location (preferring publisher copies, then repository copies), the licence, and the version (preprint, accepted, or published).

## When to use

- A user asks "is there a free copy?" or "where can I read this without a paywall?"
- An agent is preparing a reading list and wants to surface freely-readable links.
- A library or syllabus tool wants to filter recommendations by accessibility.

## Inputs

- `id` (string, required) — one identifier per call: DOI, PMID, PMCID, arXiv ID, ISBN, or ADS bibcode. Pass it verbatim. Items with no DOI return a "no DOI" result.

## Outputs

```json
{
  "ok": true,
  "doi": "10.1371/journal.pone.0173664",
  "result": {
    "isOa": true,
    "oaStatus": "gold" | "green" | "hybrid" | "bronze" | "closed",
    "title": "...",
    "bestLocation": {
      "url": "https://...",
      "hostType": "publisher" | "repository",
      "license": "cc-by" | null,
      "version": "publishedVersion" | "acceptedVersion" | "submittedVersion" | null
    },
    "locations": [{ "url": "https://...", "hostType": "...", "license": null, "version": null }]
  }
}
```

- `resolvedFrom` (`{ type, value }`) is present only when the input was not already a DOI.
- When no DOI can be found, `result` is `null` and `reason` is one of `no_doi` / `timeout` / `upstream`.

## Underlying surfaces

- **REST**: `POST /api/oa-check` with `{ "id": "…" }`.
- **Web UI**: [`/tools/open-access-checker`](https://scholar-sidekick.com/tools/open-access-checker).
- **MCP tool**: `checkOpenAccess`.

## Example

```bash
curl -sS -X POST "https://scholar-sidekick.com/api/oa-check" \
  -H "Content-Type: application/json" \
  -d '{"id":"10.1371/journal.pone.0173664"}'
```

## See also

- `resolveIdentifier` for full metadata.
- `checkRetraction` for retraction-awareness on the same identifier.
