#!/data/data/com.termux/files/usr/bin/bash
# compile_complete.sh - Complete LaTeX compilation with proper sequence

if [ $# -eq 0 ]; then
  echo "❌ Usage: compile_complete.sh <filename.tex>"
  exit 1
fi

TEXFILE=$(realpath "$1")
BASENAME=$(basename "$TEXFILE" .tex)
DIRNAME=$(dirname "$TEXFILE")
PDF="${DIRNAME}/${BASENAME}.pdf"

echo "📋 Compiling: $BASENAME.tex"

run_in_proot() {
  CMD="$1"
  echo "➡️ $CMD"
  proot-distro login debian -- sh -c "cd \"$DIRNAME\" && $CMD"
}

# CRITICAL 4-STEP SEQUENCE
echo "🔧 Step 1/4: First XeLaTeX pass..."
run_in_proot "xelatex -halt-on-error \"$BASENAME.tex\""

echo "🔧 Step 2/4: Running BibTeX..."
if [ -f "${DIRNAME}/${BASENAME}.aux" ]; then
  run_in_proot "bibtex \"$BASENAME.aux\""
else
  echo "❌ No .aux file found for BibTeX"
  exit 1
fi

echo "🔧 Step 3/4: Second XeLaTeX pass..."
run_in_proot "xelatex -halt-on-error \"$BASENAME.tex\""

echo "🔧 Step 4/4: Final XeLaTeX pass..."
run_in_proot "xelatex -halt-on-error \"$BASENAME.tex\""

# Check results
if [ -f "$PDF" ]; then
  echo "✅ PDF created: $PDF"
  echo "📄 Pages: $(pdfinfo "$PDF" | grep Pages | awk '{print $2}')"
else
  echo "❌ PDF creation failed"
  exit 1
fi

# Cleanup (keep essential BibTeX files)
echo "🧹 Cleaning temporary files..."
EXTS=("log" "out" "toc" "lof" "lot" "fdb_latexmk" "fls" "synctex.gz")
for ext in "${EXTS[@]}"; do
  FILE="${DIRNAME}/${BASENAME}.${ext}"
  [ -f "$FILE" ] && rm -f "$FILE"
done

echo "💾 Preserved: .aux, .bbl, .blg (for BibTeX)"
echo "🎉 Done! Check rev1.pdf for numbered citations and line numbers."



