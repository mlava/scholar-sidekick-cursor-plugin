# Releasing the Cursor plugin

There is no build step and no package registry — the plugin is plain JSON and Markdown.
A release is: bump the version, push, then **update the Cursor Directory listing by hand**.

> ⚠️ **The manual step is not optional and nothing will remind you.** The listing keeps its
> **own copy** of the description/README text, so pushing to GitHub does not change what
> visitors read. Skip step 4 and the directory keeps serving the previous copy indefinitely,
> with no error anywhere. This has already bitten us once: the listing described an install
> that required a `RAPIDAPI_KEY`, long after the server went anonymous-first.
>
> Scholar Sidekick is **not** in the official Cursor Marketplace — that is curated and
> restricted. [cursor.directory](https://cursor.directory/plugins/scholar-sidekick) is the
> distribution channel, and it is human-maintained.

---

## 1. Bump the version

`.cursor-plugin/plugin.json` → `version`. Semver against the last release:

| Change | Bump |
| --- | --- |
| Fixing what the plugin *does* — `mcp.json`, a skill, the rule | patch or minor |
| Only prose in `README.md` | patch (still worth it — see step 4) |
| Removing or renaming a skill/tool | major |

## 2. Sanity-check it loads

```bash
./scripts/sync-local.sh   # then: Cmd+Shift+P → "Developer: Reload Window"
```

Then in Cursor confirm the tools actually answer, rather than assuming the config parsed:

> Format 10.1038/nphys1170 in APA.

Expect `Aspelmeyer, M. (2009). Measured measurement. Nature Physics, 5(1), 11–12.`

⚠️ Check this with **no** `SCHOLAR_API_KEY` or `RAPIDAPI_KEY` in your environment. Anonymous
is the default path and the one nearly every user takes; a key in your shell hides a broken
anonymous config. Never put a `${VAR}` placeholder in `mcp.json` — an unexpanded token is
not empty, so the server treats it as a real key, switches to the RapidAPI gateway, and
403s every call.

## 3. Commit and push

```bash
git commit -am "…"
git push
```

## 4. Update the Cursor Directory listing ← the step that gets forgotten

Sign in at [cursor.directory](https://cursor.directory) and edit the existing
[Scholar Sidekick listing](https://cursor.directory/plugins/scholar-sidekick) from the
dashboard:

1. **Re-sync** the listing so it re-reads the repo.
2. **Check the description text** against the current `README.md`. This is a separate copy
   and the re-sync does not necessarily refresh it — if you changed the README's install,
   auth, or capability prose, update it here too.
3. Reload the public listing page and read it as a new user would. Confirm no stale claim
   survives, particularly anything about API keys being required.

## 5. Record it

Add the release to `docs/outreach/MENTIONS.md` in the main repo only if the listing itself
changed materially (new capability, corrected claim) — routine version bumps do not need it.

---

## Surfaces this repo has to stay in step with

The plugin bundles copies of things that are authored elsewhere. When the upstream changes,
these do **not** follow automatically:

| In this repo | Canonical source |
| --- | --- |
| `skills/scholar-sidekick-api/SKILL.md` | `mlava/scholar-sidekick-skills` (same skill, maintained there) |
| `mcp.json` | The install config documented at [scholar-sidekick.com/mcp](https://scholar-sidekick.com/mcp) |
| Auth prose in `README.md` / `rules/*.mdc` | [scholar-sidekick.com/AGENTS.md](https://scholar-sidekick.com/AGENTS.md) |
| The seven tool names | `src/lib/agent-tools.ts` in the main repo |

After any auth or contract change upstream, re-read this repo's README and `.mdc` rule
before releasing. They are untested prose: nothing fails when they go stale, which is
exactly why they do.
