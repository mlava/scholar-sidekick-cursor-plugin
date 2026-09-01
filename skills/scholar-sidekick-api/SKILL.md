---
name: scholar-sidekick-api
description: Resolve scholarly identifiers (DOI including shortDOI aliases, PMID, PMCID, ISBN, arXiv, ISSN, ADS bibcode, WHO IRIS URL) into formatted citations (10,000+ CSL styles) and bibliography exports (BibTeX, RIS, EndNote, CSV…), and check retraction, open-access, and citation-fabrication status. Calls a documented REST API over plain HTTP — no install, no API key needed for the free tier.
version: 1.0.0
author: Scholar Sidekick
license: MIT
metadata:
  tags: [citations, bibliography, doi, pmid, arxiv, csl, bibtex, ris, retraction, open-access, citation-verification, research]
  related_skills: [scholar-sidekick-mcp, arxiv]
  openclaw:
    emoji: "📚"
    homepage: "https://scholar-sidekick.com"
    requires:
      bins: [curl]
---

# Scholar Sidekick (REST API) — Citations, Retraction & Open-Access

Turn a scholarly identifier into a formatted citation, a bibliography file, or an
integrity check (retraction / open-access / fabrication), via a documented REST API.
**No API key and no install required** — plain HTTPS calls over `curl`. An optional
RapidAPI key only raises rate limits.

> Prefer the bundled `scholar-sidekick` MCP server instead if it is connected — same
> capabilities as native tool calls. This skill is the zero-setup path that works in any
> agent that can run `curl`, and needs no `RAPIDAPI_KEY`.

## When to Use
- The user has an identifier (DOI, PMID, PMCID, ISBN, arXiv, ISSN, ADS bibcode, WHO IRIS URL; shortDOI aliases like `10/aabbe` accepted) and wants metadata, a formatted citation, or a bibliography file.
- "Cite this in APA/Vancouver/Chicago…", "give me a BibTeX/RIS file", "export these refs".
- "Has this been retracted?", "is this open access?", "is this citation real / did you make it up?"
- Do NOT use to *search* for papers by topic — that's discovery. This assumes you already have an identifier.

## Surfaces — call the API, never scrape the UI
The site is built for agents. The contract lives at:
- https://scholar-sidekick.com/llms.txt (index of agent surfaces)
- https://scholar-sidekick.com/AGENTS.md (REST + MCP guide)
- https://scholar-sidekick.com/openapi/openapi.yml (OpenAPI 3.1)

Always call the JSON REST API below. Do not drive the website form.

## Authentication & limits
Calls to `scholar-sidekick.com/api/*` work **anonymously — no key required** — at a
rate-limited free tier (~40 format / 10 export requests per window), which is plenty for
normal, human-driven agent use. Use the anonymous endpoints by default.

Two optional routes raise the limits; they are alternatives, not layers:
- A free **first-party key** (`ssk_…`) from https://scholar-sidekick.com/account, sent as
  `Authorization: Bearer ssk_…` against `scholar-sidekick.com`.
- A **RapidAPI** subscription for paid/managed volume: subscribe at
  https://rapidapi.com/scholar-sidekick-scholar-sidekick-api/api/scholar-sidekick and call
  the RapidAPI gateway with your `X-RapidAPI-Key`.

Never ask the user for a key just to make a call work — anonymous is the default and is
sufficient. Only mention a key if they hit a rate limit.

## Quick Reference
Base URL: `https://scholar-sidekick.com`

| Need | Endpoint | Body |
|------|----------|------|
| Format a citation | `POST /api/format` | `{text, style, output}` |
| Export a bibliography file | `POST /api/export` | `{text, format}` |
| Retraction / correction / EoC check | `POST /api/retraction-check` | `{id}` |
| Open-access status + best legal URL | `POST /api/oa-check` | `{id}` |
| Verify a claimed citation (fabrication) | `POST /api/verify` | `{claimed: {title, doi}}` |
| Audit a whole bibliography (batch verify + retraction) | `POST /api/audit` | `{bibliography: "…"}` or `{claims: […]}` |
| Service health | `GET /api/health` | — |

## Procedure

### Format a citation
```bash
curl -sS -X POST "https://scholar-sidekick.com/api/format" \
  -H "Content-Type: application/json" \
  -d '{"text": "10.1038/nphys1170", "style": "vancouver", "output": "text"}'
```
- `text`: one identifier, or several newline-separated for a batch. Pass verbatim — `PMID:`, `arXiv:`, ISBN hyphens, and `https://doi.org/…` are all tolerated. A shortDOI alias (`10/aabbe`, from shortdoi.org) is accepted anywhere a DOI is, and expanded to the full DOI before resolving.
- `style`: `vancouver` (default), `ama`, `apa`, `ieee`, `cse`, or any CSL style ID (`chicago-author-date`, `harvard-cite-them-right`, `modern-language-association`, `nature`, `bmj`, `the-lancet`, …).
- `output`: `text` or `json`.
Response: `{ "ok": true, "items": [{ "formatted": "…" }], "text": "…" }`.

### Export a bibliography file
```bash
curl -sS -X POST "https://scholar-sidekick.com/api/export" \
  -H "Content-Type: application/json" \
  -d '{"text": "10.1038/nphys1170\nPMID:30049270", "format": "bibtex"}' \
  -o refs.bib
```
- `format`: `bibtex`, `ris`, `csl-json`, `endnote-xml`, `refworks`, `nbib`, `rdf`, `csv`, `txt`.

### Check retraction
```bash
curl -sS -X POST "https://scholar-sidekick.com/api/retraction-check" \
  -H "Content-Type: application/json" \
  -d '{"id": "10.1016/S0140-6736(97)11096-0"}'
```
Returns `{ ok, doi, result: { isRetracted, hasCorrections, hasConcern, notices[], title } }`
(Crossref + Retraction Watch). One identifier per call — field is **`id`**. When the work has
no DOI (e.g. a book), `result` is `null` and `reason` explains why (`no_doi` / `timeout` / `upstream`).

### Check open access
```bash
curl -sS -X POST "https://scholar-sidekick.com/api/oa-check" \
  -H "Content-Type: application/json" \
  -d '{"id": "10.1371/journal.pone.0173664"}'
```
Returns `{ ok, doi, result: { isOa, oaStatus, bestLocation: {url, hostType, license, version}, locations[] } }`
(Unpaywall). One identifier per call — field is **`id`**.

### Verify a claimed citation (catch fabrication)
```bash
curl -sS -X POST "https://scholar-sidekick.com/api/verify" \
  -H "Content-Type: application/json" \
  -d '{"claimed": {"title": "The title exactly as cited", "doi": "10.xxxx/xxxxx"}}'
```
Citation fields go inside a **`claimed`** object: `title` (required) plus an identifier
(`doi`, `pmid`, … — recommended) and optional `authors` / `year` / `container`. Returns
`{ ok, verdict, confidence, matched }`, verdict ∈ `matched` / `mismatch` / `ambiguous` /
`not_found`:
- `matched` — the claim agrees with the record at the identifier.
- `mismatch` — the identifier resolves but the title doesn't: the dominant AI-fabrication
  pattern (real DOI + invented title; Topaz et al., Lancet 2026).
- `ambiguous` — the identifier resolves to one paper but the claimed title matches a *different*
  real paper (a wrong-identifier error, not a fabrication).
- `not_found` — neither identifier nor title resolves anywhere.

Use this for "is this citation real?", not a plain format/resolve.

### Audit a whole bibliography (batch fabrication + retraction check)
```bash
curl -sS -X POST "https://scholar-sidekick.com/api/audit" \
  -H "Content-Type: application/json" \
  -d '{"bibliography":"@article{a, title={A real title}, doi={10.1038/nphys1170}}\n@article{b, title={An invented title}, doi={10.1016/j.neuroscience.2023.02.008}}"}'
```
The batch counterpart to `/api/verify`. Send EITHER `bibliography` (raw BibTeX / RIS /
CSL-JSON text; format auto-detected, override with `format`) OR `claims` (array of
`{title + one identifier}` objects) — not both. Optional `options.checks` defaults to
`["retraction"]` (pass `[]` to skip). Max 25 entries per call (excess reported via
`truncated`). Returns `{ ok, format, entries[], parseErrors[], truncated, summary }` where
each entry carries `verdict` / `confidence` / `retraction` and
`summary = { total, matched, mismatch, ambiguous, not_found, errored, retracted }`.
One bad entry becomes `status: "error"` without failing the batch. This audits citation
identity — it does not check whether a source supports the claim it is cited for.

## Pitfalls
- Never scrape the web UI — the JSON API is faster and stable.
- Pass identifiers verbatim; don't strip prefixes.
- Body fields differ per endpoint: `format`/`export` use `text`; `retraction-check`/`oa-check` use `id` (one identifier per call); `verify` wraps fields in `claimed`. Don't mix them up.
- ISBNs have no DOI, so retraction/OA return a "no DOI" result for books.
- Don't fabricate a fallback: if a call fails or returns `ok:false`, report that — never invent a citation, retraction status, OA verdict, or a "matched" verdict.

## Verification
- `curl -sS https://scholar-sidekick.com/api/health` returns `{ "ok": true, … }`.
- A good `/api/format` response has `items[].formatted` non-empty.

## Optional: bundled MCP server (power users)
This plugin also ships the `scholar-sidekick` MCP server (tools: `resolveIdentifier`,
`formatCitation`, `exportCitation`, `checkRetraction`, `checkOpenAccess`, `verifyCitation`,
`auditBibliography`). It runs anonymously too — prefer it when it's connected, since native
tool calls beat `curl`:
```bash
npx -y scholar-sidekick-mcp@latest   # anonymous; no key needed
```
