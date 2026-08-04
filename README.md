# Scholar Sidekick — Cursor Plugin

Resolve, format, export, and **verify** academic citations directly inside Cursor —
plus retraction and open-access checks. Works from a scholarly identifier: DOI, PMID,
PMCID, ISBN, ISSN, arXiv ID, ADS bibcode, or WHO IRIS URL.

Backed by [Scholar Sidekick](https://scholar-sidekick.com) — the same engine behind the
REST API, the MCP server, and the Obsidian plugin.

## What's in the bundle

| Component | What it gives you |
|---|---|
| **MCP server** (`mcp.json`) | The `scholar-sidekick` server with seven native tools: `resolveIdentifier`, `formatCitation`, `exportCitation`, `checkRetraction`, `checkOpenAccess`, `verifyCitation`, `auditBibliography`. |
| **8 skills** (`skills/`) | Per-capability guidance so the agent knows *when* and *how* to use each tool — including a keyless `scholar-sidekick-api` REST skill that works with no API key. |
| **1 rule** (`rules/scholar-sidekick.mdc`) | On-demand tool-selection guidance: which tool for which question, and the rule that "is this citation real?" needs `verifyCitation`, not a plain resolve. |

## Install

Install from the [Cursor Marketplace](https://cursor.com/marketplace) (search "Scholar
Sidekick"), or test locally by symlinking this repo into Cursor's local plugins dir:

```bash
ln -s "$(pwd)" ~/.cursor/plugins/local/scholar-sidekick
```

## Two ways to run — both work with no key

- **MCP server (preferred):** native tool calls. Runs anonymously on a rate-limited free
  tier; there is nothing to set up. The bundled `mcp.json`:

  ```json
  {
    "mcpServers": {
      "scholar-sidekick": {
        "command": "npx",
        "args": ["-y", "scholar-sidekick-mcp@latest"]
      }
    }
  }
  ```

  To raise your rate limits, add an `env` block setting `SCHOLAR_API_KEY` to a free
  first-party `ssk_` key from [scholar-sidekick.com/account](https://scholar-sidekick.com/account).
  `RAPIDAPI_KEY` is a separate route for paid/managed tiers — set one or the other, never
  both, and do not set either to an unexpanded `${…}` placeholder (that routes calls to the
  RapidAPI gateway with an invalid key and every request fails with 403).

- **Keyless REST (no install):** the bundled `scholar-sidekick-api` skill drives the public
  REST API at `https://scholar-sidekick.com/api/*` over `curl` — anonymous, free,
  rate-limited. Useful when you'd rather not run a local process at all.

## Try it

Once installed, ask Cursor's agent things like:

- *Format `10.1056/NEJMoa2033700` in Vancouver style.*
- *Resolve `PMID:30049270` and export it as BibTeX.*
- *Is this citation real? "A Unified Theory of Everything", `10.1038/nphys1170`.*
- *Audit every reference in `refs.bib` — which are fake or retracted?*
- *Has `10.1016/S0140-6736(97)11096-0` been retracted?*
- *Is there a free open-access copy of `10.1371/journal.pone.0173664`?*

## Links

- Website: https://scholar-sidekick.com
- Agent guide (REST + MCP): https://scholar-sidekick.com/AGENTS.md
- MCP server source: https://github.com/mlava/scholar-sidekick-mcp
- OpenAPI 3.1 spec: https://scholar-sidekick.com/openapi/openapi.yml
- Citation-integrity / verifier explainer: https://scholar-sidekick.com/citation-integrity

## License

MIT — see [LICENSE](LICENSE).
