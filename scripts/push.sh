#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# push.sh  —  Quick commit + push for HealthAI
# Usage:
#   ./scripts/push.sh                    # uses default commit message
#   ./scripts/push.sh "your message"     # uses custom commit message
# ─────────────────────────────────────────────────────────────────────────────

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

MSG="${1:-"chore: auto-push $(date '+%Y-%m-%d %H:%M')"}"

echo "📦  Staging all changes..."
git add .

# Skip commit if nothing to commit
if git diff --cached --quiet; then
  echo "✅  Nothing to commit — working tree clean."
else
  echo "💬  Committing: $MSG"
  git commit -m "$MSG"
fi

echo "🚀  Pushing to origin/main..."
git push -u origin main

echo "✅  Done! Check: https://github.com/coded-with-aryan0426/HealthAI_Fluter_app"
