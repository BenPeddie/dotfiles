#!/bin/bash
# Run after Cursor edits a .ts or .tsx file
# Reads the edited file path from JSON stdin and runs prettier + eslint --fix

FILE=$(cat | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('file_path', d.get('path', '')))" 2>/dev/null)

if [ -z "$FILE" ]; then
  exit 0
fi

# Only act on .ts and .tsx files
if [[ "$FILE" != *.ts && "$FILE" != *.tsx ]]; then
  exit 0
fi

# Run from the file's directory to pick up local config
DIR=$(dirname "$FILE")

# Try prettier
if command -v npx &>/dev/null; then
  npx prettier --write "$FILE" 2>/dev/null || true
  npx eslint --fix "$FILE" 2>/dev/null || true
fi

exit 0
