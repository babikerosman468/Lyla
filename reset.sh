#!/bin/bash
# reset.sh
# Move website files from web/ to repo root and push to GitHub Pages

set -e

echo "🧹 Cleaning repo..."
cd ~/lyla

# Move files from web/ to root (overwrite if exist)
if [ -d "web" ]; then
  echo "📂 Moving website files to repo root..."
  mv web/* ./
  rm -rf web
else
  echo "⚠️ No web/ folder found, skipping move."
fi

echo "➕ Adding files..."
git add -A

echo "💾 Committing..."
git commit -m "Move website files to repo root for GitHub Pages" || echo "ℹ️ Nothing to commit."

echo "🚀 Pushing..."
git push origin main -f

echo "✅ Done! Website will be available at:"
echo "👉 https://babikerosman468.github.io/Lyla/"

