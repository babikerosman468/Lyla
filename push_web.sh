
#!/data/data/com.termux/files/usr/bin/bash
# ==========================================
# 🗑️ reset_repo.sh — Delete & recreate repo
# Repo: lyla/web
# ==========================================

set -e  # stop on error

# 1. Delete old repo
echo "🗑️ Deleting old repo folder..."
rm -rf ~/lyla/web

# 2. Recreate folder
echo "📂 Creating new repo folder..."
mkdir -p ~/lyla/web

# 3. Copy your website files into repo
echo "📂 Copying website files into new repo..."
cp -r ~/lyla/project/web/* ~/lyla/web/

# 4. Initialize Git
cd ~/lyla/web
echo "🔧 Initializing git..."
git init
git branch -M main

# 5. Add remote (replace USERNAME with your GitHub username)
echo "🔗 Adding GitHub remote..."
git remote add origin https://github.com/babikerosman468/lyla.git

# 6. Add + commit + push
echo "➕ Adding files..."
git add .

echo "📝 Committing..."
git commit -m "Initial commit"

echo "⬆️ Pushing to GitHub..."
git push -u origin main --force

echo "✅ Repo reset and pushed successfully!"

