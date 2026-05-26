# Scholar Sidekick — Cursor Plugin

Resolve, format, export, and **verify** academic citations directly inside Cursor —
plus retraction and open-access checks. Works from a scholarly identifier: DOI, PMID,
PMCID, ISBN, ISSN, arXiv ID, ADS bibcode, or WHO IRIS URL.

Backed by [Scholar Sidekick](https://scholar-sidekick.com) — the same engine behind the
REST API, the MCP server, and the Obsidian plugin.

## What's in the bundle

| Component | What it gives you |
|---|---|
| **MCP server** (`mcp.json`) | The `scholar-sidekick` server with six native tools: `resolveIdentifier`, `formatCitation`, `exportCitation`, `checkRetraction`, `checkOpenAccess`, `verifyCitation`. |
| **7 skills** (`skills/`) | Per-capability guidance so the agent knows *when* and *how* to use each tool — including a keyless `scholar-sidekick-api` REST skill that works with no API key. |
| **1 rule** (`rules/scholar-sidekick.mdc`) | On-demand tool-selection guidance: which tool for which question, and the rule that "is this citation real?" needs `verifyCitation`, not a plain resolve. |

## Install

Install from the [Cursor Marketplace](https://cursor.com/marketplace) (search "Scholar
Sidekick"), or test locally by symlinking this repo into Cursor's local plugins dir:

```bash
ln -s "$(pwd)" ~/.cursor/plugins/local/scholar-sidekick
```

## Two ways to run — pick based on whether you have a key

- **MCP server (preferred):** native tool calls. Requires a `RAPIDAPI_KEY` in your
  environment. The `mcp.json` reads it via `${RAPIDAPI_KEY}`:

  ```json
  {
    "mcpServers": {
      "scholar-sidekick": {
        "command": "npx",
        "args": ["-y", "scholar-sidekick-mcp@latest"],
        "env": { "RAPIDAPI_KEY": "${RAPIDAPI_KEY}" }
      }
    }
  }
  ```

  Get a free-tier key at
  [rapidapi.com/scholar-sidekick…](https://rapidapi.com/scholar-sidekick-scholar-sidekick-api/api/scholar-sidekick),
  then set `RAPIDAPI_KEY` in your shell or Cursor environment.

- **Keyless REST (no setup):** if you don't have a key, the bundled `scholar-sidekick-api`
  skill drives the public REST API at `https://scholar-sidekick.com/api/*` over `curl` —
  anonymous, free, rate-limited. No install, no key.

## Try it

Once installed, ask Cursor's agent things like:

- *Format `10.1056/NEJMoa2033700` in Vancouver style.*
- *Resolve `PMID:30049270` and export it as BibTeX.*
- *Is this citation real? "A Unified Theory of Everything", `10.1038/nphys1170`.*
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
