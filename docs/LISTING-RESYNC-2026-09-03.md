# Cursor Directory listing — re-sync copy (2026-09-03)

Audit of https://cursor.directory/plugins/scholar-sidekick against repo v1.0.2.
The listing serves pre-`1065fb5` text. Three commits never reached it:
`1065fb5` (anonymous auth), `862a9bb` (audit), `86092e4` (shortDOI).

Follow `RELEASE.md` step 4. Work top-down: field 1 breaks installs today.

⚠️ **Every field below is edited by hand in the dashboard.** The listing keeps its own copy
of each component and does not read the repo, so `git push` changes nothing here. Confirmed
2026-09-03: the dashboard editor exposes one component per skill/rule/MCP server, each with
its own Name, Description, and Content fields.

---

## Field 1 — MCP server config  ⚠️ HIGHEST PRIORITY

**Currently serving:**

```json
{
  "command": "npx",
  "args": ["-y", "scholar-sidekick-mcp@latest"],
  "env": { "RAPIDAPI_KEY": "${RAPIDAPI_KEY}" }
}
```

**Replace with (exactly this — no `env` block at all):**

```json
{
  "command": "npx",
  "args": ["-y", "scholar-sidekick-mcp@latest"]
}
```

Why: an unexpanded `${RAPIDAPI_KEY}` is not empty. The server reads it as a real key,
switches to the RapidAPI gateway, and 403s every call. It never falls back to anonymous.
Anonymous is confirmed working — `POST /api/format` returned 200 with no key on 2026-09-03.

This is the repo `mcp.json` verbatim. Edit the component's config field by hand — the
dashboard holds its own copy and does not re-read the repo.

---

## Field 2 — Plugin description

**Currently serving:**

> Resolve, format, export, and verify academic citations (DOI, PMID, PMCID, ISBN, ISSN,
> arXiv, ADS, WHO IRIS) — plus retraction and open-access checks.

**Replace with:**

> Resolve, format, export, and verify academic citations (DOI incl. shortDOI aliases, PMID,
> PMCID, ISBN, ISSN, arXiv, ADS, WHO IRIS) — plus retraction and open-access checks.

This is `.cursor-plugin/plugin.json` → `description` verbatim.

---

## Field 3 — Keywords

Listing shows 11 keywords; `plugin.json` has 10. The extra one is `verify`, added by hand
in the dashboard.

**Keep `verify` on the listing.** Do not let a re-sync drop it. Better: add `"verify"` to
the `keywords` array in `.cursor-plugin/plugin.json` so the two agree and the next re-sync
is a no-op.

---

## Field 4 — The rule (`scholar-sidekick.mdc`)

The listing serves the old rule body. Four defects:

1. "Requires a `RAPIDAPI_KEY` in the environment (free tier available at
   https://rapidapi.com/…)" — false.
2. The tool table has 6 rows. `auditBibliography` is missing.
3. No shortDOI alias note.
4. No "never ask for a key" instruction.

The repo file `rules/scholar-sidekick.mdc` already has all four fixed, but the dashboard
holds its own copy. Open the rule component and edit its Content field. Simplest is to
paste the whole repo body from below the `---` frontmatter; the three passages that must
change are:

**Two paths — replace the MCP bullet:**

> - **MCP server (preferred when connected)** — the bundled `scholar-sidekick` server exposes
>   native tools. Runs anonymously at a rate-limited free tier; **no key required**.

**And add this paragraph after the two bullets:**

> Both paths are anonymous by default. **Never ask the user for an API key** to make a call
> work. A free first-party `ssk_` key (https://scholar-sidekick.com/account) only raises rate
> limits — mention it if and only if they actually hit one.

**Tool table — add this 7th row:**

> | Audit a whole bibliography / .bib / .ris file at once | `auditBibliography` | `POST /api/audit` |

**Rules of engagement — the first two bullets become:**

> - Pass identifiers **verbatim** — don't strip `PMID:`, `arXiv:`, ISBN hyphens, or
>   `https://doi.org/…` prefixes; detection is automatic.
>   A shortDOI alias (`10/aabbe`, from shortdoi.org) works anywhere a DOI does and is
>   expanded to the full DOI before resolving.
> - `formatCitation` / `exportCitation` accept several newline-separated identifiers (batch).
>   `checkRetraction` / `checkOpenAccess` / `verifyCitation` take **one** identifier per call;
>   to check a whole reference list in one call, use `auditBibliography` (max 25 entries).

---

## Field 5 — Skills: 7 on the listing, 8 in the repo

`audit-bibliography` is absent. Zero occurrences of `auditBibliography` on the page.

The dashboard does **not** pull this from the repo. Add it by hand as a new component
(the screenshot showed it as "Component 10"). It has three fields, all given verbatim below.

### Field 5a — the new `audit-bibliography` component

**Type:** `Skill`

**Name** (paste exactly):

```
audit-bibliography
```

**Description** (paste exactly — this is the skill's own frontmatter `description`, not the
rule-table row):

```
Audit a whole bibliography (BibTeX, RIS, or CSL-JSON) in one call — per-entry fabrication verdict and retraction status, plus a corpus summary.
```

**Content** — paste everything between the two markers below. This is
`skills/audit-bibliography/SKILL.md` with its YAML frontmatter stripped, because the
dashboard supplies `name` and `description` from the two fields above. It starts at the
`# auditBibliography` heading, matching what the editor already showed.

<!-- ===== BEGIN CONTENT — paste from the next line ===== -->

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

<!-- ===== END CONTENT — stop at the line above ===== -->

After saving, confirm the tab header reads **Skills (8)**.

### Field 5b — `scholar-sidekick-api` skill, two stale passages

**"Authentication & limits" currently serves:**

> Calls to `scholar-sidekick.com/api/*` work **anonymously — there is no first-party API
> key** — at a rate-limited free tier (~40 format / 10 export requests per window), which
> is plenty for normal, human-driven agent use. For higher limits, Scholar Sidekick is
> offered on RapidAPI: subscribe at https://rapidapi.com/… and call it through the RapidAPI
> gateway with your `X-RapidAPI-Key`. Use the anonymous `scholar-sidekick.com` endpoints by
> default; move to RapidAPI only for volume.

**Replace with:**

> Calls to `scholar-sidekick.com/api/*` work **anonymously — no key required** — at a
> rate-limited free tier (~40 format / 10 export requests per window), which is plenty for
> normal, human-driven agent use. Use the anonymous endpoints by default.
>
> Two optional routes raise the limits; they are alternatives, not layers:
> - A free **first-party key** (`ssk_…`) from https://scholar-sidekick.com/account, sent as
>   `Authorization: Bearer ssk_…` against `scholar-sidekick.com`.
> - A **RapidAPI** subscription for paid/managed volume: subscribe at
>   https://rapidapi.com/scholar-sidekick-scholar-sidekick-api/api/scholar-sidekick and call
>   the RapidAPI gateway with your `X-RapidAPI-Key`.
>
> Never ask the user for a key just to make a call work — anonymous is the default and is
> sufficient. Only mention a key if they hit a rate limit.

**"Optional: bundled MCP server" currently serves:**

> This plugin also ships the `scholar-sidekick` MCP server (tools: `resolveIdentifier`,
> `formatCitation`, `exportCitation`, `checkRetraction`, `checkOpenAccess`, `verifyCitation`).
> That path requires a RapidAPI key, so the REST calls above are the zero-setup default:
> ```bash
> npx -y scholar-sidekick-mcp@latest   # needs RAPIDAPI_KEY in env
> ```

**Replace with:**

> This plugin also ships the `scholar-sidekick` MCP server (tools: `resolveIdentifier`,
> `formatCitation`, `exportCitation`, `checkRetraction`, `checkOpenAccess`, `verifyCitation`,
> `auditBibliography`). It runs anonymously too — prefer it when it's connected, since native
> tool calls beat `curl`:
> ```bash
> npx -y scholar-sidekick-mcp@latest   # anonymous; no key needed
> ```

---

## Verify after re-syncing

The page sits behind a Vercel Security Checkpoint: `curl` and plain fetch both get HTTP 429.
Read it in a real browser, or with headless Chromium.

Check every one of these on the served page:

- [ ] MCP config shows **no** `env` block and no `${RAPIDAPI_KEY}`
- [ ] Tab header reads **Skills (8)**
- [ ] `auditBibliography` appears (rule table + API skill tool list + its own skill)
- [ ] `shortDOI` appears (description + rule)
- [ ] `ssk_` appears (rule + API skill)
- [ ] No text anywhere claims the MCP server needs a key
- [ ] The `verify` keyword survived

Then confirm the install actually works, per `RELEASE.md` step 2 — with **no**
`SCHOLAR_API_KEY` or `RAPIDAPI_KEY` in your shell. A key in the environment hides exactly
the defect being fixed.
