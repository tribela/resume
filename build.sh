#!/bin/bash
set -eo pipefail

mkdir -p output

# Compile LESS files (shared by all variants)
cat modern/css/elements.less modern/css/normalize.css modern/css/resume.css modern/css/screen.css > output/combined.less
lessc output/combined.less output/resume.css
cat modern/css/elements.less modern/css/normalize.css modern/css/resume.css modern/css/screen.css modern/css/pdf.css > output/combined_pdf.less
lessc output/combined_pdf.less output/pdf.css

build_one() {
  local SRC="$1"
  local BASE
  BASE="$(basename "$SRC" .md)"

  # Generate title from first two lines of the source file
  local TITLE
  TITLE=$(head -n 2 "$SRC" | sed 's/^#* //g' | tr '\n' '|' | sed 's/|$//; s/|/ | /g')

  # 1. Build HTML
  echo "<style>" > output/style_header.html
  cat output/resume.css >> output/style_header.html
  echo "</style>" >> output/style_header.html

  pandoc -f markdown+hard_line_breaks \
         -t html \
         --standalone \
         --template modern/template.html \
         --metadata pagetitle="$TITLE" \
         -H output/style_header.html \
         "$SRC" -o "output/${BASE}.html"

  # 2. Build pdf.html (for PDF conversion)
  echo "<style>" > output/pdf_style_header.html
  cat output/pdf.css >> output/pdf_style_header.html
  echo "</style>" >> output/pdf_style_header.html

  pandoc -f markdown+hard_line_breaks \
         -t html \
         --standalone \
         --template modern/template.html \
         --metadata pagetitle="$TITLE" \
         --variable body-class="pdf" \
         -H output/pdf_style_header.html \
         "$SRC" -o "output/${BASE}-pdf.html"

  # 3. Generate PDF using Playwright + Chromium
  node scripts/build_pdf.mjs "output/${BASE}-pdf.html" "output/${BASE}.pdf"

  rm output/style_header.html output/pdf_style_header.html
}

build_one resume.md
build_one resume-en.md

# Copy resume.html to index.html for web serving
cp output/resume.html output/index.html

# Cleanup
rm output/combined.less output/combined_pdf.less output/resume.css output/pdf.css

echo "Built output/resume.html, output/index.html, output/resume-en.html, output/resume.pdf and output/resume-en.pdf"
