#!/bin/bash
set -eo pipefail

mkdir -p output

# Generate title from first two lines of resume.md
TITLE=$(head -n 2 resume.md | sed 's/^#* //g' | tr '\n' '|' | sed 's/|$//; s/|/ | /g')

# Compile LESS files
# We concatenate them as the original tool did, then compile
cat modern/css/elements.less modern/css/normalize.css modern/css/resume.css modern/css/screen.css > output/combined.less
lessc output/combined.less output/resume.css

# For PDF, we also include pdf.css
cat modern/css/elements.less modern/css/normalize.css modern/css/resume.css modern/css/screen.css modern/css/pdf.css > output/combined_pdf.less
lessc output/combined_pdf.less output/pdf.css

# 1. Build resume.html
echo "<style>" > output/style_header.html
cat output/resume.css >> output/style_header.html
echo "</style>" >> output/style_header.html

pandoc -f markdown+hard_line_breaks \
       -t html \
       --standalone \
       --template modern/template.html \
       --metadata pagetitle="$TITLE" \
       -H output/style_header.html \
       resume.md -o output/resume.html

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
       resume.md -o output/pdf.html

# 3. Generate PDF using Playwright + Chromium
node scripts/build_pdf.mjs output/pdf.html output/resume.pdf

# Copy resume.html to index.html for web serving
cp output/resume.html output/index.html

# Cleanup
rm output/style_header.html output/pdf_style_header.html output/combined.less output/combined_pdf.less output/resume.css output/pdf.css

echo "Built output/resume.html, output/index.html, output/pdf.html and output/resume.pdf"
