#!/bin/bash
# move_web_to_root.sh
# Move website files from repo lyla/web/ to repo lyla/

set -e

cd ~/lyla

echo "📂 Moving files from web/ to root..."
if [ -d "web" ]; then
  mv web/* ./
  rm -rf web
else
  echo "⚠️ No web/ folder found, nothing to move."
fi

echo "➕ Adding changes..."
git add -A

echo "💾 Committing..."
git commit -m "Move website files from web/ to repo root" || echo "ℹ️ Nothing to commit."

echo "🚀 Pushing..."
git push origin main -f

echo "✅ Done!"
echo "👉 Website should be live at: https://babikerosman468.github.io/Lyla/"

