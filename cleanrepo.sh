
#!/bin/bash
# reset_repo.sh
# Clean Git repo safely, keep local Termux files

cd ~/lyla || exit

echo "🗑️  Removing old .git history..."
rm -rf .git

echo "🔧 Initializing fresh git repo..."
git init
git checkout -b main

echo "🌐 Adding remote GitHub repo..."
git remote add origin git@github.com:babikerosman468/lyla.git

echo "📂 Adding only web/ folder to repo..."
git add web

echo "📝 Commiting changes..."
git commit -m "Initial clean repo with web folder"

echo "⬆️  Forcing push to GitHub main..."
git push -f origin main

echo "✅ Repo has been reset and pushed with only web/ folder!"
