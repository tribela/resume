#!/bin/sh

set -e

git init
git config user.name "Travis CI"
git config user.email "<you>@<your-email>"

./markdown-resume/bin/md2resume html resume.md ./
./markdown-resume/bin/md2resume pdf resume.md ./
mv resume.html index.html

git add index.html
git add resume.pdf
git checkout gh-pages
git commit -m "Deploy to github pages"

git push --force --quiet "https://kjwon15:${GH_TOKEN}@${GH_REF}" gh-pages
