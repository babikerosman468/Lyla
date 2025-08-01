
#!/bin/bash

# ✅ Adjust these paths for your system
REPO_URL="https://github.com/babikerosman468/Lyla.git"
LOCAL_WEB_DIR="$HOME/20/22/24/lyla/project/web"
CLONE_DIR="$HOME/lyla-tmp"

echo "🧹 Removing old temp folder..."
rm -rf "$CLONE_DIR"

echo "🔁 Cloning repo..."
git clone "$REPO_URL" "$CLONE_DIR"

echo "📂 Copying website files..."
mkdir -p "$CLONE_DIR/web"
cp -r "$LOCAL_WEB_DIR/"* "$CLONE_DIR/web/"

echo "✅ Committing..."
cd "$CLONE_DIR"
git add web
git commit -m "Update static website files in web subfolder"

echo "🚀 Pushing..."
git push origin main

echo "🎉 Done!"

