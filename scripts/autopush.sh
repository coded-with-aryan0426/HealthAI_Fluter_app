#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# autopush.sh  —  Watch for file changes and auto-commit + push
# Requires:  fswatch  (install: brew install fswatch)
# Usage:     ./scripts/autopush.sh
# Stop:      Ctrl+C
# ─────────────────────────────────────────────────────────────────────────────

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

DEBOUNCE=30   # seconds to wait after last change before pushing

if ! command -v fswatch &>/dev/null; then
  echo "❌  fswatch not found. Install it with:  brew install fswatch"
  exit 1
fi

echo "👀  Watching for changes in: $REPO_ROOT"
echo "    Will auto-push ${DEBOUNCE}s after last change.  Press Ctrl+C to stop."

TIMER_PID=""

commit_and_push() {
  cd "$REPO_ROOT"
  git add .
  if git diff --cached --quiet; then
    echo "   (no changes to commit)"
    return
  fi
  MSG="chore: auto-push $(date '+%Y-%m-%d %H:%M:%S')"
  git commit -m "$MSG"
  git push -u origin main
  echo "✅  Pushed at $(date '+%H:%M:%S')"
}

fswatch -r -e "\.git" -e "build/" -e "\.dart_tool" "$REPO_ROOT" | while read -r event; do
  # Cancel existing timer
  if [ -n "$TIMER_PID" ] && kill -0 "$TIMER_PID" 2>/dev/null; then
    kill "$TIMER_PID" 2>/dev/null
  fi
  # Start new debounce timer in background
  (sleep "$DEBOUNCE" && commit_and_push) &
  TIMER_PID=$!
done
