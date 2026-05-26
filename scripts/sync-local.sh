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
# because you may have put a real RAPIDAPI_KEY in it for testing — the repo's copy
# only carries the ${RAPIDAPI_KEY} placeholder, which would break the MCP server.
if [ ! -f "$DEST/mcp.json" ]; then
  cp "$SRC/mcp.json" "$DEST/mcp.json"
  echo "Seeded mcp.json (uses \${RAPIDAPI_KEY}). Set that env var, or edit"
  echo "  $DEST/mcp.json"
  echo "with your RapidAPI key so the MCP server can authenticate."
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
