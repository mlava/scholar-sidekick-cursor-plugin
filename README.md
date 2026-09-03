# Scholar Sidekick — Cursor Plugin

Resolve, format, export, and **verify** academic citations directly inside Cursor —
plus retraction and open-access checks. Works from a scholarly identifier: DOI
(including shortDOI aliases like `10/aabbe`), PMID, PMCID, ISBN, ISSN, arXiv ID,
ADS bibcode, or WHO IRIS URL.

Backed by [Scholar Sidekick](https://scholar-sidekick.com) — the same engine behind the
REST API, the MCP server, and the Obsidian plugin.

## What's in the bundle

| Component | What it gives you |
|---|---|
| **MCP server** (`mcp.json`) | The `scholar-sidekick` server with seven native tools: `resolveIdentifier`, `formatCitation`, `exportCitation`, `checkRetraction`, `checkOpenAccess`, `verifyCitation`, `auditBibliography`. |
| **8 skills** (`skills/`) | Per-capability guidance so the agent knows *when* and *how* to use each tool — including a keyless `scholar-sidekick-api` REST skill that works with no API key. |
| **1 rule** (`rules/scholar-sidekick.mdc`) | On-demand tool-selection guidance: which tool for which question, and the rule that "is this citation real?" needs `verifyCitation`, not a plain resolve. |

## Install

Install from the [Cursor Directory listing](https://cursor.directory/plugins/scholar-sidekick).

To run it from a local checkout instead:

```bash
./scripts/sync-local.sh   # then: Cmd+Shift+P → "Developer: Reload Window"
```

> Use the script rather than a symlink. Cursor 3.5.x refuses to load a local plugin whose
> symlink target lives outside `~/.cursor/plugins/local`, so the script copies the
> directory instead.

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

## Troubleshooting

### The agent answers with `curl` instead of the MCP tools, or reports a 403

Symptom: you ask for a citation, the agent says it "ran N commands", and you get a network
error such as `CONNECT tunnel failed, HTTP 403` — or no citation at all.

That 403 is **not** an authentication failure and does not come from the Scholar Sidekick
API. It means the MCP server never started, so the agent silently fell back to the keyless
REST skill and the error came from whatever `curl` hit on the way out.

Check the real cause in Cursor's own MCP log:

```bash
ls -t ~/Library/Application\ Support/Cursor/logs/*/window*/exthost/anysphere.cursor-mcp/MCP\ plugin-scholar-sidekick-*.log \
  | head -1 | xargs cat
```

If it says `spawn npx ENOENT`, Cursor cannot find `npx`. Cursor launched from the Dock
inherits no shell environment — its `PATH` is `/usr/bin:/bin:/usr/sbin:/sbin`. A Node
installed by a version manager (nvm, fnm, volta, asdf) or under a custom prefix is
invisible to it, even though `npx` works fine in your terminal.

Fix it by giving the server a `PATH` in your **local** `~/.cursor/plugins/local/scholar-sidekick/mcp.json`:

```json
{
  "mcpServers": {
    "scholar-sidekick": {
      "command": "npx",
      "args": ["-y", "scholar-sidekick-mcp@latest"],
      "env": { "PATH": "/path/to/your/node/bin:/usr/bin:/bin:/usr/sbin:/sbin" }
    }
  }
}
```

Get the directory with `dirname "$(command -v node)"`. Reload the window afterwards.

> An absolute path to `npx` alone is **not** enough. `npx` is a script with a
> `#!/usr/bin/env node` shebang, so it needs `node` on `PATH` too — and so does the bin
> script that `npx` then spawns. Setting `env.PATH` is what fixes all three layers.

This is a machine-specific workaround. Keep it in your local copy; it must not be
committed, because the published config has to work on everyone's machine.

### Every call fails with 403, and the log shows no error

Check your local `mcp.json` for a leftover `env` block. An unexpanded `${RAPIDAPI_KEY}`
placeholder is not empty — the server reads it as a real key, routes through the RapidAPI
gateway, and 403s every request without ever falling back to anonymous. Delete the file and
re-run `./scripts/sync-local.sh` to reseed it.

## Releasing

See [RELEASE.md](RELEASE.md). Note that publishing is **not** just `git push`: the Cursor
Directory listing is human-maintained and keeps its own copy of the description, so it must
be re-synced and re-read by hand or it silently serves the previous text.

## Links

- Website: https://scholar-sidekick.com
- Agent guide (REST + MCP): https://scholar-sidekick.com/AGENTS.md
- MCP server source: https://github.com/mlava/scholar-sidekick-mcp
- OpenAPI 3.1 spec: https://scholar-sidekick.com/openapi/openapi.yml
- Citation-integrity / verifier explainer: https://scholar-sidekick.com/citation-integrity

## License

MIT — see [LICENSE](LICENSE).
