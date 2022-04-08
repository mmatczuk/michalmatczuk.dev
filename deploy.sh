#!/usr/bin/env bash
set -eu -o pipefail

rm -Rf public
hugo --minify

cd public
cp ../CNAME .

git init
git remote add origin git@github.com:mmatczuk/michalmatczuk.dev.git
git checkout -b gh-pages
git add .
git commit -m "publish pages"
git push origin gh-pages --force
