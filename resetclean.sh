#!/bin/bash
# reset_clean.sh
# Keep only website files in the repo root

set -e

cd ~/lyla

echo "🧹 Cleaning repo..."
# Remove everything tracked in Git
git rm -rf . > /dev/null 2>&1 || true

echo "📂 Copying website files..."
# Copy only the listed files from ~/lyla/web into repo root
cp -f ~/lyla/web/{about.html,contact.html,favicon.ico,index.html,link.html,participate.html,participate.js,style.css} ./ 2>/dev/null || true

echo "➕ Adding files..."
git add -A

echo "💾 Committing..."
git commit -m "Reset repo to contain only website files" || echo "ℹ️ Nothing to commit."

echo "🚀 Pushing..."
git push origin main -f

echo "✅ Repo cleaned and updated!"
echo "👉 Check your site at: https://babikerosman468.github.io/Lyla/"

