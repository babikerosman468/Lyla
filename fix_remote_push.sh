
#!/bin/bash

# === CONFIG ===
PROJECT_DIR="$HOME/20/22/24/lyla/project"
REPO_NAME="Lyla"
REMOTE_URL="git@github.com:babikerosman468/$REPO_NAME.git"

# === Go to project ===
cd "$PROJECT_DIR" || { echo "Directory not found: $PROJECT_DIR"; exit 1; }

# === Make sure repo is initialized ===
git init

# === Remove any existing origin ===
git remote remove origin 2>/dev/null

# === Add correct SSH remote ===
git remote add origin "$REMOTE_URL"

# === Set branch and push ===
git branch -M main
git push -u origin main

echo "✅ Remote fixed! Using SSH: $REMOTE_URL"

