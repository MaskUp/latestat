#!/usr/bin/env bash
# Exit 1 if anything in your stack has reached end of life.
# Needs curl and jq. Usage:
#   ./check-eol.sh php:8.3.20 nodejs:24.1.0 ubuntu:22.04
# Product names are the ones in latestat.com URLs (latestat.com/php -> php).
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: $0 product:version [product:version ...]" >&2
  exit 2
fi

stack=$(IFS=,; echo "$*")
report=$(curl -fsS "https://latestat.com/api/stack.json?s=${stack}")

echo "$report" | jq -r '.items[] | "\((.status // .state) | ascii_upcase | .[0:9] + "         "[0:(9 - length)])  \(if .product then "\(.product) \(.version)" else .input end): \(.message)"'
echo
echo "Grade: $(echo "$report" | jq -r .grade)  ->  $(echo "$report" | jq -r .url)"

eol=$(echo "$report" | jq '.summary.eol')
if [ "$eol" -gt 0 ]; then
  echo "$eol item(s) have reached end of life." >&2
  exit 1
fi
