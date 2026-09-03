#!/usr/bin/env bash
#
# sync-local.sh — copy this plugin into Cursor's local plugins dir for live testing.
#
# Why a copy and not a symlink: Cursor (3.5.x) rejects a local-plugin symlink whose
# target lives outside ~/.cursor/plugins/local (its loader logs
# "loadUserLocalPlugin … rejected: symlink target … is outside …/plugins/local").
# So we rsync a real directory instead.
#
# Usage:  ./scripts/sync-local.sh
# Then:   reload Cursor — Cmd+Shift+P → "Developer: Reload Window".
#
set -euo pipefail

# Repo root = parent of this script's dir (works regardless of cwd).
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$HOME/.cursor/plugins/local/scholar-sidekick"

if [ "$SRC" = "$DEST" ]; then
  echo "Refusing to sync: run this from the plugin repo, not the installed copy." >&2
  exit 1
fi

mkdir -p "$DEST"

# Seed mcp.json on first run only. We never overwrite an existing local mcp.json,
# because you may have edited it for testing (a real key, or an absolute node path)
# and rsync would clobber that on every sync.
#
# The repo's copy needs no key: the MCP server runs anonymously on a rate-limited
# free tier. If an old local copy still carries an "env" block with a ${RAPIDAPI_KEY}
# placeholder, delete the file and re-run this script — an unexpanded placeholder is
# not empty, so the server reads it as a real key and 403s every call.
if [ ! -f "$DEST/mcp.json" ]; then
  cp "$SRC/mcp.json" "$DEST/mcp.json"
  echo "Seeded mcp.json — anonymous, no key needed."
  echo "  $DEST/mcp.json"
fi

rsync -a --delete \
  --exclude '.git' \
  --exclude '.DS_Store' \
  --exclude 'node_modules' \
  --exclude 'mcp.json' \
  "$SRC/" "$DEST/"

echo "Synced: $SRC"
echo "    -> $DEST  (mcp.json left untouched)"
echo "Reload Cursor to pick up changes: Cmd+Shift+P → 'Developer: Reload Window'."

# Cursor launched from the Dock inherits no shell environment — its PATH is
# /usr/bin:/bin:/usr/sbin:/sbin. If node came from a version manager or a custom
# prefix, "command": "npx" fails with "spawn npx ENOENT" and the agent silently
# falls back to the REST skill, so the error looks like an API problem. Warn early.
if ! PATH=/usr/bin:/bin:/usr/sbin:/sbin command -v npx >/dev/null 2>&1; then
  NODE_BIN="$(dirname "$(command -v node 2>/dev/null || echo /nonexistent)")"
  echo
  echo "WARNING: npx is not on Cursor's PATH (/usr/bin:/bin:/usr/sbin:/sbin)."
  echo "Cursor will fail with 'spawn npx ENOENT' and fall back to REST."
  echo "To test the MCP path, add an env block to $DEST/mcp.json:"
  echo "    \"env\": { \"PATH\": \"$NODE_BIN:/usr/bin:/bin:/usr/sbin:/sbin\" }"
  echo "Local fix only — do not commit it. See README 'Troubleshooting'."
fi
