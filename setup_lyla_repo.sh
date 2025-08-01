#!/bin/bash

# === CONFIG ===
PROJECT_DIR="$HOME/20/22/24/lyla/project"
REPO_NAME="Lyla"
REMOTE_URL="git@github.com:babikerosman468/$REPO_NAME.git"

# === STEP 1: Go to project ===
cd "$PROJECT_DIR" || { echo "Directory not found: $PROJECT_DIR"; exit 1; }

# === STEP 2: Initialize git ===
git init

# === STEP 3: Create a .gitignore ===
cat <<EOL > .gitignore
# Byte-compiled / cache files
__pycache__/
*.py[cod]

# PDF and other build files
*.pdf

# TeX auxiliary files
*.aux
*.log
*.out
*.toc

# VSCode and editor settings
.vscode/
*.swp
EOL

echo ".gitignore created."

# === STEP 4: Add all files ===
git add .

# === STEP 5: Initial commit ===
git commit -m "Initial commit with .gitignore"

# === STEP 6: Create remote repo using GitHub CLI ===
gh repo create babikerosman468/$REPO_NAME --public --confirm

# === STEP 7: Add remote ===
git remote add origin "$REMOTE_URL"

# === STEP 8: Push to main ===
git branch -M main
git push -u origin main

echo "✅ Done! Local repo initialized, remote repo created, and pushed using SSH!"

