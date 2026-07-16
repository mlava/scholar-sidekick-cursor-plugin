---
name: audit-bibliography
description: Audit a whole bibliography (BibTeX, RIS, or CSL-JSON) in one call — per-entry fabrication verdict and retraction status, plus a corpus summary.
---

# auditBibliography

The batch counterpart to `verifyCitation`. Takes a whole bibliography — raw BibTeX / RIS / CSL-JSON text, or a `claims[]` array of pre-parsed references — and runs the same fabrication check on every entry: does the claimed title match the paper the identifier actually resolves to (the real-DOI/fake-title pattern documented by Topaz et al., Lancet 2026)? Each resolved entry also gets a retraction lookup. The result is a per-entry verdict table plus a corpus summary.

This audits citation **identity** (does each identifier resolve to the claimed work, and is it retracted). It does **not** check whether a source supports the claim it is cited for.

## When to use

- A user pastes a reference list, a `.bib` / `.ris` file, or an LLM-generated bibliography and asks "check all of these" / "which of these are fake or retracted?"
- An agent is auditing the reference section of a manuscript draft for hallucinations before submission.
- A systematic-review or journal-submission pipeline needs to screen a whole bibliography at once.

## Inputs

Provide exactly one of:

- `bibliography` (string) — raw BibTeX, RIS, or CSL-JSON text. Format is auto-detected; override with `format` (`"bibtex" | "ris" | "csl-json"`).
- `claims` (array) — pre-parsed citations, each `{ "title": "...", plus one identifier (doi/pmid/pmcid/isbn/arxiv/issn/ads/whoIrisUrl) }`.

Optional:

- `checks` (array) — per-entry enrichment. Defaults to `["retraction"]`; pass `[]` to skip.
- `screenWithLlm` (boolean) — opt-in Stage 3 LLM screen per entry (same gating as `verifyCitation`).

Capped at 25 entries per call; excess is dropped and reported via `truncated`.

## Outputs

```json
{
  "ok": true,
  "format": "bibtex" | "ris" | "csl-json" | null,
  "entries": [
    {
      "index": 1,
      "status": "ok" | "error",
      "verdict": "matched" | "mismatch" | "not_found" | "ambiguous",
      "confidence": "high" | "medium" | "low",
      "matched": { "...": "the resolved record, or null" },
      "retraction": { "checked": true, "doi": "...", "isRetracted": false, "notices": [] }
    }
  ],
  "parseErrors": [{ "index": 4, "error": "missing_title", "message": "..." }],
  "truncated": 0,
  "summary": { "total": 3, "matched": 2, "mismatch": 1, "ambiguous": 0, "not_found": 0, "errored": 0, "retracted": 1 }
}
```

Per-entry leniency: an entry that fails to resolve upstream becomes `status: "error"` without failing the batch. Every produced audit returns `200 OK` — the verdicts _are_ the answer. A total verification outage returns `502`.

## Underlying surfaces

- **REST**: `POST /api/audit` with `{ "bibliography": "..." }` or `{ "claims": [ … ] }`.
- **MCP tool**: `auditBibliography` in `scholar-sidekick-mcp` v0.8.3+.

## Example

```bash
curl -sS -X POST "https://scholar-sidekick.com/api/audit" \
  -H "Content-Type: application/json" \
  -d '{"bibliography":"@article{a, title={A real title}, doi={10.1038/nphys1170}}\n@article{b, title={An invented title}, doi={10.1016/j.neuroscience.2023.02.008}}"}'
```

## See also

- `verifyCitation` for a single citation (this is its batch counterpart).
- `checkRetraction` for a standalone retraction check on one work.
- [`/citation-integrity`](https://scholar-sidekick.com/citation-integrity) for the broader trust surface.
