---
name: verify-citation
description: Verify whether a claimed citation matches the actual paper at its identifier (detects the real-DOI/fake-title fabrication pattern common in LLM hallucinations).
---

# verifyCitation

Cross-checks a _claimed_ citation (title, plus optional authors/year/container and one identifier) against the metadata resolved from that identifier. Catches the dominant fabrication pattern documented by Topaz et al. (Lancet, 2026): a real, resolvable DOI paired with an invented title and authors.

`resolveIdentifier` alone never catches this — it returns whatever the registry has for the identifier. `verifyCitation` is the only tool that compares the _claim_ against _reality_.

## When to use

- A user pastes a citation from an LLM transcript and asks "is this real?"
- An agent is auditing references in a manuscript draft for hallucinations.
- A reviewer wants to flag suspected fabricated citations before submission.

## Inputs

Wrap the citation fields inside a `claimed` object (one citation per call):

- `claimed` (object, required):
  - `title` (string, required) — the title exactly as cited.
  - one identifier — `doi`, `pmid`, `pmcid`, `isbn`, `arxiv`, `issn`, `ads`, or `whoIrisUrl`.
  - `authors` (array, optional) — `[{ "family": "...", "given": "..." }]`; sharpens the verdict.
  - `year` (number, optional); `container` (string, optional — the journal or book title).
- `options` (object, optional) — e.g. `{ "bypassCache": true }`.

## Outputs

```json
{
  "ok": true,
  "verdict": "matched" | "mismatch" | "not_found" | "ambiguous",
  "confidence": "high" | "medium" | "low",
  "matched": { "...": "the resolved CSL item, when one was found" }
}
```

- `matched` — the claim agrees with the record at the identifier.
- `mismatch` — the identifier resolves but the title does not (the fabrication pattern; flag it clearly).
- `ambiguous` — the identifier resolves to one paper but the claimed title matches a _different_ real paper (a wrong-identifier error, not a fabrication).
- `not_found` — neither identifier nor title resolves anywhere.

Every produced verdict returns `200 OK` — the verdict _is_ the answer, not a failure. 4xx/5xx are reserved for protocol errors.

## Underlying surfaces

- **REST**: `POST /api/verify` with `{ "claimed": { … } }`. One citation per call.
- **Web UI**: [`/tools/citation-verifier`](https://scholar-sidekick.com/tools/citation-verifier).
- **MCP tool**: `verifyCitation` in `scholar-sidekick-mcp` v0.7.0+.

## Example

```bash
curl -sS -X POST "https://scholar-sidekick.com/api/verify" \
  -H "Content-Type: application/json" \
  -d '{"claimed":{"title":"The title exactly as cited","doi":"10.1038/nphys1170","authors":[{"family":"Verlinde"}],"year":2011}}'
```

## See also

- `checkRetraction` for retraction status (different concern — fake vs. retracted).
- [`/citation-integrity`](https://scholar-sidekick.com/citation-integrity) for the broader trust surface.
