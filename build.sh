#!/bin/bash
set -eo pipefail

apt-get update
apt-get install -qqy --no-install-recommends \
    fonts-nanum fonts-nanum-coding fonts-nanum-extra

mkdir output || true
md2resume pdf -t ./modern resume.md ./output
md2resume html -t ./modern resume.md ./output
