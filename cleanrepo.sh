#!/bin/bash
# clean_repo.sh
# Remove all tracked files from the repo

set -e
cd ~/lyla

echo "🧹 Cleaning repo (removing all tracked files)..."
git rm -rf . > /dev/null 2>&1 || true

echo "💾 Committing cleanup..."
git commit -m "Clean repo" || echo "ℹ️ Nothing to commit."

echo "🚀 Pushing clean state..."
git push origin main -f

echo "✅ Repo cleaned successfully!"

